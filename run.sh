#!/usr/bin/env bash
set -e
set -x

if [[ -z "${DATABASE_URL}" ]]; then
  export SIMPLEVOTE_DB_URL=$DATABASE_URL
fi

sleep 7s
java -jar /opt/simplevote.jar -liquibase

# graceful exit - probably won't ever get here
exit 0
