\echo 'You need to use the following commands:'
\echo 'CREATE EXTENSION IF NOT EXISTS softvisio_admin CASCADE;'
\echo 'ALTER EXTENSION softvisio_admin UPDATE;'
\echo \quit

ALTER TABLE cron.schedule DROP COLUMN status;
ALTER TABLE cron.schedule RENAME COLUMN status_text TO last_run_error;
