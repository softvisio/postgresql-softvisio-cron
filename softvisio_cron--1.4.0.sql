\echo 'You need to use the following commands:'
\echo 'CREATE EXTENSION IF NOT EXISTS softvisio_admin CASCADE;'
\echo 'ALTER EXTENSION softvisio_admin UPDATE;'
\echo \quit

CREATE SCHEMA IF NOT EXISTS cron;
GRANT USAGE ON SCHEMA cron TO PUBLIC;

CREATE SEQUENCE IF NOT EXISTS cron.schedule_id_seq AS int8 CYCLE;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA cron TO PUBLIC;

CREATE TABLE IF NOT EXISTS cron.schedule (
    id int8 PRIMARY KEY NOT NULL,
    module text NOT NULL,
    name text NOT NULL,
    username text NOT NULL,
    cron text NOT NULL,
    timezone text,
    query json NOT NULL,
    run_as_superuser bool NOT NULL DEFAULT FALSE,
    run_missed bool NOT NULL DEFAULT TRUE,
    next_start timestamptz( 0 ),
    last_started timestamptz,
    last_finished timestamptz,
    last_run_error text,
    schedule_error text,
    UNIQUE ( username, module, name )
);

CREATE OR REPLACE FUNCTION schedule_before_insert_trigger() RETURNS TRIGGER AS $$
BEGIN
    NEW.id = nextval( 'cron.schedule_id_seq' );
    NEW.username = CURRENT_USER;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION schedule_after_update_trigger() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify( 'cron/update', json_build_object(
        'id', NEW.id::text,
        'module', NEW.module,
        'name', NEW.name,
        'username', NEW.username,
        'cron', NEW.cron,
        'timezone', NEW.timezone,
        'query', NEW.query,
        'run_as_superuser', NEW.run_as_superuser,
        'run_missed', NEW.run_missed
    )::text );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION schedule_after_delete_trigger() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify( 'cron/delete', json_build_object(
        'id', OLD.id::text
    )::text );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS schedule_before_insert ON cron.schedule;
CREATE TRIGGER schedule_before_insert BEFORE INSERT ON cron.schedule FOR EACH ROW EXECUTE FUNCTION schedule_before_insert_trigger();

DROP TRIGGER IF EXISTS schedule_after_insert ON cron.schedule;
CREATE TRIGGER schedule_after_insert AFTER INSERT ON cron.schedule FOR EACH ROW EXECUTE FUNCTION schedule_after_update_trigger();

DROP TRIGGER IF EXISTS schedule_after_update ON cron.schedule;
CREATE TRIGGER schedule_after_update AFTER UPDATE OF cron, timezone, query, run_as_superuser, run_missed ON cron.schedule FOR EACH ROW EXECUTE FUNCTION schedule_after_update_trigger();

DROP TRIGGER IF EXISTS schedule_after_delete ON cron.schedule;
CREATE TRIGGER schedule_after_delete AFTER DELETE ON cron.schedule FOR EACH ROW EXECUTE FUNCTION schedule_after_delete_trigger();

ALTER TABLE cron.schedule ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS cron_schedule_policy ON cron.schedule;
CREATE POLICY cron_schedule_policy ON cron.schedule FOR ALL USING ( username = CURRENT_USER );

GRANT
    SELECT,
    DELETE,
    INSERT ( id, module, name, username, cron, timezone, query, run_as_superuser, run_missed ),
    UPDATE ( module, name, cron, timezone, query, run_as_superuser, run_missed )
ON cron.schedule TO PUBLIC;
