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

# For Sandbox only, chop all Logstash indexes without mercy or use date ranger
INDEXS='*'
# INDEXS=$(date +%Y.%m.*)

# Count documents in index
COUNT=$(curl -XGET "$ES_HOST/nprobe-$INDEXS/_count" -u $API_KEY: -d '{"query": {"match_all": {} } }' -s | sed 's,.*count":\([^<]*\)}.*,\1,g' )
echo "Current nProbe document count is: $COUNT"

# Remove if count is higher than $LIMIT
if [ "$COUNT" -gt "$LIMIT" ]; then
	echo "Deleting nprobe-$INDEXS"
	curl -XDELETE "$ES_HOST/nprobe-$INDEXS/" -u $API_KEY:
	echo
	exit 1;
fi
exit 0;
