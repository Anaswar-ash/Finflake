-- Mart: Profit & Loss Summary
-- Monthly P&L by entity — the report the CFO reads first

with trial_balance as (
    select * from {{ ref('int_trial_balance') }}
    where statement_type = 'PROFIT_AND_LOSS'
),

pnl as (
    select
        fiscal_period,
        fiscal_year,
        fiscal_month,
        entity_code,
        entity_name,

        -- Revenue (credit-normal: credits increase revenue)
        sum(case when account_type = 'REVENUE'
            then total_credits - total_debits else 0 end)   as total_revenue,

        -- Expenses (debit-normal: debits increase expenses)
        sum(case when account_type = 'EXPENSE'
            then total_debits - total_credits else 0 end)   as total_expenses,

        -- COGS specifically
        sum(case when account_code = '5000'
            then total_debits - total_credits else 0 end)   as cost_of_goods_sold,

        -- Operating expenses (all expenses minus COGS)
        sum(case when account_type = 'EXPENSE' and account_code != '5000'
            then total_debits - total_credits else 0 end)   as operating_expenses,

        -- Data quality
        sum(late_posting_count)                              as late_posting_count,
        sum(restatement_count)                               as restatement_count

    from trial_balance
    group by 1, 2, 3, 4, 5
)

select
    *,
    total_revenue - cost_of_goods_sold                      as gross_profit,
    total_revenue - total_expenses                          as net_income,

    -- Margins
    case when total_revenue > 0
        then round((total_revenue - cost_of_goods_sold) / total_revenue * 100, 2)
        else 0
    end                                                     as gross_margin_pct,

    case when total_revenue > 0
        then round((total_revenue - total_expenses) / total_revenue * 100, 2)
        else 0
    end                                                     as net_margin_pct

from pnl
