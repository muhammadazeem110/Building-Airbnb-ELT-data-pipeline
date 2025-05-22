WITH source_data as(
    SELECT * 
    FROM {{ (source('bronze', 'NSW_LGA_SUBURB')) }}
)

SELECT INITCAP(lga_name) as lga_name, INITCAP(suburb_name) as suburb_name
FROM source_data