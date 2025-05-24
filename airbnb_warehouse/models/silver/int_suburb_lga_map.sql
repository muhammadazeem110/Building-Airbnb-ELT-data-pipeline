WITH lga_suburb as(
    SELECT * 
    FROM {{ source('bronze', 'nsw_lga_suburb') }}
)

SELECT INITCAP(lga_name) as lga_name, INITCAP(suburb_name) as suburb_name
FROM lga_suburb
ORDER BY lga_name