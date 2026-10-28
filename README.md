# Finflake — Finance Data Platform

> A production-grade finance data platform built with **Snowflake**, **dbt**, and **Power BI** — demonstrating how modern CFO organisations transform raw ERP data into governed, reconciled management reporting.

![Architecture](docs/architecture.png)

## 🏛️ Architecture

```
┌──────────────┐     ┌──────────────────────────────────────┐     ┌──────────────┐
│              │     │         SNOWFLAKE                     │     │              │
│  ERP Source  │────▶│  RAW ──▶ CONFORMED ──▶ CURATED       │────▶│   Power BI   │
│  (Python)    │     │  (dbt staging)  (dbt marts)          │     │  Dashboards  │
│              │     │         ▲                             │     │              │
└──────────────┘     │    Reconciliation Tests (dbt test)    │     └──────────────┘
                     └──────────────────────────────────────┘
```

### Three-Layer Data Architecture

| Layer | Schema | Purpose | Governance |
|-------|--------|---------|------------|
| **Raw (Bronze)** | `RAW` | Untouched source data — exact copy from ERP | Immutable, append-only |
| **Conformed (Silver)** | `CONFORMED` | Cleaned, standardised, joined | Data engineering owns |
| **Curated (Gold)** | `CURATED` | Business-ready reporting tables | Finance analysts consume |

## 📊 What This Platform Delivers

### Management Reports
- **Profit & Loss** — Monthly by entity with gross/net margins
- **Balance Sheet** — Assets = Liabilities + Equity, with current ratio
- **Trial Balance** — Period-level account balances with reconciliation status

### Data Quality Monitoring
- Late posting detection and tracking
- Restatement flagging
- Cross-period posting alerts
- Debit/credit balance verification per journal

### Reconciliation Tests (Automated)
| Test | What It Proves |
|------|----------------|
| `assert_debits_equal_credits` | Every journal follows double-entry bookkeeping |
| `assert_trial_balance_balances` | Books balance per period per entity |
| `assert_entity_reconciliation` | No data lost between staging and mart layers |

## 🗂️ Finance Master Data

The platform models core enterprise structure:

- **Chart of Accounts** — 40+ accounts across Assets, Liabilities, Equity, Revenue, Expenses with parent-child hierarchy
- **Legal Entities** — 3 entities (UK/US/EU) with multi-currency support (GBP/USD/EUR)
- **Cost Centres** — 7 departments for internal cost allocation
- **Journal Types** — Standard, Late Posting, Restatement, Adjustment — handling the messy reality of ERP data

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Snowflake** | Cloud data warehouse — storage, compute, governance |
| **dbt Core** | Data transformation, testing, documentation, lineage |
| **Python** | Data generation (simulating ERP output) |
| **Power BI** | Management reporting dashboards |
| **SQL** | All transformations and tests |
| **Git** | Version control and audit trail |

## 🚀 Getting Started

### Prerequisites
- Python 3.11+
- Snowflake account ([free trial](https://signup.snowflake.com/))
- dbt Core (`pip install dbt-snowflake`)
- Power BI Desktop

### 1. Generate Data
```bash
python scripts/generate_gl_data.py
```
Creates 4 CSV files in `data/` simulating ERP output.

### 2. Setup Snowflake
Run the SQL scripts in order in Snowsight:
```
snowflake/01_setup.sql           # Database, schemas, warehouse
snowflake/02_create_raw_tables.sql  # Raw layer table definitions
```
Then upload CSVs via Snowsight's Load Data UI.

### 3. Configure dbt
```bash
# Copy the template to your dbt profiles directory
cp finance_platform/profiles_template.yml ~/.dbt/profiles.yml
# Edit with your Snowflake credentials
```

### 4. Run dbt
```bash
cd finance_platform
dbt deps                  # Install packages
dbt run                   # Build all models
dbt test                  # Run reconciliation tests
dbt docs generate && dbt docs serve  # View lineage
```

### 5. Connect Power BI
1. Get Data → Snowflake
2. Connect to `CURATED` schema
3. Import fact and dimension tables

## 📁 Project Structure

```
Finflake/
├── README.md
├── scripts/
│   └── generate_gl_data.py        # ERP data simulator
├── data/                           # Generated CSVs (gitignored)
├── snowflake/
│   ├── 01_setup.sql               # Environment setup
│   └── 02_create_raw_tables.sql   # Raw table definitions
├── finance_platform/               # dbt project
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── profiles_template.yml
│   ├── models/
│   │   ├── staging/               # Raw → Cleaned
│   │   ├── intermediate/          # Business logic
│   │   └── marts/                 # Reporting-ready
│   ├── tests/                     # Reconciliation tests
│   └── macros/                    # Finance utilities
└── docs/
    └── architecture.png
```

## 🔍 Key Design Decisions

1. **Three-layer architecture** — Standard medallion pattern for data governance and auditability
2. **dbt tests as reconciliation** — Automated proof that platform numbers agree with source
3. **Dirty data by design** — Late postings, restatements, and reversals simulate real ERP complexity
4. **Multi-entity support** — GBP/USD/EUR entities with consolidation group for group reporting
5. **Semantic consistency** — Margin, revenue, and expense definitions are calculated once in the mart layer

## 📜 License

MIT

## 👤 Author

**Anaswar (Ash) T** — [GitHub](https://github.com/Anaswar-ash) | [LinkedIn](https://linkedin.com/in/anaswar-ash)
