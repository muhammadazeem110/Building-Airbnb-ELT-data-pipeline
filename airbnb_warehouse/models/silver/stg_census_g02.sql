with census_g02_data as (select *
from {{ (source('bronze', 'Census_G02_NSW_LGA_2016')) }}
)

SELECT
        REPLACE(lga_code_2016, 'LGA', ''),
        {{ select_except(source('bronze', 'Census_G02_NSW_LGA_2016'), ['lga_code_2016']) }}
FROM census_g02_data