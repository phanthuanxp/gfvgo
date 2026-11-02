import assert from "node:assert/strict";
import { after, before, describe, it } from "node:test";
import { prisma } from "@/server/db";
import { encryptToken } from "@/server/crypto/token-vault";
import { MetaApiError } from "@/server/meta/client";
import { processSocialPublishQueue } from "@/server/social/publisher";

process.env.TOKEN_ENCRYPTION_KEY ??= "ci-only-token-encryption-key-32-characters";

type Fixture = { tenantA: string; tenantB: string; targetA: string; targetB: string; targetC: string };

function fakeAdapter(mode: "success" | "retry" | "permanent" = "success") {
  let calls = 0;
  return {
    get calls() { return calls; },
    publishPagePost: async (_pageId: string, token: string) => {
      assert.equal(token, "fake-page-token");
      calls += 1;
      if (mode === "retry") throw new MetaApiError("temporary fake failure", { code: 1, traceId: "fake-trace" });
      if (mode === "permanent") throw new MetaApiError("permanent fake failure", { code: 190, traceId: "fake-trace" });
      return { id: `fake_${calls}` };
    },
    publishGroupPost: async () => ({ id: "fake_group" }),
  };
}

async function fixture(): Promise<Fixture> {
  const suffix = Date.now().toString(36) + Math.random().toString(36).slice(2, 7);
  const tenantA = await prisma.tenant.create({ data: { name: "CI Tenant A", slug: `ci-a-${suffix}` } });
  const tenantB = await prisma.tenant.create({ data: { name: "CI Tenant B", slug: `ci-b-${suffix}` } });
  const workspaceA = await prisma.socialWorkspace.create({ data: { tenantId: tenantA.id, name: "A workspace", slug: `a-${suffix}` } });
  const workspaceB = await prisma.socialWorkspace.create({ data: { tenantId: tenantB.id, name: "B workspace", slug: `b-${suffix}` } });
  const pageA = await prisma.socialPage.create({ data: { workspaceId: workspaceA.id, name: "A page", slug: `a-${suffix}`, externalPageId: `page-a-${suffix}`, status: "CONNECTED" } });
  const pageB = await prisma.socialPage.create({ data: { workspaceId: workspaceB.id, name: "B page", slug: `b-${suffix}`, externalPageId: `page-b-${suffix}`, status: "CONNECTED" } });
  await prisma.socialConnection.createMany({ data: [
    { socialPageId: pageA.id, encryptedToken: encryptToken("fake-page-token"), grantedScopes: ["pages_manage_posts"] },
    { socialPageId: pageB.id, encryptedToken: encryptToken("fake-page-token"), grantedScopes: ["pages_manage_posts"] },
  ] });
  const contentA = await prisma.socialContent.create({ data: { socialPageId: pageA.id, topic: "CI", caption: "Synthetic post", hashtags: [], status: "SCHEDULED", scheduledAt: new Date(Date.now() - 1000), approvedAt: new Date() } });
  const contentB = await prisma.socialContent.create({ data: { socialPageId: pageB.id, topic: "CI", caption: "Synthetic post B", hashtags: [], status: "SCHEDULED", scheduledAt: new Date(Date.now() - 1000), approvedAt: new Date() } });
  const targetA = await prisma.socialPublishTarget.create({ data: { socialContentId: contentA.id, socialPageId: pageA.id, targetType: "PAGE", idempotencyKey: `a-${suffix}`, status: "SCHEDULED", scheduledAt: new Date(Date.now() - 1000) } });
  const targetB = await prisma.socialPublishTarget.create({ data: { socialContentId: contentB.id, socialPageId: pageB.id, targetType: "PAGE", idempotencyKey: `b-${suffix}`, status: "SCHEDULED", scheduledAt: new Date(Date.now() - 1000) } });
  const contentC = await prisma.socialContent.create({ data: { socialPageId: pageA.id, topic: "CI concurrent", caption: "Synthetic concurrent", hashtags: [], status: "SCHEDULED", scheduledAt: new Date(Date.now() - 1000), approvedAt: new Date() } });
  const targetC = await prisma.socialPublishTarget.create({ data: { socialContentId: contentC.id, socialPageId: pageA.id, targetType: "PAGE", idempotencyKey: `c-${suffix}`, status: "SCHEDULED", scheduledAt: new Date(Date.now() - 1000) } });
  return { tenantA: tenantA.id, tenantB: tenantB.id, targetA: targetA.id, targetB: targetB.id, targetC: targetC.id };
}

async function cleanup(f: Fixture) {
  await prisma.auditLog.deleteMany({ where: { tenantId: { in: [f.tenantA, f.tenantB] } } });
  await prisma.tenant.deleteMany({ where: { id: { in: [f.tenantA, f.tenantB] } } });
}

describe("PostgreSQL-backed publisher", () => {
  let f: Fixture;
  before(async () => { f = await fixture(); });
  after(async () => { await cleanup(f); await prisma.$disconnect(); });

  it("publishes scheduled target and is idempotent on rerun", async () => {
    const adapter = fakeAdapter();
    const first = await processSocialPublishQueue({ targetId: f.targetA, adapter });
    const second = await processSocialPublishQueue({ targetId: f.targetA, adapter });
    const row = await prisma.socialPublishTarget.findUniqueOrThrow({ where: { id: f.targetA } });
    assert.equal(first[0]?.status, "PUBLISHED");
    assert.equal(second.length, 0);
    assert.equal(row.status, "PUBLISHED");
    assert.equal(adapter.calls, 1);
    assert.equal(row.externalPostId, "fake_1");
  });

  it("records retry backoff and permanent failure without token leakage", async () => {
    const retry = fakeAdapter("retry");
    await processSocialPublishQueue({ targetId: f.targetB, adapter: retry });
    const retried = await prisma.socialPublishTarget.findUniqueOrThrow({ where: { id: f.targetB } });
    assert.equal(retried.status, "FAILED");
    assert.equal(retried.permanentFailure, false);
    assert.ok(retried.nextAttemptAt);
    assert.equal(JSON.stringify(await prisma.auditLog.findMany({ where: { resourceId: f.targetB } })).includes("fake-page-token"), false);
    await prisma.socialPublishTarget.update({ where: { id: f.targetB }, data: { nextAttemptAt: new Date(Date.now() - 1), status: "FAILED" } });
    const permanent = fakeAdapter("permanent");
    await processSocialPublishQueue({ targetId: f.targetB, adapter: permanent });
    const failed = await prisma.socialPublishTarget.findUniqueOrThrow({ where: { id: f.targetB } });
    assert.equal(failed.permanentFailure, true);
  });

  it("allows only the target page tenant through the queue and claims once", async () => {
    const adapter = fakeAdapter();
    const results = await Promise.all([
      processSocialPublishQueue({ targetId: f.targetC, adapter }),
      processSocialPublishQueue({ targetId: f.targetC, adapter }),
    ]);
    const row = await prisma.socialPublishTarget.findUniqueOrThrow({ where: { id: f.targetC } });
    assert.equal(row.socialPageId !== f.targetB, true);
    assert.equal(adapter.calls, 1);
    assert.equal(results.flat().filter((x) => x.status === "PUBLISHED").length, 1);
  });
});
