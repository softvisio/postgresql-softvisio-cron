\echo 'You need to use the following commands:'
\echo 'CREATE EXTENSION IF NOT EXISTS softvisio_admin CASCADE;'
\echo 'ALTER EXTENSION softvisio_admin UPDATE;'
\echo \quit

ALTER TABLE cron.schedule RENAME COLUMN as_superuser TO run_as_superuser;

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

DROP TRIGGER IF EXISTS schedule_after_update ON cron.schedule;
CREATE TRIGGER schedule_after_update AFTER UPDATE OF cron, timezone, query, run_as_superuser, run_missed ON cron.schedule FOR EACH ROW EXECUTE FUNCTION schedule_after_update_trigger();

GRANT
    SELECT,
    DELETE,
    INSERT ( id, module, name, username, cron, timezone, query, run_as_superuser, run_missed ),
    UPDATE ( module, name, cron, timezone, query, run_as_superuser, run_missed )
ON cron.schedule TO PUBLIC;
