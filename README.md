# PostgreSQL cron schema

## Install / update / drop

```
CREATE EXTENSION IF NOT EXISTS softvisio_cron;

ALTER EXTENSION softvisio_cron UPDATE;

DROP EXTENSION IF EXISTS softvisio_cron;
```

## Build

```
gmake USE_PGXS=1 install
```
