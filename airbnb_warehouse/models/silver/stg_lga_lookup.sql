WITH source_data as (
    SELECT *
    FROM {{ (source('bronze', 'NSW_LGA_CODE')) }}
)

select *
from source_data