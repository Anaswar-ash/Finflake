-- Mart: Data Quality Dashboard
-- Monitors platform health — feeds the Data Quality page in Power BI

with journals as (
    select * from {{ ref('stg_gl_journal_entries') }}
),

quality_by_period as (
    select
        fiscal_period,
        entity_code,

        count(distinct journal_id)                                     as total_journals,
        count(*)                                                       as total_lines,

        -- Journal type breakdown
        count(distinct case when journal_type = 'STANDARD' then journal_id end)    as standard_journals,
        count(distinct case when journal_type = 'LATE_POSTING' then journal_id end) as late_posting_journals,
        count(distinct case when journal_type = 'RESTATEMENT' then journal_id end)  as restatement_journals,
        count(distinct case when journal_type = 'ADJUSTMENT' then journal_id end)   as adjustment_journals,

        -- Reversed entries
        count(distinct case when is_reversed then journal_id end)       as reversed_journals,

        -- Cross-period postings
        count(distinct case when is_cross_period_posting then journal_id end) as cross_period_journals,

        -- Balance check per journal
        count(distinct case
            when journal_id in (
                select journal_id
                from {{ ref('stg_gl_journal_entries') }}
                group by journal_id
                having abs(sum(debit_amount) - sum(credit_amount)) > 0.01
            ) then journal_id
        end)                                                           as unbalanced_journals,

        -- Amounts
        sum(debit_amount)                                              as total_debits,
        sum(credit_amount)                                             as total_credits,
        abs(sum(debit_amount) - sum(credit_amount))                    as debit_credit_variance

    from journals
    group by 1, 2
)

select
    *,
    round(late_posting_journals * 100.0 / nullif(total_journals, 0), 2)   as late_posting_pct,
    round(restatement_journals * 100.0 / nullif(total_journals, 0), 2)    as restatement_pct,
    case when unbalanced_journals = 0 then 'PASS' else 'FAIL' end         as balance_test_status
from quality_by_period
