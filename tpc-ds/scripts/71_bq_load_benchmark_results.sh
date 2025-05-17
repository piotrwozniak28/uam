#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BENCHMARK_RESULTS_DIR="$(realpath ${SCRIPT_DIR}/../benchmark_results)"

source ${SCRIPT_DIR}/../.env


bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_RESULTS}
bq --project_id=${PROJECT_ID} --location=${REGION_1} mk ${BQD_TPCDS_RESULTS}


# Create call_center table with schema autodetect
bq --project_id=${PROJECT_ID} \
   --location=${REGION_1} \
load \
--autodetect \
--source_format=CSV \
--null_marker '' \
--field_delimiter ',' \
${BQD_TPCDS_RESULTS}.${BENCHMARK_RESULTS_FILE} \
${BENCHMARK_RESULTS_DIR}/${BENCHMARK_RESULTS_FILE}.csv \
query_num:string,\
start_time:integer,\
end_time:integer,\
bytes_billed:integer
