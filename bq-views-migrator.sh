#/bin/bash

ORIGP="crypto-song-153217"
NEWP="al-bi-bq-test"
MAX=10000

bq --project-id="$ORIGP" ls -n "$MAX" | tail -n +3 | sed -e 's/ *//g' | \
while read DS; do
    
    echo "this is $DS"

    bq ls -n "$MAX" "$DS" | grep VIEW | sed -e 's/ \+/ /g' | cut -d' ' -f2 | \
    while read VIEW; do

        bq show --format=prettyjson --project-id="$ORIGP" "$DS"."$VIEW" > "$VIEW.json"
        cat "$VIEW.json" | jq '.view.query' | sed -z 's/\\n/ /g' | sed -e 's/\"//g' > 

        bq mk --project_id="$NEWP" --use_legacy_sql=false --view $TEST "$i".dim_affiliates_test_v

done

