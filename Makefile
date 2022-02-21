EXTENSION = softvisio_cron
DATA =	\
	softvisio_cron--1.0.0.sql \
	softvisio_cron--1.0.0--1.1.0.sql \
	softvisio_cron--1.1.0--1.1.1.sql \
	softvisio_cron--1.1.1--1.2.0.sql \
	softvisio_cron--1.2.0.sql \
	softvisio_cron--1.2.0--1.3.0.sql \
	softvisio_cron--1.3.0.sql \
	softvisio_cron--1.3.0--1.4.0.sql \
	softvisio_cron--1.4.0.sql \
	softvisio_cron--1.4.0--1.5.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
