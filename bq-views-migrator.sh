#/bin/bash

ORIGP="crypto-song-153217"
NEWP="al-bi-bq-test"

bq --project-id="$ORIGP" ls | tail -n +3 | sed -e 's/ *//g' | \
while read i; do
    echo "this is $i"

    bq show --format=prettyjson --project-id="$ORIGP" [DATASET].[VIEW] > view.json
    export TEST="$(cat dim_affiliates_v.json | jq '.view.query' | sed -z 's/\\n/ /g' | sed -e 's/\"//g')"
    bq mk --project_id=al-bi-bq-test --use_legacy_sql=false --view $TEST dwh.dim_affiliates_test_v

done

