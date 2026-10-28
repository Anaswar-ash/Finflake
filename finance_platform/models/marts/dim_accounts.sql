-- Mart: Account Dimension
-- Conformed dimension for all reporting

with accounts as (
    select * from {{ ref('stg_chart_of_accounts') }}
)

select
    account_code,
    account_name,
    account_type,
    account_subtype,
    statement_type,
    natural_balance,
    is_control_account,
    parent_account_code,

    -- Display ordering
    case account_type
        when 'ASSET'      then 1
        when 'LIABILITY'   then 2
        when 'EQUITY'      then 3
        when 'REVENUE'     then 4
        when 'EXPENSE'     then 5
        else 9
    end as type_sort_order

from accounts
