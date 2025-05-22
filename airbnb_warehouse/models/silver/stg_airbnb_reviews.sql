WITH airbnb_data AS (
    SELECT *
    From {{ source('bronze', 'airbnb_05_2020') }}
)

{% set coalesced_columns = [
    ("number_of_reviews", 0),
    ("review_scores_rating", 0),
    ("review_scores_accuracy", 0),
    ("review_scores_cleanliness", 0),
    ("review_scores_checkin", 0),
    ("review_scores_communication", 0),
    ("review_scores_value", 0),
] %}

SELECT
    listig_id,
    {% for col, default in coalesced_columns %}
        COALESCE(NULLIF({{ col }}, ''), {{ default }}) as {{ col }} {% if not loop.last %}, {% endif %}
    {% endfor %}
From airbnb_data