WITH airbnb_data AS (
    SELECT listing_id, number_of_reviews, review_scores_rating, review_scores_accuracy, review_scores_cleanliness, review_scores_checkin, review_scores_communication, review_scores_value
    From {{ source('bronze', 'airbnb') }}
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
    listing_id,
    {% for col, default in coalesced_columns %}
        COALESCE({{ col }},{{ default }}) as {{ col }} {% if not loop.last %}, {% endif %}
    {% endfor %}
From airbnb_data
ORDER By listing_id