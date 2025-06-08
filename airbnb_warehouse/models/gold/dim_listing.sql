{{ config(
    indexes = [
        {"columns": ["listing_sk"]}
    ]
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['listing_id', 'scraped_date', 'dbt_valid_from']) }} AS listing_sk,
    listing_id,
    host_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    availability_30,
    has_availability,
    dbt_updated_at AS updated_at,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE 
        WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE
    END AS is_current
FROM {{ ref('snap_listings') }}