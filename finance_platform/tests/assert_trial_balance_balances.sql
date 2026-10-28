-- RECONCILIATION TEST: Trial balance must balance per period per entity
-- Total debits across ALL accounts must equal total credits.
-- If this fails, the books don't balance — a critical audit finding.

with period_totals as (
    select
        fiscal_period,
        entity_code,
        sum(total_debits)   as period_debits,
        sum(total_credits)  as period_credits,
        abs(sum(total_debits) - sum(total_credits)) as variance
    from {{ ref('fct_trial_balance') }}
    group by fiscal_period, entity_code
)

-- Return rows that FAIL
select
    fiscal_period,
    entity_code,
    period_debits,
    period_credits,
    variance
from period_totals
where variance > 0.01
