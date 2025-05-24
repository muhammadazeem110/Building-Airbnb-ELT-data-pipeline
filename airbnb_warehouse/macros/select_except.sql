{% macro select_except(table, exclude_columns) %}
    {%- set columns = adapter.get_columns_in_relation(table) -%}
    {%- set selected = [] -%}
    {%- for col in columns if col.name not in exclude_columns -%}
        {%- do selected.append(col.name) -%}
    {%- endfor -%}
    {{ selected | join(', ') }}
{% endmacro %}
