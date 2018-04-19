#!/bin/bash

set -e
set -o pipefail

if [[ -n ${DEBUG} ]] ; then
  echo "DEBUG: VCAP_SERVICES:   ${VCAP_SERVICES}"
  echo "DEBUG: fromService:     ${fromService}"
  echo "DEBUG: toService:       ${toService}"
fi


if [[ -z ${VCAP_SERVICES} ]] ; then
  echo "\${VCAP_SERVICES} not set!"
  exit 1
fi
if [[ -z ${fromService} ]] ; then
  echo "\${fromService} not set!"
  exit 1
fi
if [[ -z ${toService} ]] ; then
  echo "\${toService} not set!"
  exit 1
fi

declare -A  from
declare -A  to

from[service_type_name]=${OLD_SERVICE_TYPE_NAME:-redis}
to[service_type_name]=${NEW_SERVICE_TYPE_NAME:-redis}

from[host]=$( echo "${VCAP_SERVICES}" | jq ".\"${from[service_type_name]}\"[] | select( .name == \"${fromService}\" ) | .credentials.host" | tr -d '"')
from[password]=$( echo "${VCAP_SERVICES}" | jq ".\"${from[service_type_name]}\"[] | select( .name == \"${fromService}\" ) | .credentials.password" | tr -d '"')
from[port]=$( echo "${VCAP_SERVICES}" | jq ".\"${from[service_type_name]}\"[] | select( .name == \"${fromService}\" ) | .credentials.port" | tr -d '"')

to[host]=$( echo "${VCAP_SERVICES}" | jq ".\"${to[service_type_name]}\"[] | select( .name == \"${toService}\" ) | .credentials.host" | tr -d '"')
to[password]=$( echo "${VCAP_SERVICES}" | jq ".\"${to[service_type_name]}\"[] | select( .name == \"${toService}\" ) | .credentials.password" | tr -d '"')
to[port]=$( echo "${VCAP_SERVICES}" | jq ".\"${to[service_type_name]}\"[] | select( .name == \"${toService}\" ) | .credentials.port" | tr -d '"')

if [[ -n ${DEBUG} ]] ; then
  echo "DEBUG: from[host]:     ${from[host]}"
  echo "DEBUG: from[password]: ${from[password]}"
  echo "DEBUG: from[port]:     ${from[port]}"

  echo "DEBUG: to[host]:     ${to[host]}"
  echo "DEBUG: to[password]: ${to[password]}"
  echo "DEBUG: to[port]:     ${to[port]}"
fi


if [[ -z ${from[host]} ]] ; then
  echo "could not resolve details of \"${fromService}\" from \${VCAP_SERVICES}!"
  exit 1
fi
if [[ -z ${to[host]} ]] ; then
  echo "could not resolve details of \"${toService}\" from \${VCAP_SERVICES}!"
  exit 1
fi

echo "Starting redis Migration"
echo "  from: ${fromService}"
echo "  to:   ${toService}"
echo ""

if [[ -n ${DEBUG} ]] ; then
echo "Going to execute the following command:
unbuffer redis-dump \
  -h ${from[host]} \
  -p ${from[port]} \
  -a ${from[password]} | \
redis-cli \
  -h ${to[host]} \
  -p ${to[port]} \
  -a ${to[password]} \
"
fi

unbuffer redis-dump \
  -h ${from[host]} \
  -p ${from[port]} \
  -a ${from[password]} | \
redis-cli \
  -h ${to[host]} \
  -p ${to[port]} \
  -a ${to[password]}

sourceDb="$(redis-cli -h ${from[host]} -p ${from[port]} -a ${from[password]} DBSIZE)"
targetDb="$(redis-cli -h ${to[host]} -p ${to[port]} -a ${to[password]} DBSIZE)"
dbsizesame=0

if [ "$sourceDb" != "$targetDb" ]; then
  dbsizesame=1
fi

RC=$?
echo "Finished redis Migration with RC: $?"
if [[ ${RC} -eq 0 && ${dbsizesame} -eq 0 ]]; then
  echo "MIGRATION SUCCESSFULL"
else
  echo "MIGRATION FAILED"
fi

while true ; do
  echo "This App can now be deleted"
  sleep 60
done
