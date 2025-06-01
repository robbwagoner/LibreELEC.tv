#!/bin/bash

# Simple script to send notification popups to Kodi
# Usage: kodi-notify "Title" "Message" [duration_ms] [icon_type]

TITLE="${1:-Notification}"
MESSAGE="${2:-No message provided}"
DURATION="${3:-5000}"
ICON="${4:-info}"

# Valid icons: info, warning, error
if [[ ! "${ICON}" =~ '^(info|warning|error)$' ]] ; then
  ICON="info"
fi

# Kodi's JSON-RPC address (default for local connections)
KODI_HOST="127.0.0.1" # Using loopback IP to remove reliance on local hostname resolution vs. 'localhost'
KODI_PORT="8080"
KODI_HTTP_USERNAME="kodi"
KODI_HTTP_PASSWORD=""

if [ -f /storage/.config/kodi_notify.env ] ; then
  source /storage/.config/kodi_notify.env
fi

if [ -n "${KODI_HTTP_USERNAME}" ] && [ -n "${KODI_HTTP_PASSWORD}" ]; then
  # Use HTTP Basic Authentication if credentials are provided
  AUTH="-u ${KODI_HTTP_USERNAME}:${KODI_HTTP_PASSWORD}"
else
  AUTH=""
fi

logger -t kodi-notify "Sending notification: Title='${TITLE}', Message='${MESSAGE}', Duration=${DURATION}, Icon=${ICON}"

# Send the notification to Kodi using JSON-RPC
curl -s -X POST ${AUTH} \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"GUI.ShowNotification\",\"params\":{\"title\":\"${TITLE}\",\"message\":\"${MESSAGE}\",\"displaytime\":${DURATION},\"image\":\"${ICON}\"},\"id\":2}" \
  "http://$KODI_HOST:$KODI_PORT/jsonrpc" > /dev/null

exit $?