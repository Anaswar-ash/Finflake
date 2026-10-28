-- Mart: Balance Sheet
-- Cumulative balances by entity — Assets = Liabilities + Equity

with trial_balance as (
    select * from {{ ref('int_trial_balance') }}
    where statement_type = 'BALANCE_SHEET'
),

balance_sheet as (
    select
        fiscal_period,
        fiscal_year,
        fiscal_month,
        entity_code,
        entity_name,

        -- Assets (debit-normal)
        sum(case when account_type = 'ASSET'
            then balance else 0 end)                        as total_assets,

        -- Liabilities (credit-normal, so negate)
        sum(case when account_type = 'LIABILITY'
            then -balance else 0 end)                       as total_liabilities,

        -- Equity (credit-normal, so negate)
        sum(case when account_type = 'EQUITY'
            then -balance else 0 end)                       as total_equity,

        -- Subtotals
        sum(case when account_subtype = 'Current Asset'
            then balance else 0 end)                        as current_assets,
        sum(case when account_subtype in ('Fixed Asset', 'Non-Current Asset')
            then balance else 0 end)                        as non_current_assets,
        sum(case when account_subtype = 'Contra Asset'
            then balance else 0 end)                        as contra_assets,
        sum(case when account_subtype = 'Current Liability'
            then -balance else 0 end)                       as current_liabilities,
        sum(case when account_subtype = 'Non-Current Liability'
            then -balance else 0 end)                       as non_current_liabilities

    from trial_balance
    group by 1, 2, 3, 4, 5
)

select
    *,

    -- Accounting equation check: Assets = Liabilities + Equity
    total_assets - (total_liabilities + total_equity)        as balance_check,

    -- Liquidity ratio: Current Assets / Current Liabilities
    case when current_liabilities > 0
        then round(current_assets / current_liabilities, 2)
        else null
    end                                                     as current_ratio

from balance_sheet
