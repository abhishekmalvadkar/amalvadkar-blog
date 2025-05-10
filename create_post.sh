#!/bin/bash

title=$1
date=$(date +%Y-%m-%d)
year=$(date +%Y)
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
filename="$year/$date-$slug.md"
npm run create posts/$filename
