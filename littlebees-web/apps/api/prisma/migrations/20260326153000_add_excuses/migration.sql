CREATE TABLE "excuses" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "child_id" UUID NOT NULL,
    "submitted_by" UUID NOT NULL,
    "type" VARCHAR(50) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "date" DATE NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'pending',
    "reviewed_by" UUID,
    "reviewed_at" TIMESTAMP(3),
    "review_notes" TEXT,
    "attachments" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "excuses_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "excuses_tenant_id_status_date_idx" ON "excuses"("tenant_id", "status", "date");
CREATE INDEX "excuses_tenant_id_child_id_date_idx" ON "excuses"("tenant_id", "child_id", "date");

ALTER TABLE "excuses"
ADD CONSTRAINT "excuses_tenant_id_fkey"
FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id")
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "excuses"
ADD CONSTRAINT "excuses_child_id_fkey"
FOREIGN KEY ("child_id") REFERENCES "children"("id")
ON DELETE RESTRICT ON UPDATE CASCADE;
