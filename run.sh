#!/usr/bin/env bash
set -e
set -x

if [[ -z "${DATABASE_URL}" ]]; then
  export SIMPLEVOTE_DB_URL=$DATABASE_URL

  cat > /simplevote.properties << EOF
jdbc.url="jdbc:$DATABASE_URL"
version=1.0.0
activejdbc.version=1.4.13
main.class=com.simplevote.webservice.WebService
EOF

fi

sleep 7s
java -jar /opt/simplevote.jar -liquibase

# graceful exit - probably won't ever get here
exit 0
