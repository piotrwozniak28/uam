select
    {{ dbt_utils.star(source('tpcds_raw', 'call_center')) }}
from {{ source('tpcds_raw', 'call_center') }}