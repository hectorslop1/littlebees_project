-- Fase 4: Sistema de Justificantes
-- Crear enums para tipos y estados de justificantes

CREATE TYPE "ExcuseType" AS ENUM ('sick', 'late_arrival', 'absence', 'other');
CREATE TYPE "ExcuseStatus" AS ENUM ('pending', 'approved', 'rejected');

-- Crear tabla de justificantes
CREATE TABLE "excuses" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id") ON DELETE CASCADE,
    "child_id" UUID NOT NULL REFERENCES "children"("id") ON DELETE CASCADE,
    "parent_id" UUID NOT NULL,
    "type" "ExcuseType" NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "date" DATE NOT NULL,
    "attachments" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "status" "ExcuseStatus" NOT NULL DEFAULT 'pending',
    "reviewed_by" UUID,
    "reviewed_at" TIMESTAMP,
    "created_at" TIMESTAMP NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Crear índices para optimizar consultas
CREATE INDEX "excuses_tenant_id_child_id_idx" ON "excuses"("tenant_id", "child_id");
CREATE INDEX "excuses_tenant_id_date_idx" ON "excuses"("tenant_id", "date");
CREATE INDEX "excuses_tenant_id_status_idx" ON "excuses"("tenant_id", "status");

-- Comentarios para documentación
COMMENT ON TABLE "excuses" IS 'Justificantes enviados por padres para ausencias, llegadas tarde, etc.';
COMMENT ON COLUMN "excuses"."type" IS 'Tipo de justificante: enfermedad, llegada tarde, ausencia, otro';
COMMENT ON COLUMN "excuses"."status" IS 'Estado del justificante: pendiente, aprobado, rechazado';
COMMENT ON COLUMN "excuses"."attachments" IS 'URLs de archivos adjuntos (fotos, documentos médicos, etc.)';
