WITH census_data_g01 as (
    SELECT *
    FROM {{ source('bronze', 'census_g01_nsw_lga_2016') }}
)

select
    replace(lga_code_2016, 'LGA', '') as lga_code,
    {{ select_except(source('bronze', 'census_g01_nsw_lga_2016'), ['lga_code_2016']) }}
from census_data_g01
order by lga_code