#!/bin/bash
# Dumb Cron helper to Drop/Rotate data in ES sandbox

# MANDATORY: Facetflow API Key
API_KEY=""

# Use local https proxy or actual url
ES_HOST='http://localhost:19200'
# Document Limit per index being checked
LIMIT=4000
TODAY=$(date +%Y.%m.%d)

# Count documents in index
COUNT=$(curl -XGET "$ES_HOST/logstash-$TODAY/_count" -u $API_KEY: -d '{"query": {"match_all": {} } }' -s | sed 's,.*count":\([^<]*\)}.*,\1,g' )
echo "Current index count is: $COUNT"

# Remove if count is higher than $LIMIT
if [ "$COUNT" -gt "$LIMIT" ]; then
	echo "Deleting logstash-$TODAY"
	curl -XDELETE "$ES_HOST/logstash-$TODAY/" -u $API_KEY:
	echo
	exit 1;
fi
exit 0;
