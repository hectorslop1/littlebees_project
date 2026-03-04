-- Enable Row Level Security extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom setting for tenant context
-- This allows SET LOCAL app.tenant_id = 'uuid' for RLS
ALTER DATABASE kinderspace_dev SET app.tenant_id = '';
