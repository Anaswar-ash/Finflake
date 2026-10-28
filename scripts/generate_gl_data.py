"""
Finflake — Finance Data Generator
Generates realistic GL journal data simulating an ERP system.
Outputs CSV files for loading into Snowflake.
"""

import csv
import random
import os
from datetime import datetime, timedelta
from pathlib import Path

random.seed(42)  # Reproducibility

DATA_DIR = Path(__file__).parent.parent / 'data'
DATA_DIR.mkdir(exist_ok=True)

# ============================================
# CHART OF ACCOUNTS
# ============================================
CHART_OF_ACCOUNTS = [
    # Assets (1000-1999)
    ('1000', 'Cash and Cash Equivalents', 'Asset', 'Current Asset', False, None),
    ('1010', 'Petty Cash', 'Asset', 'Current Asset', False, '1000'),
    ('1100', 'Accounts Receivable', 'Asset', 'Current Asset', True, None),
    ('1200', 'Inventory', 'Asset', 'Current Asset', False, None),
    ('1300', 'Prepaid Expenses', 'Asset', 'Current Asset', False, None),
    ('1500', 'Property Plant and Equipment', 'Asset', 'Fixed Asset', False, None),
    ('1510', 'Office Equipment', 'Asset', 'Fixed Asset', False, '1500'),
    ('1520', 'Computer Equipment', 'Asset', 'Fixed Asset', False, '1500'),
    ('1600', 'Accumulated Depreciation', 'Asset', 'Contra Asset', False, None),
    ('1700', 'Intangible Assets', 'Asset', 'Non-Current Asset', False, None),
    # Liabilities (2000-2999)
    ('2000', 'Accounts Payable', 'Liability', 'Current Liability', True, None),
    ('2100', 'Accrued Expenses', 'Liability', 'Current Liability', False, None),
    ('2200', 'VAT Payable', 'Liability', 'Current Liability', False, None),
    ('2300', 'Corporation Tax Payable', 'Liability', 'Current Liability', False, None),
    ('2400', 'Short Term Loans', 'Liability', 'Current Liability', False, None),
    ('2500', 'Deferred Revenue', 'Liability', 'Current Liability', False, None),
    ('2700', 'Long Term Debt', 'Liability', 'Non-Current Liability', False, None),
    ('2800', 'Pension Obligations', 'Liability', 'Non-Current Liability', False, None),
    # Equity (3000-3999)
    ('3000', 'Share Capital', 'Equity', 'Equity', False, None),
    ('3100', 'Retained Earnings', 'Equity', 'Equity', False, None),
    ('3200', 'Other Reserves', 'Equity', 'Equity', False, None),
    ('3300', 'Foreign Currency Translation Reserve', 'Equity', 'Equity', False, None),
    # Revenue (4000-4999)
    ('4000', 'Product Revenue', 'Revenue', 'Operating Revenue', False, None),
    ('4100', 'Service Revenue', 'Revenue', 'Operating Revenue', False, None),
    ('4200', 'Subscription Revenue', 'Revenue', 'Operating Revenue', False, None),
    ('4500', 'Interest Income', 'Revenue', 'Non-Operating Revenue', False, None),
    ('4600', 'Foreign Exchange Gains', 'Revenue', 'Non-Operating Revenue', False, None),
    ('4900', 'Other Income', 'Revenue', 'Non-Operating Revenue', False, None),
    # Expenses (5000-5999)
    ('5000', 'Cost of Goods Sold', 'Expense', 'Direct Cost', False, None),
    ('5100', 'Salaries and Wages', 'Expense', 'Personnel', False, None),
    ('5110', 'Employee Benefits', 'Expense', 'Personnel', False, '5100'),
    ('5120', 'Payroll Taxes', 'Expense', 'Personnel', False, '5100'),
    ('5200', 'Rent and Facilities', 'Expense', 'Operating Expense', False, None),
    ('5300', 'Marketing and Advertising', 'Expense', 'Operating Expense', False, None),
    ('5400', 'IT and Software', 'Expense', 'Operating Expense', False, None),
    ('5500', 'Professional Services', 'Expense', 'Operating Expense', False, None),
    ('5600', 'Depreciation Expense', 'Expense', 'Non-Cash', False, None),
    ('5700', 'Travel and Entertainment', 'Expense', 'Operating Expense', False, None),
    ('5800', 'Insurance', 'Expense', 'Operating Expense', False, None),
    ('5900', 'Foreign Exchange Losses', 'Expense', 'Non-Operating Expense', False, None),
    ('5950', 'Interest Expense', 'Expense', 'Non-Operating Expense', False, None),
    ('5990', 'Miscellaneous Expense', 'Expense', 'Operating Expense', False, None),
]

