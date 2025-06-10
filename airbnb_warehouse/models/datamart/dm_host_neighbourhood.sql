SELECT
    lga_code as host_neighbourhood_lga,
    DATE_TRUNC('month', scraped_date) as month,

    -- Number of distinct host
    COUNT(DISTINCT host_id) as host_id,

    -- Estimated Revenue
    ROUND(SUM(estimated_revenue), 2) as estimated_revenue,

    -- Estimated Revenue per host (distinct)
    ROUND(SUM(estimated_revenue) / NULLIF(COUNT(DISTINCT host_id), 0), 2) AS revenue_per_host
FROM {{ref("fact_airbnb_listing")}} as fal
JOIN {{ref("dim_lga")}} as lga
    ON fal.lga_sk = lga.lga_sk
JOIN {{ref("dim_host")}} as host
    ON fal.host_sk = host.host_sk
GROUP BY host_neighbourhood_lga, DATE_TRUNC('month', scraped_date)