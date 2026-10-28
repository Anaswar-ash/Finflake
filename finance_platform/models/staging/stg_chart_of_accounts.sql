-- Staging: Chart of Accounts
-- Cleans and standardises the raw chart of accounts data

with source as (
    select * from {{ source('raw', 'RAW_CHART_OF_ACCOUNTS') }}
),

staged as (
    select
        trim(account_code)                          as account_code,
        trim(account_name)                          as account_name,
        upper(trim(account_type))                   as account_type,
        trim(account_subtype)                       as account_subtype,
        case
            when lower(is_control) in ('true', '1', 'yes') then true
            else false
        end                                         as is_control_account,
        nullif(trim(parent_account), '')             as parent_account_code,

        -- Derived: Balance sheet vs P&L classification
        case
            when upper(trim(account_type)) in ('ASSET', 'LIABILITY', 'EQUITY')
                then 'BALANCE_SHEET'
            when upper(trim(account_type)) in ('REVENUE', 'EXPENSE')
                then 'PROFIT_AND_LOSS'
            else 'UNKNOWN'
        end                                         as statement_type,

        -- Derived: Natural balance direction
        case
            when upper(trim(account_type)) in ('ASSET', 'EXPENSE')
                then 'DEBIT'
            when upper(trim(account_type)) in ('LIABILITY', 'EQUITY', 'REVENUE')
                then 'CREDIT'
            else 'UNKNOWN'
        end                                         as natural_balance

    from source
    where account_code is not null
)

select * from staged