# ============================================
# LEGAL ENTITIES
# ============================================
LEGAL_ENTITIES = [
    ('ENT-UK', 'Finflake UK Ltd', 'United Kingdom', 'GBP', 'Finflake Group'),
    ('ENT-US', 'Finflake US Inc', 'United States', 'USD', 'Finflake Group'),
    ('ENT-EU', 'Finflake EU GmbH', 'Germany', 'EUR', 'Finflake Group'),
]

# ============================================
# COST CENTRES
# ============================================
COST_CENTRES = [
    ('CC-SALES', 'Sales Department', 'Sales', 'Sarah Mitchell'),
    ('CC-OPS', 'Operations', 'Operations', 'James Chen'),
    ('CC-FIN', 'Finance Department', 'Finance', 'Emma Thompson'),
    ('CC-IT', 'Information Technology', 'IT', 'Raj Patel'),
    ('CC-HR', 'Human Resources', 'HR', 'Lisa Wong'),
    ('CC-MKT', 'Marketing', 'Marketing', 'David Brown'),
    ('CC-EXEC', 'Executive Office', 'Executive', 'Michael Adams'),
]

# ============================================
# JOURNAL ENTRY TEMPLATES
# ============================================
JOURNAL_TEMPLATES = [
    # (description, debit_account, credit_account, min_amount, max_amount, cost_centres)
    ('Product sale - invoice raised', '1100', '4000', 5000, 150000, ['CC-SALES']),
    ('Service revenue - consulting', '1100', '4100', 2000, 50000, ['CC-SALES']),
    ('Subscription revenue - monthly', '1000', '4200', 500, 10000, ['CC-SALES']),
    ('Cash received from customer', '1000', '1100', 5000, 150000, ['CC-FIN']),
    ('Supplier payment - raw materials', '5000', '2000', 3000, 80000, ['CC-OPS']),
    ('Rent payment - office', '5200', '1000', 5000, 25000, ['CC-OPS']),
    ('Salary payment - monthly', '5100', '1000', 20000, 100000, ['CC-HR']),
    ('Employee benefits - insurance', '5110', '2100', 2000, 15000, ['CC-HR']),
    ('Payroll tax payment', '5120', '2200', 3000, 20000, ['CC-HR']),
    ('Marketing campaign spend', '5300', '2000', 1000, 30000, ['CC-MKT']),
    ('IT software licenses', '5400', '2000', 500, 15000, ['CC-IT']),
    ('Professional services - audit', '5500', '2000', 5000, 40000, ['CC-FIN']),
    ('Depreciation - monthly', '5600', '1600', 1000, 8000, ['CC-FIN']),
    ('Travel expenses - sales', '5700', '1000', 200, 5000, ['CC-SALES']),
    ('Insurance premium payment', '5800', '1000', 2000, 10000, ['CC-FIN']),
    ('Interest on loan', '5950', '1000', 500, 5000, ['CC-FIN']),
    ('Interest income received', '1000', '4500', 100, 2000, ['CC-FIN']),
    ('VAT payment to HMRC', '2200', '1000', 5000, 30000, ['CC-FIN']),
    ('Corporation tax provision', '2300', '1000', 10000, 50000, ['CC-FIN']),
    ('Equipment purchase', '1520', '1000', 1000, 20000, ['CC-IT']),
    ('Accounts payable settlement', '2000', '1000', 3000, 80000, ['CC-FIN']),
    ('Prepaid expense - annual licence', '1300', '1000', 2000, 12000, ['CC-IT']),
    ('Accrued expenses - utilities', '5990', '2100', 500, 3000, ['CC-OPS']),
    ('FX gain on USD receivable', '1100', '4600', 100, 5000, ['CC-FIN']),
    ('FX loss on EUR payable', '5900', '2000', 100, 5000, ['CC-FIN']),
    ('Deferred revenue recognition', '2500', '4100', 1000, 20000, ['CC-SALES']),
]

POSTED_BY = ['system_auto', 'e.thompson', 'j.chen', 's.mitchell', 'r.patel', 'finance_batch']


def generate_journal_id(seq: int) -> str:
    return f'JNL-2025-{seq:05d}'


