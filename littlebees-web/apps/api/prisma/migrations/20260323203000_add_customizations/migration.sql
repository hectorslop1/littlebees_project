-- CreateTable
CREATE TABLE "customizations" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "logo_url" TEXT,
    "primary_color" VARCHAR(7) NOT NULL DEFAULT '#D4A853',
    "secondary_color" VARCHAR(7) NOT NULL DEFAULT '#8FAE8B',
    "accent_color" VARCHAR(7) DEFAULT '#E8B84B',
    "system_name" VARCHAR(255) NOT NULL DEFAULT 'LittleBees',
    "menu_labels" JSONB NOT NULL DEFAULT '{}',
    "custom_css" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "customizations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "customizations_tenant_id_key" ON "customizations"("tenant_id");

-- AddForeignKey
ALTER TABLE "customizations" ADD CONSTRAINT "customizations_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
