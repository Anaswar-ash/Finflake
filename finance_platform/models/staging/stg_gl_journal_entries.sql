-- Staging: GL Journal Entries
-- Cleans, standardises, and flags data quality issues
-- This is the most critical staging model — every financial report depends on it

with source as (
    select * from {{ source('raw', 'RAW_GL_JOURNAL_ENTRIES') }}
),

staged as (
    select
        -- Keys
        trim(journal_id)                            as journal_id,
        entry_line,

        -- Dates
        posting_date,
        trim(period)                                as fiscal_period,
        year(posting_date)                          as fiscal_year,
        month(posting_date)                         as fiscal_month,

        -- Dimensions
        trim(entity_code)                           as entity_code,
        trim(account_code)                          as account_code,
        trim(cost_centre_code)                      as cost_centre_code,

        -- Amounts (ensure non-negative)
        coalesce(abs(debit_amount), 0)              as debit_amount,
        coalesce(abs(credit_amount), 0)             as credit_amount,
        coalesce(abs(debit_amount), 0)
          - coalesce(abs(credit_amount), 0)         as net_amount,

        -- Metadata
        trim(description)                           as description,
        upper(trim(currency))                       as currency_code,
        trim(source_system)                         as source_system,
        upper(trim(journal_type))                   as journal_type,
        created_at,
        trim(posted_by)                             as posted_by,
        case
            when lower(is_reversed) in ('true', '1', 'yes') then true
            else false
        end                                         as is_reversed,

        -- Data quality flags
        case
            when upper(trim(journal_type)) = 'LATE_POSTING' then true
            else false
        end                                         as is_late_posting,

        case
            when upper(trim(journal_type)) = 'RESTATEMENT' then true
            else false
        end                                         as is_restatement,

        case
            when posting_date != try_to_date(trim(period) || '-01')
                 and month(posting_date) != month(try_to_date(trim(period) || '-01'))
            then true
            else false
        end                                         as is_cross_period_posting

    from source
    where journal_id is not null
)

select * from staged