def generate_journals() -> list[dict]:
    """Generate ~2000 GL journal entries across 12 months."""
    entries = []
    seq = 1
    base_date = datetime(2025, 1, 1)

    for month in range(1, 13):
        # Standard journals: ~140 per month
        n_journals = random.randint(130, 155)
        for _ in range(n_journals):
            template = random.choice(JOURNAL_TEMPLATES)
            desc, debit_acct, credit_acct, min_amt, max_amt, cc_list = template
            amount = round(random.uniform(min_amt, max_amt), 2)
            entity = random.choice(LEGAL_ENTITIES)
            cost_centre = random.choice(cc_list)
            day = random.randint(1, 28)
            posting_date = datetime(2025, month, day)
            period = posting_date.strftime('%Y-%m')
            jnl_id = generate_journal_id(seq)

            # Debit line
            entries.append({
                'journal_id': jnl_id,
                'entry_line': 1,
                'posting_date': posting_date.strftime('%Y-%m-%d'),
                'period': period,
                'entity_code': entity[0],
                'account_code': debit_acct,
                'cost_centre_code': cost_centre,
                'description': desc,
                'debit_amount': amount,
                'credit_amount': 0.00,
                'currency': entity[3],
                'source_system': 'ERP_CORE',
                'journal_type': 'STANDARD',
                'created_at': posting_date.strftime('%Y-%m-%d %H:%M:%S'),
                'posted_by': random.choice(POSTED_BY),
                'is_reversed': False,
            })
            # Credit line
            entries.append({
                'journal_id': jnl_id,
                'entry_line': 2,
                'posting_date': posting_date.strftime('%Y-%m-%d'),
                'period': period,
                'entity_code': entity[0],
                'account_code': credit_acct,
                'cost_centre_code': cost_centre,
                'description': desc,
                'debit_amount': 0.00,
                'credit_amount': amount,
                'currency': entity[3],
                'source_system': 'ERP_CORE',
                'journal_type': 'STANDARD',
                'created_at': posting_date.strftime('%Y-%m-%d %H:%M:%S'),
                'posted_by': random.choice(POSTED_BY),
                'is_reversed': False,
            })
            seq += 1

        # ----- DIRTY DATA -----

        # Late postings (5-8 per month): posted in THIS month but belong to a PREVIOUS month
        if month >= 3:
            for _ in range(random.randint(5, 8)):
                template = random.choice(JOURNAL_TEMPLATES)
                desc, debit_acct, credit_acct, min_amt, max_amt, cc_list = template
                amount = round(random.uniform(min_amt, max_amt), 2)
                entity = random.choice(LEGAL_ENTITIES)
                cost_centre = random.choice(cc_list)
                original_month = random.randint(1, month - 1)
                posting_date = datetime(2025, month, random.randint(1, 10))
                original_period = f'2025-{original_month:02d}'
                jnl_id = generate_journal_id(seq)

                for line, (acct, dr, cr) in enumerate([
                    (debit_acct, amount, 0.00),
                    (credit_acct, 0.00, amount)
                ], 1):
                    entries.append({
                        'journal_id': jnl_id,
                        'entry_line': line,
                        'posting_date': posting_date.strftime('%Y-%m-%d'),
                        'period': original_period,
                        'entity_code': entity[0],
                        'account_code': acct,
                        'cost_centre_code': cost_centre,
                        'description': f'LATE POSTING: {desc}',
                        'debit_amount': dr,
                        'credit_amount': cr,
                        'currency': entity[3],
                        'source_system': 'ERP_CORE',
                        'journal_type': 'LATE_POSTING',
                        'created_at': posting_date.strftime('%Y-%m-%d %H:%M:%S'),
                        'posted_by': random.choice(POSTED_BY),
                        'is_reversed': False,
                    })
                seq += 1

        # Restatements (2-3 per quarter)
        if month in (3, 6, 9, 12):
            for _ in range(random.randint(2, 3)):
                amount = round(random.uniform(5000, 50000), 2)
                entity = random.choice(LEGAL_ENTITIES)
                jnl_id = generate_journal_id(seq)
                posting_date = datetime(2025, month, 28)
                restate_period = f'2025-{month - 1:02d}'

                for line, (acct, dr, cr) in enumerate([
                    ('4000', 0.00, amount),
                    ('3100', amount, 0.00)
                ], 1):
                    entries.append({
                        'journal_id': jnl_id,
                        'entry_line': line,
                        'posting_date': posting_date.strftime('%Y-%m-%d'),
                        'period': restate_period,
                        'entity_code': entity[0],
                        'account_code': acct,
                        'cost_centre_code': 'CC-FIN',
                        'description': f'RESTATEMENT: Revenue adjustment for {restate_period}',
                        'debit_amount': dr,
                        'credit_amount': cr,
                        'currency': entity[3],
                        'source_system': 'ERP_CORE',
                        'journal_type': 'RESTATEMENT',
                        'created_at': posting_date.strftime('%Y-%m-%d %H:%M:%S'),
                        'posted_by': 'e.thompson',
                        'is_reversed': False,
                    })
                seq += 1

        # Reversed entries (3-5 per month): original + reversal
        for _ in range(random.randint(3, 5)):
            template = random.choice(JOURNAL_TEMPLATES)
            desc, debit_acct, credit_acct, min_amt, max_amt, cc_list = template
            amount = round(random.uniform(min_amt, max_amt), 2)
            entity = random.choice(LEGAL_ENTITIES)
            cost_centre = random.choice(cc_list)
            posting_date = datetime(2025, month, random.randint(1, 20))
            period = posting_date.strftime('%Y-%m')

            # Original (marked as reversed)
            orig_jnl = generate_journal_id(seq)
            for line, (acct, dr, cr) in enumerate([
                (debit_acct, amount, 0.00),
                (credit_acct, 0.00, amount)
            ], 1):
                entries.append({
                    'journal_id': orig_jnl,
                    'entry_line': line,
                    'posting_date': posting_date.strftime('%Y-%m-%d'),
                    'period': period,
                    'entity_code': entity[0],
                    'account_code': acct,
                    'cost_centre_code': cost_centre,
                    'description': f'ORIGINAL (REVERSED): {desc}',
                    'debit_amount': dr,
                    'credit_amount': cr,
                    'currency': entity[3],
                    'source_system': 'ERP_CORE',
                    'journal_type': 'STANDARD',
                    'created_at': posting_date.strftime('%Y-%m-%d %H:%M:%S'),
                    'posted_by': random.choice(POSTED_BY),
                    'is_reversed': True,
                })
            seq += 1

            # Reversal (swapped debits/credits)
            rev_jnl = generate_journal_id(seq)
            rev_date = posting_date + timedelta(days=random.randint(1, 5))
            if rev_date.month != month:
                rev_date = datetime(2025, month, 28)
            for line, (acct, dr, cr) in enumerate([
                (credit_acct, amount, 0.00),
                (debit_acct, 0.00, amount)
            ], 1):
                entries.append({
                    'journal_id': rev_jnl,
                    'entry_line': line,
                    'posting_date': rev_date.strftime('%Y-%m-%d'),
                    'period': rev_date.strftime('%Y-%m'),
                    'entity_code': entity[0],
                    'account_code': acct,
                    'cost_centre_code': cost_centre,
                    'description': f'REVERSAL OF {orig_jnl}: {desc}',
                    'debit_amount': dr,
                    'credit_amount': cr,
                    'currency': entity[3],
                    'source_system': 'ERP_CORE',
                    'journal_type': 'ADJUSTMENT',
                    'created_at': rev_date.strftime('%Y-%m-%d %H:%M:%S'),
                    'posted_by': random.choice(POSTED_BY),
                    'is_reversed': False,
                })
            seq += 1

    return entries


