EXTENSION = softvisio_cron
DATA =	\
	softvisio_cron--1.0.0.sql \
	softvisio_cron--1.0.0--1.1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)