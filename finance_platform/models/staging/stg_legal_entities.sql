-- Staging: Legal Entities
-- Cleans and standardises legal entity master data

with source as (
    select * from {{ source('raw', 'RAW_LEGAL_ENTITIES') }}
),

staged as (
    select
        trim(entity_code)           as entity_code,
        trim(entity_name)           as entity_name,
        trim(country)               as country,
        upper(trim(currency))       as currency_code,
        trim(consolidation_group)   as consolidation_group
    from source
    where entity_code is not null
)

select * from staged
