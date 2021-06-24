#!/bin/bash
API_URL="https://ote-api.nameshield.net/v1"
IP_SERVICE="http://me.gandi.net"
date=$(date "+[%Y-%m-%d %H:%M:%S]")

#Setting up IPV4 address
if [[ -z "${FORCE_IPV4}" ]]; then
  WAN_IPV4=$(curl -s4 ${IP_SERVICE})
  if [[ -z "${WAN_IPV4}" ]]; then
    echo -e "${date} [ERROR]\nSomething went wrong. Can not get your IPv4 from ${IP_SERVICE}"
    exit 1
  fi
else
  WAN_IPV4="${FORCE_IPV4}"
fi

#Update DNS zone records with WAN IPV4
for RECORD in ${RECORD_LIST//;/ }; do
  if [ "${RECORD}" = "@" ] || [ "${RECORD}" = "*" ]; then
    SUBDOMAIN="${DOMAIN}"
  else
    SUBDOMAIN="${RECORD}.${DOMAIN}"
  fi

  CURRENT_IPV4=$(dig A ${SUBDOMAIN} +short)

  if [ "${CURRENT_IPV4}" = "${WAN_IPV4}" ]; then
    echo -e "${date} [INFO]\nCurrent DNS A record for ${RECORD} matches WAN IP (${CURRENT_IPV4}). Nothing to do."
    continue
  fi

#Prepared date for the query
  DATA='{"name":"", "type": "A", "data": '"${WAN_IPV4}"' , "ttl": '${TTL}'}'

#Query to update with WAN IPV4
  status=$(curl --location --request "${API_URL}/zones/${DOMAIN}/records" \
    -H"Authorization: Bearer ${APIKEY}" \
    -H"Content-Type: application/json" \
    --data-raw "${DATA}")

  if [ "${status}" = '201' ]; then
    echo -e "${date} [OK]\nUpdated ${RECORD} to ${WAN_IPV4}"
  else
    echo -e "${date} [ERROR]\nAPI POST returned status ${status}"
  fi
done
exit 0
