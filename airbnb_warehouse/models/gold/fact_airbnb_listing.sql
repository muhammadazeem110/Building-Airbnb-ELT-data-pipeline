WITH fact_listing AS (
    SELECT
        listing.listing_sk,
        host.host_sk,
        lga.lga_sk,

        listing.scraped_date,
        snap_listing.price,
        listing.availability_30,

        reviews.number_of_reviews,
        reviews.review_scores_rating,
        reviews.review_scores_accuracy,
        reviews.review_scores_cleanliness,
        reviews.review_scores_checkin,
        reviews.review_scores_communication,
        reviews.review_scores_value,

        CASE
            WHEN listing.has_availability = TRUE THEN 1 ELSE 0
        END AS active_listing

    FROM {{ ref("dim_listing") }} AS listing
    JOIN {{ ref("dim_host") }} AS host
        ON host.host_id = listing.host_id
    JOIN {{ ref("snap_listings") }} AS snap_listing
        ON listing.listing_id = snap_listing.listing_id and listing.scraped_date = snap_listing.scraped_date
    JOIN {{ ref("int_airbnb_reviews") }} AS reviews
        ON listing.listing_id = reviews.listing_id and reviews.scraped_date = listing.scraped_date
    JOIN {{ ref("dim_lga") }} AS lga
        ON listing.listing_neighbourhood = lga.lga_name
)

SELECT 
    *,
    CASE
        WHEN active_listing = 1 THEN (30 - availability_30)
        ELSE NULL
    END AS number_of_stays,
    
    CASE
        WHEN active_listing = 1 THEN (30 - availability_30) * price
        ELSE NULL
    END AS estimated_revenue
FROM fact_listing
