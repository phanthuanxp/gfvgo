/**
 * Read-only production compatibility probe.
 *
 * Scope: table/column metadata and Prisma migration names/status only.
 * It deliberately does not select business rows, credentials, tokens or
 * customer identifiers. Run only after the project owner approves the target
 * DATABASE_URL and least-privilege read-only database role.
 */
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@prisma/client";

const url = process.env.DATABASE_URL;
if (!url) throw new Error("DATABASE_URL is required");

const prisma = new PrismaClient({ adapter: new PrismaPg({ connectionString: url }) });

async function main() {
  const tables = await prisma.$queryRaw<Array<{ table_name: string }>>`
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    ORDER BY table_name
  `;
  const columns = await prisma.$queryRaw<Array<{ table_name: string; column_name: string; data_type: string }>>`
    SELECT table_name, column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    ORDER BY table_name, ordinal_position
  `;
  const migrations = await prisma.$queryRaw<Array<{ migration_name: string; finished_at: Date | null; rolled_back_at: Date | null }>>`
    SELECT migration_name, finished_at, rolled_back_at
    FROM "_prisma_migrations"
    ORDER BY started_at, migration_name
  `;

  console.log(JSON.stringify({
    scope: "schema-and-prisma-metadata-only",
    tableCount: tables.length,
    tables: tables.map((x) => x.table_name),
    columnCount: columns.length,
    columns,
    prismaMigrations: migrations.map((x) => ({
      name: x.migration_name,
      finished: Boolean(x.finished_at),
      rolledBack: Boolean(x.rolled_back_at),
    })),
  }, null, 2));
}

main().finally(() => prisma.$disconnect());
