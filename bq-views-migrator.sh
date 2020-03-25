#/bin/bash

ORIGP="crypto-song-153217"
NEWP="al-bi-bq-test"
MAX=10000
TEMPDIR="$HOME/bq-temp"

bq --project-id="$ORIGP" ls -n "$MAX" | tail -n +3 | sed -e 's/ *//g' | \
while read DS; do
    
    echo "this is $DS"

    bq ls -n "$MAX" "$DS" | grep VIEW | sed -e 's/ \+/ /g' | cut -d' ' -f2 | \
    while read VIEW; do

        DSDIR="$TEMPDIR/$DS"
        
        mkdir -p "$DSDIR"
        bq show --format=prettyjson --project-id="$ORIGP" "$DS"."$VIEW" > "$DSDIR/$VIEW.json"

        QUERY="$(cat "$DSDIR/$VIEW.json" | jq '.view.query' \
              | sed -z 's/\\n/ /g' | sed -e 's/\"//g')"

        bq mk --project_id="$NEWP" --use_legacy_sql=false \
              --view "$QUERY" "$DS"."$VIEW"
    done
done
