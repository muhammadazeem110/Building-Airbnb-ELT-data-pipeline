WITH airbnb_data AS (
    SELECT *
    FROM {{ source('bronze', 'airbnb_05_2020') }}
)

SELECT
    listing_id,
    host_id,
    scrape_id,
    scraped_date,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    price,
    has_availability,
    availability_30
FROM airbnb_data