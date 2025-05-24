WITH airbnb_data AS (
    SELECT *
    FROM {{ source('bronze', 'airbnb_05_2020') }}
)

SELECT
    airbnb.scrape_id,
    airbnb.scraped_date,
    airbnb.listing_id,
    airbnb.host_id,
    lga.lga_code,
    airbnb.listing_neighbourhood,
    airbnb.property_type,
    airbnb.room_type,
    airbnb.accommodates,
    airbnb.price,
    airbnb.has_availability,
    airbnb.availability_30
FROM airbnb_data airbnb
JOIN {{ ref('int_lga_lookup') }} lga
    ON airbnb.listing_neighbourhood = lga.lga_name
ORDER BY airbnb.scraped_date