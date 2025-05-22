with census_g01_data as (
    SELECT * FROM {{source('bronze', 'Census_G01_NSW_LGA_2016')}}
)

select
        REPLACE(LGA_CODE_2016, 'LGA', '') as lga_code,
        {{ select_except(source('bronze', 'Census_G01_NSW_LGA_2016'), ['LGA_CODE_2016']) }}
FROM census_g01_data