import { defineConfig } from "prisma/config";

// Baseline-only config for a brand-new database. Existing databases keep the
// historical prisma/migrations chain and must not use this path.
export default defineConfig({
  schema: "baseline/schema.prisma",
  migrations: { path: "baseline/migrations" },
  datasource: {
    url: process.env.DATABASE_URL ?? "postgresql://localhost:5432/gfvgo_baseline",
  },
});
