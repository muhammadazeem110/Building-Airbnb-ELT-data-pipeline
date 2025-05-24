WITH nsw_lga_code as (
    SELECT *
    FROM {{ source('bronze', 'nsw_lga_code') }}
)

select *
from nsw_lga_code
order by lga_code