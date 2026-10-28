-- Intermediate: Enriched Journal Entries
-- Joins journal entries with all dimension tables
-- This is the single source of truth for all downstream reporting

with journals as (
    select * from {{ ref('stg_gl_journal_entries') }}
),

accounts as (
    select * from {{ ref('stg_chart_of_accounts') }}
),

entities as (
    select * from {{ ref('stg_legal_entities') }}
),

cost_centres as (
    select * from {{ ref('stg_cost_centres') }}
),

enriched as (
    select
        -- Journal data
        j.journal_id,
        j.entry_line,
        j.posting_date,
        j.fiscal_period,
        j.fiscal_year,
        j.fiscal_month,
        j.description,
        j.debit_amount,
        j.credit_amount,
        j.net_amount,
        j.currency_code,
        j.source_system,
        j.journal_type,
        j.posted_by,
        j.is_reversed,
        j.is_late_posting,
        j.is_restatement,
        j.is_cross_period_posting,

        -- Account dimensions
        j.account_code,
        a.account_name,
        a.account_type,
        a.account_subtype,
        a.statement_type,
        a.natural_balance,
        a.is_control_account,

        -- Entity dimensions
        j.entity_code,
        e.entity_name,
        e.country,
        e.consolidation_group,

        -- Cost centre dimensions
        j.cost_centre_code,
        cc.cost_centre_name,
        cc.department,
        cc.responsible_person

    from journals j
    left join accounts a on j.account_code = a.account_code
    left join entities e on j.entity_code = e.entity_code
    left join cost_centres cc on j.cost_centre_code = cc.cost_centre_code
)

select * from enriched
