-- FINANCIAL REPORTING - Industry-Specific SQL Scenarios
-- This file demonstrates comprehensive financial reporting and analysis using SQL
-- with a complete financial data model including chart of accounts, transactions, and budgets
-- ============================================
-- REQUIRED: This file creates its own financial database schema
-- Run with: duckdb data/databases/financial_reporting.db < exercises/section-12-industry-scenarios/financial-reporting.sql
-- ============================================

-- FINANCIAL REPORTING CONCEPTS:
-- - Chart of Accounts: Structured classification of all financial accounts
-- - General Ledger: Complete record of all financial transactions
-- - Trial Balance: Summary of all account balances to ensure books balance
-- - Financial Statements: P&L, Balance Sheet, Cash Flow Statement
-- - Budget vs Actual Analysis: Comparing planned vs actual financial performance
-- - Financial Ratios: Key performance indicators for financial health

-- BUSINESS CONTEXT:
-- Financial reporting provides critical insights for business decision-making,
-- regulatory compliance, investor relations, and strategic planning.
-- Accurate and timely financial analysis enables organizations to monitor performance,
-- identify trends, manage risks, and optimize resource allocation.

-- ============================================
-- CLEANUP EXISTING TABLES (for repeated runs)
-- ============================================

DROP TABLE IF EXISTS detailed_transactions;
DROP TABLE IF EXISTS fiscal_periods;
DROP TABLE IF EXISTS cost_centers;
DROP TABLE IF EXISTS budget;
DROP TABLE IF EXISTS general_ledger;
DROP TABLE IF EXISTS chart_of_accounts;

-- ============================================
-- FINANCIAL DATA MODEL CREATION
-- ============================================

-- Chart of Accounts - The foundation of financial reporting
CREATE TABLE chart_of_accounts (
    account_id INTEGER PRIMARY KEY,
    account_code VARCHAR(20) UNIQUE,
    account_name VARCHAR(200),
    account_type VARCHAR(50), -- 'Asset', 'Liability', 'Equity', 'Revenue', 'Expense'
    account_subtype VARCHAR(50), -- 'Current Asset', 'Fixed Asset', 'Operating Expense', etc.
    parent_account_id INTEGER,
    is_active BOOLEAN DEFAULT true,
    normal_balance VARCHAR(10), -- 'Debit' or 'Credit'
    description TEXT
);

