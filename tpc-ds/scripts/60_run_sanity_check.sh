#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMMON_RESOURCES_DIR="$(realpath "${SCRIPT_DIR}"/../common_resources)"
set -o allexport; source  "${SCRIPT_DIR}"/../../../.env; set +o allexport
# ------------------------------------------------------------

for QUERY_FILE in ${SCRIPT_DIR}/../queries/sanity_check/*.sql;
do
    echo "Running ${QUERY_FILE}'"

    cat "${QUERY_FILE}" \
      | bq \
        --project_id=${PROJECT_ID} \
        --location=${REGION_1} \
        --dataset_id=${BQD_TPCDS_NATIVE_NOAUTODETECT} \
        query \
        --use_cache=false \
        --use_legacy_sql=false \
        --batch=false \
        --format=pretty
done
