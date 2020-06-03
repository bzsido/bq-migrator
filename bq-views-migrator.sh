#/bin/bash

ORIGP="$1" #"crypto-song-153217"
NEWP="$2" #"al-bi-bq-prod"
MAX=10000

bq --project_id="$ORIGP" ls -n "$MAX" | tail -n +3 | sed -e 's/ *//g' | \
while read DS; do
    
    echo "dataset is $DS"

    bq ls -n "$MAX" "$DS" | grep VIEW | sed -e 's/ \+/ /g' | cut -d' ' -f2 | \
    while read VIEW; do

        QUERY="$(bq show --format=sparse --view "$DS"."$VIEW" | tail -n +5 \
                | sed -e 's/^ \{2\}//g' | sed -e "s/$ORIGP/$NEWP/g")"

        # think about legacy sql param
        bq mk --project_id="$NEWP" --use_legacy_sql=false \
              --view "$QUERY" "$DS"."$VIEW"
    done
done
