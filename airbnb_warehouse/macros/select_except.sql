{% macro select_except(ref_relation, exclude_columns=[]) %}
  {% set columns = adapter.get_columns_in_relation(ref_relation) %}
  {% set selected = [] %}
  {% for col in columns %}
    {% if col.name not in exclude_columns %}
      {% do selected.append(col.name) %}
    {% endif %}
  {% endfor %}
  {{ selected | join(', ') }}
{% endmacro %}
