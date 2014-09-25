#!/bin/bash
# Hyper Dumb Cron helper to Drop/Rotate data in ES sandbox @facetflow
# If you need something smart, secure and reliable, please use the official helper scripts from ES

# m h  dom mon dow   command
# */5 * * * * /opt/rotate_stash.sh

# MANDATORY: Your Facetflow API Key
API_KEY=""

# Use local nginx https proxy or actual ES url
ES_HOST='http://localhost:19200'

# Document Limit per index being checked
LIMIT=4500

# For Sandbox only, chop without mercy
INDEXS=$(date +%Y.%m.*)

# Count documents in index
COUNT=$(curl -XGET "$ES_HOST/logstash-$INDEXS/_count" -u $API_KEY: -d '{"query": {"match_all": {} } }' -s | sed 's,.*count":\([^<]*\)}.*,\1,g' )
echo "Current index count is: $COUNT"

# Remove if count is higher than $LIMIT
if [ "$COUNT" -gt "$LIMIT" ]; then
	echo "Deleting logstash-$INDEXS"
	curl -XDELETE "$ES_HOST/logstash-$INDEXS/" -u $API_KEY:
	echo
	exit 1;
fi
exit 0;
