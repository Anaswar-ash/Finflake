-- Finance utility macros

{% macro fiscal_quarter(month_column) %}
    case
        when {{ month_column }} between 1 and 3 then 'Q1'
        when {{ month_column }} between 4 and 6 then 'Q2'
        when {{ month_column }} between 7 and 9 then 'Q3'
        when {{ month_column }} between 10 and 12 then 'Q4'
    end
{% endmacro %}

{% macro is_balance_sheet_account(account_type_column) %}
    {{ account_type_column }} in ('ASSET', 'LIABILITY', 'EQUITY')
{% endmacro %}

{% macro is_pnl_account(account_type_column) %}
    {{ account_type_column }} in ('REVENUE', 'EXPENSE')
{% endmacro %}