def write_csv(filename: str, rows: list[dict | tuple], headers: list[str] | None = None):
    filepath = DATA_DIR / filename
    if isinstance(rows[0], dict):
        headers = list(rows[0].keys())
        with open(filepath, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=headers)
            writer.writeheader()
            writer.writerows(rows)
    else:
        with open(filepath, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(headers)
            writer.writerows(rows)
    print(f'  Written {len(rows):,} rows to {filepath}')


def main():
    print('Finflake Data Generator')
    print('=' * 40)

    print('\nGenerating Chart of Accounts...')
    write_csv('chart_of_accounts.csv', CHART_OF_ACCOUNTS,
              ['account_code', 'account_name', 'account_type', 'account_subtype', 'is_control', 'parent_account'])

    print('Generating Legal Entities...')
    write_csv('legal_entities.csv', LEGAL_ENTITIES,
              ['entity_code', 'entity_name', 'country', 'currency', 'consolidation_group'])

    print('Generating Cost Centres...')
    write_csv('cost_centres.csv', COST_CENTRES,
              ['cost_centre_code', 'cost_centre_name', 'department', 'responsible_person'])

    print('Generating GL Journal Entries...')
    journals = generate_journals()
    write_csv('gl_journal_entries.csv', journals)

    print(f'\nDone! Total journal entry lines: {len(journals):,}')
    print(f'  Standard entries: {sum(1 for j in journals if j["journal_type"] == "STANDARD"):,}')
    print(f'  Late postings:    {sum(1 for j in journals if j["journal_type"] == "LATE_POSTING"):,}')
    print(f'  Restatements:     {sum(1 for j in journals if j["journal_type"] == "RESTATEMENT"):,}')
    print(f'  Adjustments:      {sum(1 for j in journals if j["journal_type"] == "ADJUSTMENT"):,}')
    print(f'  Reversed entries: {sum(1 for j in journals if j["is_reversed"]):,}')
    print(f'\nFiles saved to: {DATA_DIR}')


if __name__ == '__main__':
    main()
