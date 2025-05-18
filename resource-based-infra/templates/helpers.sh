gcloud auth application-default set-quota-project "prj-tpcds-qpzo1"

bq ls --project_id "prj-tpcds-qpzo1" --format=json | jq -r '.[].datasetReference.datasetId' | \
while read -r DATASET_ID; do
    echo "Processing dataset: prj-tpcds-qpzo1:${DATASET_ID}"
    bq ls --format=json "prj-tpcds-qpzo1:${DATASET_ID}" | \
        jq -r '.[] | select(.type=="TABLE" or .type=="VIEW") | .id' | \
        while read -r OBJECT_ID; do
            echo "  Deleting: ${OBJECT_ID}"
            # For a dry run to see what WOULD be deleted, comment out the 'bq rm'
            # line below and uncomment the 'echo "  WOULD DELETE..." line.
            # echo "  WOULD DELETE: ${OBJECT_ID} (Dry Run)"
            bq rm -f --table "${OBJECT_ID}"
        done
done
