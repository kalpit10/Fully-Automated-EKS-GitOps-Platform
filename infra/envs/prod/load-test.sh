#!/bin/bash

# URL="<YOUR_TARGET_ALB_URL_HERE>"

# Simple load test script that sends continuous requests to the given URL
# This will send requests in the background indefinitely. How many? As many as our system can handle.
while true; do 
  for i in {1..200}; do 
    curl -s http://proshop-alb-prod-970944878.us-east-1.elb.amazonaws.com/ >/dev/null & 
  done 
  wait
done
