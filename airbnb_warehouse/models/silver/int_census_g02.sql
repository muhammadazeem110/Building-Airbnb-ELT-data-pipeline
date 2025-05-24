with census_data_g02 as (select *
from {{ source('bronze', 'census_g02_nsw_lga_2016') }}
)

SELECT
        REPLACE(lga_code_2016, 'LGA', '') as lga_code,
        {{ select_except(source('bronze', 'census_g02_nsw_lga_2016'), ['lga_code_2016']) }}
FROM census_data_g02
ORDER BY lga_code