-- General Ledger - All financial transactions
CREATE TABLE general_ledger (
    transaction_id INTEGER PRIMARY KEY,
    transaction_date DATE,
    account_id INTEGER,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    description TEXT,
    reference_number VARCHAR(50),
    journal_entry_id INTEGER,
    created_by VARCHAR(100),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Budget data for planning and variance analysis
CREATE TABLE budget (
    budget_id INTEGER PRIMARY KEY,
    fiscal_year INTEGER,
    fiscal_period INTEGER, -- 1-12 for months
    account_id INTEGER,
    budget_amount DECIMAL(15,2),
    budget_type VARCHAR(50), -- 'Operating', 'Capital', 'Cash Flow'
    version VARCHAR(20) DEFAULT 'V1.0',
    approved_date DATE,
    notes TEXT
);

-- Cost centers for departmental reporting
CREATE TABLE cost_centers (
    cost_center_id INTEGER PRIMARY KEY,
    cost_center_code VARCHAR(20),
    cost_center_name VARCHAR(200),
    department VARCHAR(100),
    manager_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true
);

-- Enhanced general ledger with cost center allocation
CREATE TABLE detailed_transactions (
    detail_id INTEGER PRIMARY KEY,
    transaction_id INTEGER,
    cost_center_id INTEGER,
    project_code VARCHAR(50),
    allocation_percentage DECIMAL(5,2) DEFAULT 100.00,
    allocated_amount DECIMAL(15,2)
);

-- Financial periods for reporting structure
CREATE TABLE fiscal_periods (
    period_id INTEGER PRIMARY KEY,
    fiscal_year INTEGER,
    fiscal_period INTEGER,
    period_name VARCHAR(50), -- 'January 2024', 'Q1 2024', etc.
    start_date DATE,
    end_date DATE,
    is_closed BOOLEAN DEFAULT false,
    quarter INTEGER,
    year_to_date_period INTEGER
);

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert Chart of Accounts (in proper hierarchy order)
INSERT INTO chart_of_accounts VALUES
-- Top-level headers first
(1000, '1000', 'ASSETS', 'Asset', 'Header', NULL, true, 'Debit', 'Total Assets'),
(2000, '2000', 'LIABILITIES', 'Liability', 'Header', NULL, true, 'Credit', 'Total Liabilities'),
(3000, '3000', 'EQUITY', 'Equity', 'Header', NULL, true, 'Credit', 'Shareholders Equity'),
(4000, '4000', 'REVENUE', 'Revenue', 'Header', NULL, true, 'Credit', 'Total Revenue'),
(5000, '5000', 'COST OF GOODS SOLD', 'Expense', 'Cost of Sales', NULL, true, 'Debit', 'Direct costs'),
(6000, '6000', 'OPERATING EXPENSES', 'Expense', 'Header', NULL, true, 'Debit', 'Operating Expenses'),

-- Second-level categories
(1100, '1100', 'CURRENT ASSETS', 'Asset', 'Current Asset', 1000, true, 'Debit', 'Current Assets'),
(1200, '1200', 'FIXED ASSETS', 'Asset', 'Fixed Asset', 1000, true, 'Debit', 'Long-term assets'),
(2100, '2100', 'CURRENT LIABILITIES', 'Liability', 'Current Liability', 2000, true, 'Credit', 'Short-term obligations'),
(2200, '2200', 'LONG-TERM LIABILITIES', 'Liability', 'Long-term Liability', 2000, true, 'Credit', 'Long-term debt'),

-- Detail accounts
(1110, '1110', 'Cash and Cash Equivalents', 'Asset', 'Current Asset', 1100, true, 'Debit', 'Operating cash accounts'),
(1120, '1120', 'Accounts Receivable', 'Asset', 'Current Asset', 1100, true, 'Debit', 'Customer receivables'),
(1130, '1130', 'Inventory', 'Asset', 'Current Asset', 1100, true, 'Debit', 'Product inventory'),
(1140, '1140', 'Prepaid Expenses', 'Asset', 'Current Asset', 1100, true, 'Debit', 'Prepaid insurance, rent, etc.'),
(1210, '1210', 'Property, Plant & Equipment', 'Asset', 'Fixed Asset', 1200, true, 'Debit', 'Buildings, equipment, vehicles'),
(1220, '1220', 'Accumulated Depreciation', 'Asset', 'Fixed Asset', 1200, true, 'Credit', 'Contra-asset account'),

(2110, '2110', 'Accounts Payable', 'Liability', 'Current Liability', 2100, true, 'Credit', 'Vendor payables'),
(2120, '2120', 'Accrued Expenses', 'Liability', 'Current Liability', 2100, true, 'Credit', 'Accrued wages, taxes, etc.'),
(2130, '2130', 'Short-term Debt', 'Liability', 'Current Liability', 2100, true, 'Credit', 'Notes payable within 1 year'),
(2210, '2210', 'Long-term Debt', 'Liability', 'Long-term Liability', 2200, true, 'Credit', 'Loans payable > 1 year'),

(3100, '3100', 'Share Capital', 'Equity', 'Contributed Capital', 3000, true, 'Credit', 'Common stock'),
(3200, '3200', 'Retained Earnings', 'Equity', 'Retained Earnings', 3000, true, 'Credit', 'Accumulated profits'),

(4100, '4100', 'Sales Revenue', 'Revenue', 'Operating Revenue', 4000, true, 'Credit', 'Product sales'),
(4200, '4200', 'Service Revenue', 'Revenue', 'Operating Revenue', 4000, true, 'Credit', 'Service income'),
(4300, '4300', 'Other Revenue', 'Revenue', 'Non-operating Revenue', 4000, true, 'Credit', 'Interest, gains, etc.'),

(5100, '5100', 'Materials Cost', 'Expense', 'Cost of Sales', 5000, true, 'Debit', 'Raw materials'),
(5200, '5200', 'Labor Cost', 'Expense', 'Cost of Sales', 5000, true, 'Debit', 'Direct labor'),

(6100, '6100', 'Salaries and Wages', 'Expense', 'Personnel', 6000, true, 'Debit', 'Employee compensation'),
(6200, '6200', 'Rent Expense', 'Expense', 'Facilities', 6000, true, 'Debit', 'Office and warehouse rent'),
(6300, '6300', 'Marketing Expense', 'Expense', 'Sales & Marketing', 6000, true, 'Debit', 'Advertising and promotion'),
(6400, '6400', 'Depreciation Expense', 'Expense', 'Non-cash', 6000, true, 'Debit', 'Asset depreciation'),
(6500, '6500', 'Interest Expense', 'Expense', 'Financial', 6000, true, 'Debit', 'Loan interest');

-- Insert Cost Centers
INSERT INTO cost_centers VALUES
(1, 'CC001', 'Sales Department', 'Sales', 'John Smith', true),
(2, 'CC002', 'Marketing Department', 'Marketing', 'Jane Doe', true),
(3, 'CC003', 'Operations Department', 'Operations', 'Mike Johnson', true),
(4, 'CC004', 'Administration', 'Admin', 'Sarah Wilson', true),
(5, 'CC005', 'IT Department', 'Technology', 'David Brown', true);

-- Insert Fiscal Periods
INSERT INTO fiscal_periods VALUES
(1, 2024, 1, 'January 2024', '2024-01-01', '2024-01-31', true, 1, 1),
(2, 2024, 2, 'February 2024', '2024-02-01', '2024-02-29', true, 1, 2),
(3, 2024, 3, 'March 2024', '2024-03-01', '2024-03-31', true, 1, 3),
(4, 2024, 4, 'April 2024', '2024-04-01', '2024-04-30', true, 2, 4),
(5, 2024, 5, 'May 2024', '2024-05-01', '2024-05-31', true, 2, 5),
(6, 2024, 6, 'June 2024', '2024-06-01', '2024-06-30', true, 2, 6),
(7, 2024, 7, 'July 2024', '2024-07-01', '2024-07-31', false, 3, 7),
(8, 2024, 8, 'August 2024', '2024-08-01', '2024-08-31', false, 3, 8),
(9, 2024, 9, 'September 2024', '2024-09-01', '2024-09-30', false, 3, 9),
(10, 2024, 10, 'October 2024', '2024-10-01', '2024-10-31', false, 4, 10),
(11, 2024, 11, 'November 2024', '2024-11-01', '2024-11-30', false, 4, 11),
(12, 2024, 12, 'December 2024', '2024-12-01', '2024-12-31', false, 4, 12);

-- Insert Sample Transactions (January - June 2024)
INSERT INTO general_ledger VALUES
-- January 2024 transactions
(1, '2024-01-01', 1110, 500000, 0, 'Initial cash investment', 'INV-001', 1, 'System', '2024-01-01 09:00:00'),
(2, '2024-01-01', 3100, 0, 500000, 'Initial share capital', 'INV-001', 1, 'System', '2024-01-01 09:00:00'),

(3, '2024-01-15', 1120, 150000, 0, 'Sales on credit - Customer A', 'INV-1001', 2, 'Sales', '2024-01-15 10:30:00'),
(4, '2024-01-15', 4100, 0, 150000, 'Product sales revenue', 'INV-1001', 2, 'Sales', '2024-01-15 10:30:00'),

(5, '2024-01-20', 5100, 90000, 0, 'Materials purchased', 'PO-2001', 3, 'Purchasing', '2024-01-20 14:15:00'),
(6, '2024-01-20', 2110, 0, 90000, 'Accounts payable - Supplier B', 'PO-2001', 3, 'Purchasing', '2024-01-20 14:15:00'),

(7, '2024-01-31', 6100, 45000, 0, 'January salaries', 'PAY-001', 4, 'HR', '2024-01-31 16:00:00'),
(8, '2024-01-31', 1110, 0, 45000, 'Cash payment for salaries', 'PAY-001', 4, 'HR', '2024-01-31 16:00:00'),

-- February 2024 transactions
(9, '2024-02-01', 1110, 120000, 0, 'Cash received from Customer A', 'REC-1001', 5, 'Collections', '2024-02-01 11:00:00'),
(10, '2024-02-01', 1120, 0, 120000, 'Partial payment received', 'REC-1001', 5, 'Collections', '2024-02-01 11:00:00'),

(11, '2024-02-10', 1120, 200000, 0, 'Sales on credit - Customer C', 'INV-1002', 6, 'Sales', '2024-02-10 13:45:00'),
(12, '2024-02-10', 4100, 0, 200000, 'Product sales revenue', 'INV-1002', 6, 'Sales', '2024-02-10 13:45:00'),

(13, '2024-02-15', 6200, 25000, 0, 'Office rent - February', 'RENT-002', 7, 'Admin', '2024-02-15 09:30:00'),
(14, '2024-02-15', 1110, 0, 25000, 'Cash payment for rent', 'RENT-002', 7, 'Admin', '2024-02-15 09:30:00'),

(15, '2024-02-28', 6100, 47000, 0, 'February salaries', 'PAY-002', 8, 'HR', '2024-02-28 16:00:00'),
(16, '2024-02-28', 1110, 0, 47000, 'Cash payment for salaries', 'PAY-002', 8, 'HR', '2024-02-28 16:00:00'),

-- March 2024 transactions
(17, '2024-03-05', 1210, 150000, 0, 'Equipment purchase', 'EQ-001', 9, 'Operations', '2024-03-05 10:00:00'),
(18, '2024-03-05', 1110, 0, 150000, 'Cash payment for equipment', 'EQ-001', 9, 'Operations', '2024-03-05 10:00:00'),

(19, '2024-03-15', 1120, 180000, 0, 'Sales on credit - Customer D', 'INV-1003', 10, 'Sales', '2024-03-15 14:20:00'),
(20, '2024-03-15', 4100, 0, 180000, 'Product sales revenue', 'INV-1003', 10, 'Sales', '2024-03-15 14:20:00'),

(21, '2024-03-20', 6300, 35000, 0, 'Marketing campaign', 'MKT-001', 11, 'Marketing', '2024-03-20 11:15:00'),
(22, '2024-03-20', 1110, 0, 35000, 'Cash payment for marketing', 'MKT-001', 11, 'Marketing', '2024-03-20 11:15:00'),

(23, '2024-03-31', 6100, 48000, 0, 'March salaries', 'PAY-003', 12, 'HR', '2024-03-31 16:00:00'),
(24, '2024-03-31', 1110, 0, 48000, 'Cash payment for salaries', 'PAY-003', 12, 'HR', '2024-03-31 16:00:00'),

(25, '2024-03-31', 6400, 5000, 0, 'Depreciation expense - Q1', 'DEP-Q1', 13, 'Accounting', '2024-03-31 17:00:00'),
(26, '2024-03-31', 1220, 0, 5000, 'Accumulated depreciation', 'DEP-Q1', 13, 'Accounting', '2024-03-31 17:00:00'),

-- April 2024 transactions
(27, '2024-04-10', 1110, 180000, 0, 'Cash received from Customer C', 'REC-1002', 14, 'Collections', '2024-04-10 10:30:00'),
(28, '2024-04-10', 1120, 0, 180000, 'Full payment received', 'REC-1002', 14, 'Collections', '2024-04-10 10:30:00'),

(29, '2024-04-15', 1120, 220000, 0, 'Sales on credit - Customer E', 'INV-1004', 15, 'Sales', '2024-04-15 15:00:00'),
(30, '2024-04-15', 4100, 0, 220000, 'Product sales revenue', 'INV-1004', 15, 'Sales', '2024-04-15 15:00:00'),

(31, '2024-04-30', 6100, 49000, 0, 'April salaries', 'PAY-004', 16, 'HR', '2024-04-30 16:00:00'),
(32, '2024-04-30', 1110, 0, 49000, 'Cash payment for salaries', 'PAY-004', 16, 'HR', '2024-04-30 16:00:00'),

-- May 2024 transactions
(33, '2024-05-01', 2110, 90000, 0, 'Payment to Supplier B', 'PAY-SUP-001', 17, 'AP', '2024-05-01 09:00:00'),
(34, '2024-05-01', 1110, 0, 90000, 'Cash payment to supplier', 'PAY-SUP-001', 17, 'AP', '2024-05-01 09:00:00'),

(35, '2024-05-20', 1120, 160000, 0, 'Sales on credit - Customer F', 'INV-1005', 18, 'Sales', '2024-05-20 12:30:00'),
(36, '2024-05-20', 4100, 0, 160000, 'Product sales revenue', 'INV-1005', 18, 'Sales', '2024-05-20 12:30:00'),

(37, '2024-05-31', 6100, 50000, 0, 'May salaries', 'PAY-005', 19, 'HR', '2024-05-31 16:00:00'),
(38, '2024-05-31', 1110, 0, 50000, 'Cash payment for salaries', 'PAY-005', 19, 'HR', '2024-05-31 16:00:00'),

-- June 2024 transactions
(39, '2024-06-15', 1120, 190000, 0, 'Sales on credit - Customer G', 'INV-1006', 20, 'Sales', '2024-06-15 11:45:00'),
(40, '2024-06-15', 4100, 0, 190000, 'Product sales revenue', 'INV-1006', 20, 'Sales', '2024-06-15 11:45:00'),

(41, '2024-06-25', 6500, 8000, 0, 'Interest expense on loan', 'INT-001', 21, 'Finance', '2024-06-25 14:00:00'),
(42, '2024-06-25', 1110, 0, 8000, 'Cash payment for interest', 'INT-001', 21, 'Finance', '2024-06-25 14:00:00'),

(43, '2024-06-30', 6100, 51000, 0, 'June salaries', 'PAY-006', 22, 'HR', '2024-06-30 16:00:00'),
(44, '2024-06-30', 1110, 0, 51000, 'Cash payment for salaries', 'PAY-006', 22, 'HR', '2024-06-30 16:00:00'),

(45, '2024-06-30', 6400, 5000, 0, 'Depreciation expense - Q2', 'DEP-Q2', 23, 'Accounting', '2024-06-30 17:00:00'),
(46, '2024-06-30', 1220, 0, 5000, 'Accumulated depreciation', 'DEP-Q2', 23, 'Accounting', '2024-06-30 17:00:00');

-- Insert Budget Data for 2024
INSERT INTO budget VALUES
-- Revenue budgets
(1, 2024, 1, 4100, 140000, 'Operating', 'V1.0', '2023-12-15', 'Conservative sales estimate'),
(2, 2024, 2, 4100, 180000, 'Operating', 'V1.0', '2023-12-15', 'Growth expected'),
(3, 2024, 3, 4100, 170000, 'Operating', 'V1.0', '2023-12-15', 'Seasonal adjustment'),
(4, 2024, 4, 4100, 200000, 'Operating', 'V1.0', '2023-12-15', 'Spring sales push'),
(5, 2024, 5, 4100, 150000, 'Operating', 'V1.0', '2023-12-15', 'Market conditions'),
(6, 2024, 6, 4100, 180000, 'Operating', 'V1.0', '2023-12-15', 'Mid-year target'),

-- Expense budgets - Salaries
(7, 2024, 1, 6100, 50000, 'Operating', 'V1.0', '2023-12-15', 'Staff compensation'),
(8, 2024, 2, 6100, 50000, 'Operating', 'V1.0', '2023-12-15', 'Staff compensation'),
(9, 2024, 3, 6100, 52000, 'Operating', 'V1.0', '2023-12-15', 'Annual increases'),
(10, 2024, 4, 6100, 52000, 'Operating', 'V1.0', '2023-12-15', 'Staff compensation'),
(11, 2024, 5, 6100, 52000, 'Operating', 'V1.0', '2023-12-15', 'Staff compensation'),
(12, 2024, 6, 6100, 54000, 'Operating', 'V1.0', '2023-12-15', 'Mid-year adjustments'),

-- Expense budgets - Marketing
(13, 2024, 1, 6300, 20000, 'Operating', 'V1.0', '2023-12-15', 'Q1 campaigns'),
(14, 2024, 2, 6300, 25000, 'Operating', 'V1.0', '2023-12-15', 'Brand awareness'),
(15, 2024, 3, 6300, 30000, 'Operating', 'V1.0', '2023-12-15', 'Product launch'),
(16, 2024, 4, 6300, 25000, 'Operating', 'V1.0', '2023-12-15', 'Ongoing campaigns'),
(17, 2024, 5, 6300, 20000, 'Operating', 'V1.0', '2023-12-15', 'Reduced spend'),
(18, 2024, 6, 6300, 22000, 'Operating', 'V1.0', '2023-12-15', 'Summer campaigns');

-- ============================================
-- PROFIT & LOSS STATEMENT ANALYSIS
-- ============================================

-- WHAT IT IS: The Profit & Loss (P&L) statement shows a company's revenues,
-- expenses, and profits over a specific period, revealing operational performance.
--
-- WHY IT MATTERS: P&L analysis enables:
-- - Assessment of operational efficiency and profitability
-- - Identification of cost control opportunities
-- - Trend analysis for strategic planning
-- - Performance comparison against budgets and benchmarks
--
-- KEY COMPONENTS: Revenue, Cost of Goods Sold, Gross Profit, Operating Expenses, Net Income
-- BENCHMARK: Healthy gross margins vary by industry (20-80%), net margins typically 5-20%

-- Example 1: Monthly Profit & Loss Statement
-- Business Question: "What is our financial performance by month?"

WITH monthly_pl AS (
    SELECT 
        EXTRACT(YEAR FROM gl.transaction_date) as fiscal_year,
        EXTRACT(MONTH FROM gl.transaction_date) as fiscal_month,
        coa.account_type,
        coa.account_subtype,
        coa.account_name,
        
        -- Calculate net amounts (debits - credits for expenses, credits - debits for revenue)
        CASE 
            WHEN coa.account_type = 'Revenue' THEN SUM(gl.credit_amount - gl.debit_amount)
            WHEN coa.account_type = 'Expense' THEN SUM(gl.debit_amount - gl.credit_amount)
            ELSE 0
        END as net_amount
        
    FROM general_ledger gl
    JOIN chart_of_accounts coa ON gl.account_id = coa.account_id
    WHERE coa.account_type IN ('Revenue', 'Expense')
    AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
    GROUP BY 
        EXTRACT(YEAR FROM gl.transaction_date),
        EXTRACT(MONTH FROM gl.transaction_date),
        coa.account_type,
        coa.account_subtype,
        coa.account_name,
        coa.account_id
)

SELECT 
    fiscal_year,
    fiscal_month,
    
    -- Revenue section
    SUM(CASE WHEN account_type = 'Revenue' THEN net_amount ELSE 0 END) as total_revenue,
    
    -- Cost of Goods Sold
    SUM(CASE WHEN account_subtype = 'Cost of Sales' THEN net_amount ELSE 0 END) as cost_of_goods_sold,
    
    -- Gross Profit
    SUM(CASE WHEN account_type = 'Revenue' THEN net_amount ELSE 0 END) - 
    SUM(CASE WHEN account_subtype = 'Cost of Sales' THEN net_amount ELSE 0 END) as gross_profit,
    
    -- Operating Expenses
    SUM(CASE WHEN account_type = 'Expense' AND account_subtype != 'Cost of Sales' THEN net_amount ELSE 0 END) as operating_expenses,
    
    -- Operating Income
    SUM(CASE WHEN account_type = 'Revenue' THEN net_amount ELSE 0 END) - 
    SUM(CASE WHEN account_type = 'Expense' THEN net_amount ELSE 0 END) as operating_income,
    
    -- Calculate margins
    ROUND(
        (SUM(CASE WHEN account_type = 'Revenue' THEN net_amount ELSE 0 END) - 
         SUM(CASE WHEN account_subtype = 'Cost of Sales' THEN net_amount ELSE 0 END)) * 100.0 /
        NULLIF(SUM(CASE WHEN account_type = 'Revenue' THEN net_amount ELSE 0 END), 0), 2
    ) as gross_margin_pct,
    
    ROUND(
        (SUM(CASE WHEN account_type = 'Revenue' THEN net_amount ELSE 0 END) - 
         SUM(CASE WHEN account_type = 'Expense' THEN net_amount ELSE 0 END)) * 100.0 /
        NULLIF(SUM(CASE WHEN account_type = 'Revenue' THEN net_amount ELSE 0 END), 0), 2
    ) as net_margin_pct

FROM monthly_pl
GROUP BY fiscal_year, fiscal_month
ORDER BY fiscal_year, fiscal_month;

-- Example 2: Detailed Expense Analysis by Category
-- Business Question: "What are our major expense categories and trends?"

SELECT 
    coa.account_subtype as expense_category,
    coa.account_name,
    
    -- Monthly breakdown
    SUM(CASE WHEN EXTRACT(MONTH FROM gl.transaction_date) = 1 THEN gl.debit_amount - gl.credit_amount ELSE 0 END) as jan_amount,
    SUM(CASE WHEN EXTRACT(MONTH FROM gl.transaction_date) = 2 THEN gl.debit_amount - gl.credit_amount ELSE 0 END) as feb_amount,
    SUM(CASE WHEN EXTRACT(MONTH FROM gl.transaction_date) = 3 THEN gl.debit_amount - gl.credit_amount ELSE 0 END) as mar_amount,
    SUM(CASE WHEN EXTRACT(MONTH FROM gl.transaction_date) = 4 THEN gl.debit_amount - gl.credit_amount ELSE 0 END) as apr_amount,
    SUM(CASE WHEN EXTRACT(MONTH FROM gl.transaction_date) = 5 THEN gl.debit_amount - gl.credit_amount ELSE 0 END) as may_amount,
    SUM(CASE WHEN EXTRACT(MONTH FROM gl.transaction_date) = 6 THEN gl.debit_amount - gl.credit_amount ELSE 0 END) as jun_amount,
    
    -- Totals and analysis
    SUM(gl.debit_amount - gl.credit_amount) as total_ytd,
    ROUND(AVG(gl.debit_amount - gl.credit_amount), 2) as avg_monthly,
    COUNT(gl.transaction_id) as transaction_count,
    
    -- Percentage of total expenses
    ROUND(
        SUM(gl.debit_amount - gl.credit_amount) * 100.0 / 
        (SELECT SUM(debit_amount - credit_amount) 
         FROM general_ledger gl2 
         JOIN chart_of_accounts coa2 ON gl2.account_id = coa2.account_id 
         WHERE coa2.account_type = 'Expense' 
         AND gl2.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'), 2
    ) as pct_of_total_expenses

FROM general_ledger gl
JOIN chart_of_accounts coa ON gl.account_id = coa.account_id
WHERE coa.account_type = 'Expense'
AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
GROUP BY coa.account_subtype, coa.account_name, coa.account_id
ORDER BY total_ytd DESC;

-- ============================================
-- BUDGET VS ACTUAL ANALYSIS
-- ============================================

-- WHAT IT IS: Budget vs Actual analysis compares planned financial performance
-- against actual results to identify variances and their causes.
--
-- WHY IT MATTERS: Variance analysis enables:
-- - Performance monitoring against financial plans
-- - Early identification of budget deviations
-- - Improved forecasting and planning accuracy
-- - Resource allocation optimization
--
-- KEY METRICS: Variance amount, variance percentage, favorable vs unfavorable
-- BENCHMARK: Variances within 5-10% are typically considered acceptable

-- Example 3: Revenue Budget vs Actual Analysis
-- Business Question: "How are we performing against our revenue budget?"

WITH actual_revenue AS (
    SELECT 
        EXTRACT(MONTH FROM gl.transaction_date) as fiscal_period,
        SUM(gl.credit_amount - gl.debit_amount) as actual_amount
    FROM general_ledger gl
    JOIN chart_of_accounts coa ON gl.account_id = coa.account_id
    WHERE coa.account_type = 'Revenue'
    AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
    GROUP BY EXTRACT(MONTH FROM gl.transaction_date)
),

budget_revenue AS (
    SELECT 
        fiscal_period,
        SUM(budget_amount) as budget_amount
    FROM budget b
    JOIN chart_of_accounts coa ON b.account_id = coa.account_id
    WHERE coa.account_type = 'Revenue'
    AND fiscal_year = 2024
    AND fiscal_period <= 6
    GROUP BY fiscal_period
)

SELECT 
    fp.period_name,
    br.budget_amount,
    COALESCE(ar.actual_amount, 0) as actual_amount,
    
    -- Variance calculations
    COALESCE(ar.actual_amount, 0) - br.budget_amount as variance_amount,
    ROUND(
        (COALESCE(ar.actual_amount, 0) - br.budget_amount) * 100.0 / 
        NULLIF(br.budget_amount, 0), 2
    ) as variance_pct,
    
    -- Performance indicators
    CASE 
        WHEN COALESCE(ar.actual_amount, 0) >= br.budget_amount THEN 'Favorable'
        ELSE 'Unfavorable'
    END as variance_type,
    
    CASE 
        WHEN ABS((COALESCE(ar.actual_amount, 0) - br.budget_amount) * 100.0 / NULLIF(br.budget_amount, 0)) <= 5 THEN 'On Target'
        WHEN ABS((COALESCE(ar.actual_amount, 0) - br.budget_amount) * 100.0 / NULLIF(br.budget_amount, 0)) <= 15 THEN 'Moderate Variance'
        ELSE 'Significant Variance'
    END as variance_category,
    
    -- Cumulative analysis
    SUM(br.budget_amount) OVER (ORDER BY br.fiscal_period) as cumulative_budget,
    SUM(COALESCE(ar.actual_amount, 0)) OVER (ORDER BY br.fiscal_period) as cumulative_actual

FROM budget_revenue br
LEFT JOIN actual_revenue ar ON br.fiscal_period = ar.fiscal_period
JOIN fiscal_periods fp ON br.fiscal_period = fp.fiscal_period AND fp.fiscal_year = 2024
ORDER BY br.fiscal_period;

-- Example 4: Expense Budget vs Actual Analysis
-- Business Question: "Which expense categories are over or under budget?"

WITH actual_expenses AS (
    SELECT 
        coa.account_name,
        coa.account_subtype,
        EXTRACT(MONTH FROM gl.transaction_date) as fiscal_period,
        SUM(gl.debit_amount - gl.credit_amount) as actual_amount
    FROM general_ledger gl
    JOIN chart_of_accounts coa ON gl.account_id = coa.account_id
    WHERE coa.account_type = 'Expense'
    AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
    GROUP BY coa.account_name, coa.account_subtype, coa.account_id, EXTRACT(MONTH FROM gl.transaction_date)
),

budget_expenses AS (
    SELECT 
        coa.account_name,
        coa.account_subtype,
        b.fiscal_period,
        SUM(b.budget_amount) as budget_amount
    FROM budget b
    JOIN chart_of_accounts coa ON b.account_id = coa.account_id
    WHERE coa.account_type = 'Expense'
    AND b.fiscal_year = 2024
    AND b.fiscal_period <= 6
    GROUP BY coa.account_name, coa.account_subtype, b.fiscal_period
)

SELECT 
    be.account_subtype as expense_category,
    be.account_name,
    
    -- YTD totals
    SUM(be.budget_amount) as ytd_budget,
    SUM(COALESCE(ae.actual_amount, 0)) as ytd_actual,
    SUM(COALESCE(ae.actual_amount, 0)) - SUM(be.budget_amount) as ytd_variance,
    
    -- Variance analysis
    ROUND(
        (SUM(COALESCE(ae.actual_amount, 0)) - SUM(be.budget_amount)) * 100.0 / 
        NULLIF(SUM(be.budget_amount), 0), 2
    ) as variance_pct,
    
    -- Performance assessment
    CASE 
        WHEN SUM(COALESCE(ae.actual_amount, 0)) <= SUM(be.budget_amount) THEN 'Under Budget (Favorable)'
        ELSE 'Over Budget (Unfavorable)'
    END as budget_performance,
    
    -- Monthly average
    ROUND(SUM(be.budget_amount) / 6.0, 2) as avg_monthly_budget,
    ROUND(SUM(COALESCE(ae.actual_amount, 0)) / 6.0, 2) as avg_monthly_actual,
    
    -- Utilization rate
    ROUND(
        SUM(COALESCE(ae.actual_amount, 0)) * 100.0 / 
        NULLIF(SUM(be.budget_amount), 0), 2
    ) as budget_utilization_pct

FROM budget_expenses be
LEFT JOIN actual_expenses ae ON be.account_name = ae.account_name AND be.fiscal_period = ae.fiscal_period
GROUP BY be.account_subtype, be.account_name
ORDER BY ABS(SUM(COALESCE(ae.actual_amount, 0)) - SUM(be.budget_amount)) DESC;

-- ============================================
-- BALANCE SHEET ANALYSIS
-- ============================================

-- WHAT IT IS: The Balance Sheet shows a company's financial position at a specific
-- point in time, displaying assets, liabilities, and equity.
--
-- WHY IT MATTERS: Balance Sheet analysis reveals:
-- - Financial stability and solvency
-- - Asset utilization efficiency
-- - Capital structure and leverage
-- - Liquidity position
--
-- FUNDAMENTAL EQUATION: Assets = Liabilities + Equity
-- KEY RATIOS: Current ratio, debt-to-equity, return on assets

-- Example 5: Balance Sheet as of June 30, 2024
-- Business Question: "What is our financial position at the end of Q2?"

WITH account_balances AS (
    SELECT 
        coa.account_id,
        coa.account_code,
        coa.account_name,
        coa.account_type,
        coa.account_subtype,
        coa.normal_balance,
        
        -- Calculate running balance based on normal balance
        CASE 
            WHEN coa.normal_balance = 'Debit' THEN 
                SUM(gl.debit_amount - gl.credit_amount)
            ELSE 
                SUM(gl.credit_amount - gl.debit_amount)
        END as account_balance
        
    FROM chart_of_accounts coa
    LEFT JOIN general_ledger gl ON coa.account_id = gl.account_id 
        AND gl.transaction_date <= '2024-06-30'
    WHERE coa.account_type IN ('Asset', 'Liability', 'Equity')
    GROUP BY coa.account_id, coa.account_code, coa.account_name, 
             coa.account_type, coa.account_subtype, coa.normal_balance
)

SELECT 
    account_type,
    account_subtype,
    account_name,
    ROUND(account_balance, 2) as balance,
    
    -- Calculate percentages within account type
    ROUND(
        account_balance * 100.0 / 
        SUM(account_balance) OVER (PARTITION BY account_type), 2
    ) as pct_of_type,
    
    -- Calculate percentage of total assets (for ratio analysis)
    ROUND(
        account_balance * 100.0 / 
        (SELECT SUM(account_balance) FROM account_balances WHERE account_type = 'Asset'), 2
    ) as pct_of_total_assets

FROM account_balances
WHERE account_balance != 0  -- Only show accounts with balances
ORDER BY 
    CASE account_type 
        WHEN 'Asset' THEN 1 
        WHEN 'Liability' THEN 2 
        WHEN 'Equity' THEN 3 
    END,
    account_subtype,
    account_name;

-- Example 6: Financial Ratios Analysis
-- Business Question: "What are our key financial health indicators?"

WITH balance_sheet_summary AS (
    SELECT 
        SUM(CASE WHEN coa.account_type = 'Asset' AND coa.account_subtype = 'Current Asset' 
                 THEN CASE WHEN coa.normal_balance = 'Debit' 
                          THEN gl_sum.debit_total - gl_sum.credit_total
                          ELSE gl_sum.credit_total - gl_sum.debit_total END 
                 ELSE 0 END) as current_assets,
                 
        SUM(CASE WHEN coa.account_type = 'Asset' 
                 THEN CASE WHEN coa.normal_balance = 'Debit' 
                          THEN gl_sum.debit_total - gl_sum.credit_total
                          ELSE gl_sum.credit_total - gl_sum.debit_total END 
                 ELSE 0 END) as total_assets,
                 
        SUM(CASE WHEN coa.account_type = 'Liability' AND coa.account_subtype = 'Current Liability' 
                 THEN CASE WHEN coa.normal_balance = 'Credit' 
                          THEN gl_sum.credit_total - gl_sum.debit_total
                          ELSE gl_sum.debit_total - gl_sum.credit_total END 
                 ELSE 0 END) as current_liabilities,
                 
        SUM(CASE WHEN coa.account_type = 'Liability' 
                 THEN CASE WHEN coa.normal_balance = 'Credit' 
                          THEN gl_sum.credit_total - gl_sum.debit_total
                          ELSE gl_sum.debit_total - gl_sum.credit_total END 
                 ELSE 0 END) as total_liabilities,
                 
        SUM(CASE WHEN coa.account_type = 'Equity' 
                 THEN CASE WHEN coa.normal_balance = 'Credit' 
                          THEN gl_sum.credit_total - gl_sum.debit_total
                          ELSE gl_sum.debit_total - gl_sum.credit_total END 
                 ELSE 0 END) as total_equity
                 
    FROM chart_of_accounts coa
    LEFT JOIN (
        SELECT 
            account_id,
            SUM(debit_amount) as debit_total,
            SUM(credit_amount) as credit_total
        FROM general_ledger 
        WHERE transaction_date <= '2024-06-30'
        GROUP BY account_id
    ) gl_sum ON coa.account_id = gl_sum.account_id
),

income_summary AS (
    SELECT 
        SUM(CASE WHEN coa.account_type = 'Revenue' 
                 THEN gl.credit_amount - gl.debit_amount ELSE 0 END) -
        SUM(CASE WHEN coa.account_type = 'Expense' 
                 THEN gl.debit_amount - gl.credit_amount ELSE 0 END) as net_income_ytd
    FROM general_ledger gl
    JOIN chart_of_accounts coa ON gl.account_id = coa.account_id
    WHERE gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
    AND coa.account_type IN ('Revenue', 'Expense')
)

SELECT 
    'FINANCIAL RATIOS ANALYSIS - June 30, 2024' as analysis_title,
    
    -- Liquidity Ratios
    ROUND(bs.current_assets / NULLIF(bs.current_liabilities, 0), 2) as current_ratio,
    ROUND((bs.current_assets - bs.current_liabilities), 2) as working_capital,
    
    -- Leverage Ratios
    ROUND(bs.total_liabilities / NULLIF(bs.total_assets, 0) * 100, 2) as debt_to_assets_pct,
    ROUND(bs.total_liabilities / NULLIF(bs.total_equity, 0), 2) as debt_to_equity_ratio,
    
    -- Profitability Ratios
    ROUND(inc.net_income_ytd / NULLIF(bs.total_assets, 0) * 100, 2) as return_on_assets_pct,
    ROUND(inc.net_income_ytd / NULLIF(bs.total_equity, 0) * 100, 2) as return_on_equity_pct,
    
    -- Balance Sheet Verification
    ROUND(bs.total_assets, 2) as total_assets,
    ROUND(bs.total_liabilities + bs.total_equity, 2) as liabilities_plus_equity,
    ROUND(bs.total_assets - (bs.total_liabilities + bs.total_equity), 2) as balance_check,
    
    -- Performance Indicators
    CASE 
        WHEN bs.current_assets / NULLIF(bs.current_liabilities, 0) >= 2.0 THEN 'Excellent Liquidity'
        WHEN bs.current_assets / NULLIF(bs.current_liabilities, 0) >= 1.5 THEN 'Good Liquidity'
        WHEN bs.current_assets / NULLIF(bs.current_liabilities, 0) >= 1.0 THEN 'Adequate Liquidity'
        ELSE 'Poor Liquidity'
    END as liquidity_assessment,
    
    CASE 
        WHEN bs.total_liabilities / NULLIF(bs.total_assets, 0) <= 0.3 THEN 'Conservative Leverage'
        WHEN bs.total_liabilities / NULLIF(bs.total_assets, 0) <= 0.6 THEN 'Moderate Leverage'
        ELSE 'High Leverage'
    END as leverage_assessment

FROM balance_sheet_summary bs
CROSS JOIN income_summary inc;

-- ============================================
-- CASH FLOW ANALYSIS
-- ============================================

-- WHAT IT IS: Cash Flow analysis tracks the movement of cash in and out of
-- the business, categorized by operating, investing, and financing activities.
--
-- WHY IT MATTERS: Cash flow analysis reveals:
-- - Actual cash generation from operations
-- - Investment and financing patterns
-- - Liquidity trends and cash management effectiveness
-- - Sustainability of business operations
--
-- CATEGORIES: Operating (day-to-day), Investing (assets), Financing (capital)
-- BENCHMARK: Positive operating cash flow indicates healthy operations

-- Example 7: Cash Flow Statement Analysis
-- Business Question: "What are our cash flow patterns by activity type?"

WITH cash_transactions AS (
    SELECT 
        gl.transaction_date,
        gl.debit_amount - gl.credit_amount as net_cash_flow,
        gl.description,
        gl.reference_number,
        
        -- Categorize cash flows
        CASE 
            WHEN gl.description LIKE '%sales%' OR gl.description LIKE '%revenue%' 
                 OR gl.description LIKE '%received%' OR gl.description LIKE '%collection%' THEN 'Operating - Inflows'
            WHEN gl.description LIKE '%salaries%' OR gl.description LIKE '%rent%' 
                 OR gl.description LIKE '%marketing%' OR gl.description LIKE '%supplier%' 
                 OR gl.description LIKE '%interest%' THEN 'Operating - Outflows'
            WHEN gl.description LIKE '%equipment%' OR gl.description LIKE '%asset%' THEN 'Investing'
            WHEN gl.description LIKE '%investment%' OR gl.description LIKE '%capital%' 
                 OR gl.description LIKE '%loan%' THEN 'Financing'
            ELSE 'Other'
        END as cash_flow_category
        
    FROM general_ledger gl
    JOIN chart_of_accounts coa ON gl.account_id = coa.account_id
    WHERE coa.account_code = '1110'  -- Cash account
    AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
)

SELECT 
    cash_flow_category,
    COUNT(*) as transaction_count,
    SUM(net_cash_flow) as total_cash_flow,
    ROUND(AVG(net_cash_flow), 2) as avg_transaction_amount,
    
    -- Monthly breakdown
    SUM(CASE WHEN EXTRACT(MONTH FROM transaction_date) = 1 THEN net_cash_flow ELSE 0 END) as jan_cash_flow,
    SUM(CASE WHEN EXTRACT(MONTH FROM transaction_date) = 2 THEN net_cash_flow ELSE 0 END) as feb_cash_flow,
    SUM(CASE WHEN EXTRACT(MONTH FROM transaction_date) = 3 THEN net_cash_flow ELSE 0 END) as mar_cash_flow,
    SUM(CASE WHEN EXTRACT(MONTH FROM transaction_date) = 4 THEN net_cash_flow ELSE 0 END) as apr_cash_flow,
    SUM(CASE WHEN EXTRACT(MONTH FROM transaction_date) = 5 THEN net_cash_flow ELSE 0 END) as may_cash_flow,
    SUM(CASE WHEN EXTRACT(MONTH FROM transaction_date) = 6 THEN net_cash_flow ELSE 0 END) as jun_cash_flow,
    
    -- Percentage of total cash activity
    ROUND(
        SUM(ABS(net_cash_flow)) * 100.0 / 
        (SELECT SUM(ABS(net_cash_flow)) FROM cash_transactions), 2
    ) as pct_of_total_activity

FROM cash_transactions
GROUP BY cash_flow_category
ORDER BY total_cash_flow DESC;

-- Example 8: Monthly Cash Position Analysis
-- Business Question: "How has our cash position changed over time?"

WITH monthly_cash_flow AS (
    SELECT 
        EXTRACT(YEAR FROM gl.transaction_date) as fiscal_year,
        EXTRACT(MONTH FROM gl.transaction_date) as fiscal_month,
        SUM(gl.debit_amount - gl.credit_amount) as monthly_net_cash_flow,
        
        -- Calculate running cash balance
        SUM(SUM(gl.debit_amount - gl.credit_amount)) OVER (
            ORDER BY EXTRACT(YEAR FROM gl.transaction_date), EXTRACT(MONTH FROM gl.transaction_date)
        ) as running_cash_balance
        
    FROM general_ledger gl
    JOIN chart_of_accounts coa ON gl.account_id = coa.account_id
    WHERE coa.account_code = '1110'  -- Cash account
    AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30'
    GROUP BY EXTRACT(YEAR FROM gl.transaction_date), EXTRACT(MONTH FROM gl.transaction_date)
)

SELECT 
    fp.period_name,
    COALESCE(mcf.monthly_net_cash_flow, 0) as monthly_cash_flow,
    COALESCE(mcf.running_cash_balance, 0) as ending_cash_balance,
    
    -- Calculate month-over-month change
    COALESCE(mcf.running_cash_balance, 0) - 
    LAG(COALESCE(mcf.running_cash_balance, 0), 1, 0) OVER (ORDER BY fp.fiscal_period) as mom_change,
    
    -- Performance indicators
    CASE 
        WHEN COALESCE(mcf.monthly_net_cash_flow, 0) > 0 THEN 'Positive Cash Flow'
        WHEN COALESCE(mcf.monthly_net_cash_flow, 0) = 0 THEN 'Neutral Cash Flow'
        ELSE 'Negative Cash Flow'
    END as cash_flow_status,
    
    CASE 
        WHEN COALESCE(mcf.running_cash_balance, 0) >= 100000 THEN 'Strong Cash Position'
        WHEN COALESCE(mcf.running_cash_balance, 0) >= 50000 THEN 'Adequate Cash Position'
        WHEN COALESCE(mcf.running_cash_balance, 0) >= 0 THEN 'Weak Cash Position'
        ELSE 'Cash Deficit'
    END as liquidity_status

FROM fiscal_periods fp
LEFT JOIN monthly_cash_flow mcf ON fp.fiscal_year = mcf.fiscal_year AND fp.fiscal_period = mcf.fiscal_month
WHERE fp.fiscal_year = 2024 AND fp.fiscal_period <= 6
ORDER BY fp.fiscal_period;

-- ============================================
-- FINANCIAL REPORTING BEST PRACTICES
-- ============================================

-- PERFORMANCE OPTIMIZATION STRATEGIES:
-- 1. Database Design for Financial Reporting
--    - Implement proper indexing on date columns and account IDs
--    - Use appropriate data types for monetary amounts (DECIMAL vs FLOAT)
--    - Consider partitioning large transaction tables by fiscal period

-- 2. Data Integrity and Controls
--    - Implement double-entry bookkeeping validation (debits = credits)
--    - Use foreign key constraints to maintain referential integrity
--    - Implement audit trails for all financial transactions

-- 3. Reporting Automation
--    - Create materialized views for frequently accessed financial statements
--    - Implement automated variance analysis with exception reporting
--    - Schedule regular financial close procedures and reconciliations

-- COMPLIANCE AND GOVERNANCE:
-- 1. Regulatory Requirements
--    - Ensure compliance with accounting standards (GAAP, IFRS)
--    - Implement proper documentation and approval workflows
--    - Maintain audit trails for regulatory examinations

-- 2. Internal Controls
--    - Segregation of duties in financial processes
--    - Regular reconciliation procedures
--    - Management review and approval processes

-- 3. Data Security
--    - Implement role-based access controls
--    - Encrypt sensitive financial data
--    - Regular backup and disaster recovery procedures

-- ANALYTICAL INSIGHTS FRAMEWORK:
-- 1. Trend Analysis
--    - Monitor key financial ratios over time
--    - Identify seasonal patterns in revenue and expenses
--    - Track performance against industry benchmarks

-- 2. Variance Investigation
--    - Establish variance thresholds for automated alerts
--    - Implement root cause analysis procedures
--    - Create corrective action tracking

-- 3. Forecasting and Planning
--    - Use historical data for budget preparation
--    - Implement rolling forecasts for dynamic planning
--    - Scenario analysis for strategic decision making

-- SAMPLE EXECUTIVE DASHBOARD QUERY:
-- Business Question: "What are our key financial KPIs for executive reporting?"

WITH financial_kpis AS (
    SELECT 
        -- Revenue metrics
        (SELECT SUM(credit_amount - debit_amount) 
         FROM general_ledger gl JOIN chart_of_accounts coa ON gl.account_id = coa.account_id 
         WHERE coa.account_type = 'Revenue' AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30') as ytd_revenue,
         
        (SELECT SUM(credit_amount - debit_amount) 
         FROM general_ledger gl JOIN chart_of_accounts coa ON gl.account_id = coa.account_id 
         WHERE coa.account_type = 'Revenue' AND gl.transaction_date BETWEEN '2024-06-01' AND '2024-06-30') as current_month_revenue,
         
        -- Expense metrics
        (SELECT SUM(debit_amount - credit_amount) 
         FROM general_ledger gl JOIN chart_of_accounts coa ON gl.account_id = coa.account_id 
         WHERE coa.account_type = 'Expense' AND gl.transaction_date BETWEEN '2024-01-01' AND '2024-06-30') as ytd_expenses,
         
        -- Cash position
        (SELECT SUM(debit_amount - credit_amount) 
         FROM general_ledger gl JOIN chart_of_accounts coa ON gl.account_id = coa.account_id 
         WHERE coa.account_code = '1110' AND gl.transaction_date <= '2024-06-30') as cash_balance,
         
        -- Budget performance
        (SELECT SUM(budget_amount) 
         FROM budget b JOIN chart_of_accounts coa ON b.account_id = coa.account_id 
         WHERE coa.account_type = 'Revenue' AND b.fiscal_year = 2024 AND b.fiscal_period <= 6) as ytd_revenue_budget
)

SELECT 
    'FINANCIAL DASHBOARD - YTD June 2024' as dashboard_title,
    ROUND(ytd_revenue, 0) || ' YTD Revenue' as revenue_summary,
    ROUND(ytd_expenses, 0) || ' YTD Expenses' as expense_summary,
    ROUND(ytd_revenue - ytd_expenses, 0) || ' Net Income' as profit_summary,
    ROUND(cash_balance, 0) || ' Cash Position' as cash_summary,
    ROUND((ytd_revenue - ytd_revenue_budget) * 100.0 / ytd_revenue_budget, 1) || '% Revenue vs Budget' as budget_performance,
    ROUND((ytd_revenue - ytd_expenses) * 100.0 / ytd_revenue, 1) || '% Net Margin' as profitability_summary,
    ROUND(current_month_revenue, 0) || ' June Revenue' as current_month_summary

FROM financial_kpis;

-- ============================================
-- CLEANUP AND MAINTENANCE
-- ============================================

-- Note: In production environments, consider implementing:
-- 1. Regular financial close procedures and period-end adjustments
-- 2. Automated reconciliation processes for key accounts
-- 3. Performance monitoring for complex financial queries
-- 4. Regular backup and archival of historical financial data

-- ============================================
-- END OF FINANCIAL REPORTING EXAMPLES
-- ============================================