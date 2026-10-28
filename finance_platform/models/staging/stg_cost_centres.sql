-- Staging: Cost Centres
-- Cleans and standardises cost centre master data

with source as (
    select * from {{ source('raw', 'RAW_COST_CENTRES') }}
),

staged as (
    select
        trim(cost_centre_code)      as cost_centre_code,
        trim(cost_centre_name)      as cost_centre_name,
        trim(department)            as department,
        trim(responsible_person)    as responsible_person
    from source
    where cost_centre_code is not null
)

select * from staged
