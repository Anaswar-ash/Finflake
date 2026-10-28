-- Mart: Journal Entry Fact Table
-- The detailed transaction-level fact table
-- Every report should be traceable back to these entries

with enriched as (
    select * from {{ ref('int_journal_entries_enriched') }}
)

select
    -- Surrogate key
    {{ dbt_utils.generate_surrogate_key(['journal_id', 'entry_line']) }} as journal_entry_key,

    -- Keys
    journal_id,
    entry_line,

    -- Dates
    posting_date,
    fiscal_period,
    fiscal_year,
    fiscal_month,

    -- Dimensions
    entity_code,
    entity_name,
    country,
    consolidation_group,
    account_code,
    account_name,
    account_type,
    statement_type,
    cost_centre_code,
    cost_centre_name,
    department,

    -- Measures
    debit_amount,
    credit_amount,
    net_amount,
    currency_code,

    -- Metadata
    description,
    journal_type,
    source_system,
    posted_by,
    is_reversed,
    is_late_posting,
    is_restatement,
    is_cross_period_posting

from enriched
