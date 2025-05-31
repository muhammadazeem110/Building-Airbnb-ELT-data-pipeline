WITH airbnb_data AS (
    SELECT *
    FROM {{ source('bronze', 'airbnb_05_2020') }}
)

{% set coalesced_columns = [
    ("host_name", "'unknown'"),
    ("host_neighbourhood", "'null'")
] %}

SELECT DISTINCT
    host_id,
    {% for col, default in coalesced_columns %}
        COALESCE(NULLIF({{ col }}, ''), {{ default }}) AS {{ col }}{% if not loop.last %},{% endif %}
    {% endfor %},
    COALESCE(host_since, null) as host_since,
    host_is_superhost
FROM airbnb_data
ORDER BY host_id