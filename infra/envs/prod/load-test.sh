#!/bin/bash

URL="<YOUR_TARGET_ALB_URL_HERE>"

# Simple load test script that sends continuous requests to the given URL
# This will send requests in the background indefinitely. How many? As many as our system can handle.
while true; do
    # This command means it will use curl to send a request to the URL silently (-s) and discard the output (>/dev/null)
    curl -s $URL >/dev/null &
done
