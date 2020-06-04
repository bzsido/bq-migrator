#!/bin/bash

# You need to install gcloud first to be able to use this script

if [ $# -lt 2 ]; then
    echo "Please enter the following args: <source-project-id> <new-project-id>"
    exit 1
fi

ORIGP="$1"
NEWP="$2"
MAX=10000

bq ls -n "$MAX" --project_id="$ORIGP"  | tail -n +3 | sed -e 's/ *//g' | \
while read DS; do

    echo "Comparing dataset $DS"
    diff  <(bq ls -n "$MAX" --project_id="$ORIGP"  "$DS" | tr -s ' ' | tail -n +3)  <(bq ls -n "$MAX" --project_id="$NEWP" "$DS" | tr -s ' ' | tail -n +3)
done
