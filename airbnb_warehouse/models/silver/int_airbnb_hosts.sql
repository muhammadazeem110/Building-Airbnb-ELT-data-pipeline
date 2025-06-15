{% set coalesced_columns = [
    ("host_name", "'unknown'"),
    ("host_neighbourhood", "'null'")
] %}


WITH airbnb_data AS (
    SELECT host_id, host_name, host_neighbourhood, host_since, host_is_superhost, scraped_date
    FROM {{ source('bronze', 'airbnb') }}
),

ranked_hosts AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY host_id
               ORDER BY scraped_date DESC
           ) AS row_num
    FROM airbnb_data
    WHERE host_id IS NOT NULL
)

SELECT
    host_id,
    
    {% for col, default in coalesced_columns %}
        COALESCE(NULLIF({{ col }}, ''), {{ default }}) AS {{ col }}{% if not loop.last %},{% endif %}
    {% endfor %},

    host_since,
    host_is_superhost
FROM ranked_hosts
where row_num = 1
ORDER BY host_id