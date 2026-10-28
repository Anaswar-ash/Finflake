-- ============================================
-- FINFLAKE: RAW LAYER TABLE DEFINITIONS
-- Run AFTER 01_setup.sql
-- ============================================

USE DATABASE FINANCE_PLATFORM;
USE SCHEMA RAW;
USE WAREHOUSE FINANCE_WH;

-- Chart of Accounts
CREATE OR REPLACE TABLE RAW_CHART_OF_ACCOUNTS (
    account_code    VARCHAR(10),
    account_name    VARCHAR(100),
    account_type    VARCHAR(20),
    account_subtype VARCHAR(50),
    is_control      VARCHAR(10),
    parent_account  VARCHAR(10)
);

-- Legal Entities
CREATE OR REPLACE TABLE RAW_LEGAL_ENTITIES (
    entity_code         VARCHAR(10),
    entity_name         VARCHAR(100),
    country             VARCHAR(50),
    currency            VARCHAR(3),
    consolidation_group VARCHAR(50)
);

-- Cost Centres
CREATE OR REPLACE TABLE RAW_COST_CENTRES (
    cost_centre_code    VARCHAR(10),
    cost_centre_name    VARCHAR(100),
    department          VARCHAR(50),
    responsible_person  VARCHAR(100)
);

-- GL Journal Entries (the core transaction table)
CREATE OR REPLACE TABLE RAW_GL_JOURNAL_ENTRIES (
    journal_id          VARCHAR(20),
    entry_line          INT,
    posting_date        DATE,
    period              VARCHAR(7),
    entity_code         VARCHAR(10),
    account_code        VARCHAR(10),
    cost_centre_code    VARCHAR(10),
    description         VARCHAR(500),
    debit_amount        DECIMAL(18,2),
    credit_amount       DECIMAL(18,2),
    currency            VARCHAR(3),
    source_system       VARCHAR(50),
    journal_type        VARCHAR(20),
    created_at          TIMESTAMP,
    posted_by           VARCHAR(50),
    is_reversed         VARCHAR(10)
);

SELECT 'Raw tables created successfully' AS status;
