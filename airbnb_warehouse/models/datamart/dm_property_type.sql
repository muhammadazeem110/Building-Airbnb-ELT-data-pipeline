SELECT
    property_type,
    room_type,
    accommodates,
    DATE_TRUNC('month', scraped_date) AS month,

    -- Active listing rate
    ROUND(SUM(is_available) * 100.0 / COUNT(is_available), 2) AS active_listing_rate,

    -- Minimum, maximum, median, and average price for active listings
    MIN(CASE WHEN is_available = 1 THEN price END) AS minimum_price,
    MAX(CASE WHEN is_available = 1 THEN price END) AS maximum_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CASE WHEN is_available = 1 THEN price END) AS median_price,
    ROUND(AVG(CASE WHEN is_available = 1 THEN price END), 2) AS average_price,

    -- Number of distinct hosts
    COUNT(DISTINCT dh.host_id) AS distinct_host_id,

    -- Superhost rate
    ROUND(
        COUNT(DISTINCT CASE WHEN host_is_superhost THEN dh.host_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT dh.host_id), 0), 
    2) AS superhost_rate,

    -- Average of review_scores_rating for active listings
    ROUND(AVG(CASE WHEN is_available = 1 THEN review_scores_rating END), 2) AS avg_scores_rating,

    -- Percentage change for active listings
    ROUND(
        (SUM(is_available) - LAG(SUM(is_available)) OVER (PARTITION BY dl.listing_neighbourhood ORDER BY DATE_TRUNC('month', scraped_date))) /
        NULLIF(LAG(SUM(is_available)) OVER (PARTITION BY dl.listing_neighbourhood ORDER BY DATE_TRUNC('month', scraped_date)), 0) * 100,
    2) AS percent_chg_active,

    -- Total number of stays
    SUM(number_of_stays) AS tot_no_of_stays,

    -- Average estimated revenue per active listing
    ROUND(AVG(estimated_revenue),2)  AS avg_estimated_revenue

FROM {{ref("fact_airbnb_listing")}} AS fal
JOIN {{ref("dim_listing")}} AS dl
    ON fal.listing_sk = dl.listing_sk
JOIN {{ref("dim_host")}} AS dh
    ON fal.host_sk = dh.host_sk

GROUP BY property_type, room_type, accommodates, dl.listing_neighbourhood, DATE_TRUNC('month', scraped_date)
ORDER BY month

