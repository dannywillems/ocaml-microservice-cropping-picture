## This Makefile must only be used for testing. It creates a local directory for
## the database.
## See Makefile.conf for configuration.

include Makefile.conf

ENV_PSQL          := PGHOST=$(DB_HOST) PGDATABASE=$(DB_NAME) PGPORT=$(DB_PORT) \
                     PGUSER=$(DB_USER) PGPASSWORD=$(DB_PASSWORD)

pg_dump = pg_dump

# Rule to get the pg_ctl binary.
ifeq ($(shell psql --version 2> /dev/null),)
$(error "PostgreSQL is not installed")
else
PSQL_VERSION := $(shell psql --version | cut -d' ' -f 3 | cut -d'.' -f 1-2)
pg_ctl       := $(shell \
                  sh -c "which pg_ctl" || \
                  sh -c "echo /usr/lib/postgresql/$(PSQL_VERSION)/bin/pg_ctl")
endif

## ---------------------------------------------------------------------
## Here some rules to easily manage the database.
# - db-init:
#   Initialise the database. It creates the directory PSQL_DIR and
#   start the database.
#
# - db-start:
#   Start the database.
#
# - db-stop:
#   Stop the database.
#
# - db-status:
#   Get the database status.
#
# - db-create:
#   Create the database and use UNICODE.
#
# - db-schema:
#   Execute the SQL file contained in the PSQL_FILE variable to create the
#   schema and the tables.
#
# - db-drop:
#   Drop the database but doesn't remove the database directory PSQL_DIR.
#
# - db-psql:
#   Connect to the database.
#
# - db-delete:
#   Stop the database (without error if it's not running) and remove
#   the database directory containing all database data.

##----------------------------------------------------------------------

$(PSQL_DIR):
	-mkdir -p $@

db-init: $(PSQL_DIR)
	$(pg_ctl) initdb -D $(PSQL_DIR)
	echo unix_socket_directories = \'/tmp\' >> $(PSQL_DIR)/postgresql.conf
	$(pg_ctl) -o "-p $(DB_PORT)" -D $(PSQL_DIR) -l $(PSQL_LOG) start

db-start:
	$(pg_ctl) -o "-p $(DB_PORT)" -D $(PSQL_DIR) -l $(PSQL_LOG) start

db-stop:
	$(pg_ctl) -D $(PSQL_DIR) -l $(PSQL_LOG) stop

db-status:
	$(pg_ctl) -D $(PSQL_DIR) -l $(PSQL_LOG) status

db-delete:
	$(pg_ctl) -D $(PSQL_DIR) -l $(PSQL_LOG) stop || true
	rm -rf $(PSQL_DIR)

db-snapshot:
	@echo "# Creating $(DB_SNAPSHOT)"
	$(ENV_PSQL) $(pg_dump) --clean --create --no-owner --encoding=utf8 \
        $(DB_NAME) | gzip > $(DB_SNAPSHOT)

db-create:
	$(ENV_PSQL) createdb --encoding UNICODE $(DB_NAME)

db-schema:
	$(ENV_PSQL) psql -d $(DB_NAME) -f $(PSQL_FILE)

db-drop:
	$(ENV_PSQL) dropdb $(DB_NAME)

db-psql:
	$(ENV_PSQL) psql $(DB_NAME)

##----------------------------------------------------------------------

BLOB_GOOGLE=data:image/jpeg;base64,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
test-google-image:
	curl -X POST \
       -H "Content-Type: application/json" \
       -d \
       '{"blob": "$(BLOB_GOOGLE)", "width": 90, "height": 90, "crop": {"top": 30, "bottom": 15, "left": 15, "right": 30}}' \
       http://localhost:9000/crop
