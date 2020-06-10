#/bin/bash

# You need to install parallel and gcloud first to be able to use this script

if [ $# -lt 2 ]; then
    echo "Please enter the following args: <source-project-id> <new-project-id>"
    exit 1
fi

export PARAL_ARGS=(--will-cite -v -j4 --progress)

if echo "$@" | grep 'dry-run' &> /dev/null; then
    PARAL_ARGS+=(--dry-run)
fi

export ORIGP="$1"
export NEWP="$2"
export MAX=10000

export DS="$(bq --project_id="$ORIGP" ls -n "$MAX" | tail -n +3 | sed -e 's/ *//g')"

create_dataset() {    
    echo "Creating $1 dataset"
    bq --project_id="$NEWP" mk "$1"
}; export -f create_dataset

parallel "${PARAL_ARGS[@]}" create_dataset ::: "$DS"

copy_tables() {
    echo "bq cp -n "$ORIGP":"$1"."$2" "$NEWP":"$1"."$2""
    bq cp -n "$ORIGP":"$1"."$2" "$NEWP":"$1"."$2"
}; export -f copy_tables

for CURRENT_DS in $DS; do

    echo "$CURRENT_DS"
    export CURRENT_TABLES="$(bq --project_id="$ORIGP" ls -n "$MAX" "$CURRENT_DS" | grep TABLE | sed -e 's/ \+/ /g' | cut -d' ' -f2)"
    parallel "${PARAL_ARGS[@]}" copy_tables "$CURRENT_DS" ::: "$CURRENT_TABLES"

done

copy_views() {
    QUERY="$(bq --project_id="$ORIGP" show --format=sparse --view "$1"."$2" | tail -n +5 \
                | sed -e 's/^ \{2\}//g' | sed -e "s/$ORIGP/$NEWP/g")"

    echo "bq mk --project_id="$NEWP" --use_legacy_sql=false --view <query> "$1"."$2""
    bq mk --project_id="$NEWP" --use_legacy_sql=false --view "$QUERY" "$1"."$2"
}; export -f copy_views

for CURRENT_DS in $DS; do

    echo "$CURRENT_DS"
    export CURRENT_VIEWS="$(bq --project_id="$ORIGP" ls -n "$MAX" "$CURRENT_DS" | grep VIEW | sed -e 's/ \+/ /g' | cut -d' ' -f2)"
    parallel "${PARAL_ARGS[@]}" copy_views "$CURRENT_DS" ::: "$CURRENT_VIEWS"

done
