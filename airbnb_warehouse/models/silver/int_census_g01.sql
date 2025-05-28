WITH census_data_g01 AS (
    SELECT *
    FROM {{ source('bronze', 'census_g01_nsw_lga_2016') }}
)

SELECT
    CAST(REPLACE(lga_code_2016, 'LGA', '') AS INT) AS lga_code,
    {{ select_except(source('bronze', 'census_g01_nsw_lga_2016'), ['lga_code_2016']) }}
FROM census_data_g01
ORDER BY lga_code
