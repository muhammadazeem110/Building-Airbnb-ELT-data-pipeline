
-- ============================================
-- 1. Create a Generic CDC Log Table
-- ============================================
CREATE TABLE IF NOT EXISTS public.cdc_log (
    id SERIAL PRIMARY KEY,
    source_schema TEXT,
    source_table TEXT,
    change_type TEXT,               -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at TIMESTAMP DEFAULT NOW(),
    primary_key TEXT,
    old_data JSONB,
    new_data JSONB
);

-- ============================================
-- 2. Create a Generic CDC Logger Function
-- ============================================
CREATE OR REPLACE FUNCTION public.generic_cdc_logger()
RETURNS TRIGGER AS $$
DECLARE
    pk_value TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        pk_value := COALESCE(NEW.id::TEXT, '');
        INSERT INTO public.cdc_log (
            source_schema,
            source_table,
            change_type,
            primary_key,
            new_data
        )
        VALUES (
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            TG_OP,
            pk_value,
            to_jsonb(NEW)
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        pk_value := COALESCE(NEW.id::TEXT, '');
        INSERT INTO public.cdc_log (
            source_schema,
            source_table,
            change_type,
            primary_key,
            old_data,
            new_data
        )
        VALUES (
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            TG_OP,
            pk_value,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        pk_value := COALESCE(OLD.id::TEXT, '');
        INSERT INTO public.cdc_log (
            source_schema,
            source_table,
            change_type,
            primary_key,
            old_data
        )
        VALUES (
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            TG_OP,
            pk_value,
            to_jsonb(OLD)
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 3. Example: Add Triggers to Tables
-- ============================================
-- Adjust these as needed for your tables/schemas

-- For bronze.raw_airbnb_data table
-- CREATE TRIGGER cdc_airbnb
-- AFTER INSERT OR UPDATE OR DELETE ON bronze.raw_airbnb_data
-- FOR EACH ROW EXECUTE FUNCTION public.generic_cdc_logger();

-- For bronze.census_data table
-- CREATE TRIGGER cdc_census
-- AFTER INSERT OR UPDATE OR DELETE ON bronze.census_data
-- FOR EACH ROW EXECUTE FUNCTION public.generic_cdc_logger();
