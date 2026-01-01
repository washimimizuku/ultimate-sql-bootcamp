-- SQL TRANSACTIONS Examples - Advanced SQL Concepts
-- This file demonstrates transaction management and ACID properties in SQL
-- Transactions ensure data integrity by grouping operations into atomic units
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-7-advanced-sql/transactions.sql
-- ============================================

-- TRANSACTION CONCEPTS:
-- - ACID Properties: Atomicity, Consistency, Isolation, Durability
-- - Atomicity: All operations in a transaction succeed or all fail
-- - Consistency: Database remains in a valid state before and after transaction
-- - Isolation: Concurrent transactions don't interfere with each other
-- - Durability: Committed changes persist even after system failure

-- TRANSACTION SYNTAX:
-- BEGIN TRANSACTION;        -- Start a transaction
-- COMMIT;                   -- Save all changes permanently
-- ROLLBACK;                 -- Undo all changes since BEGIN

-- TRANSACTION ISOLATION LEVELS:
-- - READ UNCOMMITTED: Lowest isolation, allows dirty reads
-- - READ COMMITTED: Prevents dirty reads, allows non-repeatable reads
-- - REPEATABLE READ: Prevents dirty and non-repeatable reads, allows phantom reads
-- - SERIALIZABLE: Highest isolation, prevents all phenomena

-- NOTE: DuckDB does not support SQL savepoint syntax (SAVEPOINT, ROLLBACK TO)
-- Savepoints are available through programming APIs but not SQL commands
-- For partial rollbacks, use separate transactions or conditional logic

-- Database exploration
SHOW TABLES;

-- =====================================================
-- SETUP: CREATE DEMONSTRATION TABLES
-- =====================================================

-- Create temporary tables for transaction demonstrations
CREATE TEMPORARY TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    account_name VARCHAR(50),
    balance DECIMAL(10,2),
    account_type VARCHAR(20)
);

CREATE TEMPORARY TABLE transaction_log (
    log_id INTEGER,
    account_id INTEGER,
    transaction_type VARCHAR(20),
    amount DECIMAL(10,2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(100)
);

-- Insert sample data
INSERT INTO accounts VALUES 
    (1, 'Alice Johnson', 1000.00, 'Checking'),
    (2, 'Bob Smith', 2500.00, 'Savings'),
    (3, 'Carol Davis', 750.00, 'Checking'),
    (4, 'David Wilson', 5000.00, 'Savings'),
    (5, 'Eve Brown', 1200.00, 'Checking');

-- Show initial state
SELECT 'Initial Account Balances:' as info;
SELECT * FROM accounts ORDER BY account_id;

-- =====================================================
-- BASIC TRANSACTION EXAMPLES
-- =====================================================

-- Example 1: Simple Transaction - Transfer Money Between Accounts
-- Demonstrate basic BEGIN, COMMIT pattern
SELECT 'Example 1: Basic Money Transfer' as example;

BEGIN TRANSACTION;

-- Transfer $200 from Alice (account 1) to Bob (account 2)
UPDATE accounts SET balance = balance - 200.00 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 200.00 WHERE account_id = 2;

-- Log the transactions
INSERT INTO transaction_log (log_id, account_id, transaction_type, amount, description) VALUES
    (1, 1, 'DEBIT', 200.00, 'Transfer to account 2'),
    (2, 2, 'CREDIT', 200.00, 'Transfer from account 1');

-- Check balances before commit
SELECT 'Balances during transaction:' as info;
SELECT account_id, account_name, balance FROM accounts WHERE account_id IN (1, 2);

COMMIT;

-- Show final balances after commit
SELECT 'Balances after commit:' as info;
SELECT account_id, account_name, balance FROM accounts WHERE account_id IN (1, 2);

-- Example 2: Transaction Rollback - Insufficient Funds
-- Demonstrate ROLLBACK when business rules are violated
SELECT 'Example 2: Transaction Rollback (Insufficient Funds)' as example;

BEGIN TRANSACTION;

-- Attempt to transfer $2000 from Carol (account 3) who only has $750
UPDATE accounts SET balance = balance - 2000.00 WHERE account_id = 3;

-- Check if balance went negative (business rule violation)
SELECT 'Balance after attempted withdrawal:' as info;
SELECT account_id, account_name, balance FROM accounts WHERE account_id = 3;

-- Business rule: Don't allow negative balances - rollback the transaction
ROLLBACK;

-- Show balance after rollback (should be unchanged)
SELECT 'Balance after rollback:' as info;
SELECT account_id, account_name, balance FROM accounts WHERE account_id = 3;

-- =====================================================
-- ALTERNATIVE TO SAVEPOINTS: SEPARATE TRANSACTIONS
-- =====================================================

-- Example 3: Multiple Transactions for Complex Operations
-- Since DuckDB doesn't support savepoints, use separate transactions
SELECT 'Example 3: Multiple Transactions (Alternative to Savepoints)' as example;

-- Transaction 1: First transfer (will be committed)
BEGIN TRANSACTION;

-- Transfer $100 from David to Eve
UPDATE accounts SET balance = balance - 100.00 WHERE account_id = 4;
UPDATE accounts SET balance = balance + 100.00 WHERE account_id = 5;

-- Log the transaction
INSERT INTO transaction_log (log_id, account_id, transaction_type, amount, description) VALUES
    (3, 4, 'DEBIT', 100.00, 'Transfer to account 5'),
    (4, 5, 'CREDIT', 100.00, 'Transfer from account 4');

COMMIT;

SELECT 'First transaction committed' as info;

-- Transaction 2: Second transfer (will be committed)
BEGIN TRANSACTION;

-- Transfer $300 from David to Carol
UPDATE accounts SET balance = balance - 300.00 WHERE account_id = 4;
UPDATE accounts SET balance = balance + 300.00 WHERE account_id = 3;

-- Log the transaction
INSERT INTO transaction_log (log_id, account_id, transaction_type, amount, description) VALUES
    (5, 4, 'DEBIT', 300.00, 'Transfer to account 3'),
    (6, 3, 'CREDIT', 300.00, 'Transfer from account 4');

COMMIT;

SELECT 'Second transaction committed' as info;

-- Transaction 3: Large transfer (will be rolled back)
BEGIN TRANSACTION;

-- Attempt a large transfer that we'll decide to undo
UPDATE accounts SET balance = balance - 1000.00 WHERE account_id = 4;
UPDATE accounts SET balance = balance + 1000.00 WHERE account_id = 1;

-- Check current balances
SELECT 'Balances during large transfer:' as info;
SELECT account_id, account_name, balance FROM accounts WHERE account_id IN (1, 4);

-- Decide to abort this transaction
ROLLBACK;

SELECT 'Large transfer rolled back' as info;

-- Show final balances after separate transactions
SELECT 'Final balances after multiple transactions:' as info;
SELECT account_id, account_name, balance FROM accounts WHERE account_id IN (1, 3, 4, 5);

-- =====================================================
-- ERROR HANDLING EXAMPLES
-- =====================================================

-- Example 4: Transaction with Error Handling
-- Demonstrate how to handle errors within transactions
SELECT 'Example 4: Error Handling in Transactions' as example;

-- First, let's see what happens with a constraint violation
BEGIN TRANSACTION;

-- This will work
UPDATE accounts SET balance = balance - 50.00 WHERE account_id = 1;

-- This would cause an error if we had a constraint (simulated)
-- Let's simulate checking for an error condition
SELECT 'Checking for error conditions...' as info;

-- Simulate: Check if account exists before transfer
SELECT CASE 
    WHEN COUNT(*) = 0 THEN 'ERROR: Account not found'
    ELSE 'Account found, proceeding'
END as status
FROM accounts WHERE account_id = 999;  -- Non-existent account

-- Since account 999 doesn't exist, we should rollback
ROLLBACK;

SELECT 'Transaction rolled back due to error condition' as info;

-- =====================================================
-- BATCH PROCESSING WITH TRANSACTIONS
-- =====================================================

-- Example 5: Batch Processing with Transaction Control
-- Demonstrate processing multiple operations efficiently
SELECT 'Example 5: Batch Processing with Transactions' as example;

BEGIN TRANSACTION;

-- Process multiple account updates in a single transaction
-- Apply monthly interest to all savings accounts (2% annual = 0.167% monthly)
UPDATE accounts 
SET balance = balance * 1.00167 
WHERE account_type = 'Savings';

-- Log the interest payments
INSERT INTO transaction_log (log_id, account_id, transaction_type, amount, description)
SELECT 
    ROW_NUMBER() OVER () + 6,  -- Start from 7 since we have 6 existing records
    account_id,
    'CREDIT',
    balance * 0.00167,
    'Monthly interest payment'
FROM accounts 
WHERE account_type = 'Savings';

-- Apply monthly fee to checking accounts with low balance
UPDATE accounts 
SET balance = balance - 5.00 
WHERE account_type = 'Checking' AND balance < 1000.00;

-- Log the fees
INSERT INTO transaction_log (log_id, account_id, transaction_type, amount, description)
SELECT 
    ROW_NUMBER() OVER () + 8,  -- Continue numbering
    account_id,
    'DEBIT',
    5.00,
    'Monthly maintenance fee'
FROM accounts 
WHERE account_type = 'Checking' AND balance < 1000.00;

COMMIT;

-- Show results of batch processing
SELECT 'Account balances after batch processing:' as info;
SELECT * FROM accounts ORDER BY account_id;

-- =====================================================
-- TRANSACTION ISOLATION DEMONSTRATION
-- =====================================================

-- Example 6: Demonstrating Transaction Isolation
-- Note: This example shows concepts, but full isolation testing requires multiple connections
SELECT 'Example 6: Transaction Isolation Concepts' as example;

-- Create a test scenario for isolation
CREATE TEMPORARY TABLE isolation_test (
    id INTEGER PRIMARY KEY,
    value INTEGER,
    description VARCHAR(50)
);

INSERT INTO isolation_test VALUES (1, 100, 'Test value');

-- Transaction 1: Long-running transaction
BEGIN TRANSACTION;

-- Read initial value
SELECT 'Transaction 1 - Initial read:' as info;
SELECT * FROM isolation_test WHERE id = 1;

-- Simulate some processing time with a complex query
SELECT 'Transaction 1 - Processing...' as info;

-- Update the value
UPDATE isolation_test SET value = 200 WHERE id = 1;

-- In a real multi-user scenario, another transaction might try to read/modify this data
-- The isolation level would determine what that transaction sees

SELECT 'Transaction 1 - After update (before commit):' as info;
SELECT * FROM isolation_test WHERE id = 1;

COMMIT;

SELECT 'Transaction 1 - After commit:' as info;
SELECT * FROM isolation_test WHERE id = 1;

-- =====================================================
-- DEADLOCK PREVENTION EXAMPLE
-- =====================================================

-- Example 7: Deadlock Prevention Strategy
-- Demonstrate ordering resources to prevent deadlocks
SELECT 'Example 7: Deadlock Prevention Strategy' as example;

-- Best practice: Always acquire locks in the same order
-- Transfer between accounts by always locking lower account_id first

BEGIN TRANSACTION;

-- Transfer from account 5 to account 2 (higher to lower ID)
-- Good practice: Lock accounts in ID order (2, then 5) to prevent deadlocks
SELECT 'Locking accounts in order: 2, then 5' as info;

-- Update lower ID first
UPDATE accounts SET balance = balance + 150.00 WHERE account_id = 2;
-- Then update higher ID
UPDATE accounts SET balance = balance - 150.00 WHERE account_id = 5;

-- Log the transaction
INSERT INTO transaction_log (log_id, account_id, transaction_type, amount, description) VALUES
    (11, 5, 'DEBIT', 150.00, 'Transfer to account 2'),
    (12, 2, 'CREDIT', 150.00, 'Transfer from account 5');

COMMIT;

SELECT 'Transfer completed successfully' as info;

-- =====================================================
-- TRANSACTION PERFORMANCE CONSIDERATIONS
-- =====================================================

-- Example 8: Transaction Size and Performance
-- Demonstrate the impact of transaction size on performance
SELECT 'Example 8: Transaction Performance Considerations' as example;

-- Small, focused transaction (GOOD)
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance + 1.00 WHERE account_id = 1;
INSERT INTO transaction_log (log_id, account_id, transaction_type, amount, description) 
VALUES (13, 1, 'CREDIT', 1.00, 'Small transaction test');
COMMIT;

-- Show transaction log summary
SELECT 'Transaction Log Summary:' as info;
SELECT 
    transaction_type,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount
FROM transaction_log 
GROUP BY transaction_type
ORDER BY transaction_type;

-- =====================================================
-- ADVANCED TRANSACTION PATTERNS
-- =====================================================

-- Example 9: Conditional Transactions
-- Demonstrate business logic within transactions
SELECT 'Example 9: Conditional Transaction Logic' as example;

BEGIN TRANSACTION;

-- Check account balance before proceeding
SELECT 'Checking account balance for conditional logic...' as info;

-- Use a conditional update based on current balance
UPDATE accounts 
SET balance = CASE 
    WHEN balance >= 500.00 THEN balance - 100.00
    ELSE balance
END
WHERE account_id = 3;

-- Check if the update actually happened
SELECT 
    CASE 
        WHEN balance >= 400.00 THEN 'Transaction executed - sufficient funds'
        ELSE 'Transaction skipped - insufficient funds'
    END as transaction_result,
    balance
FROM accounts 
WHERE account_id = 3;

COMMIT;

-- =====================================================
-- CLEANUP: REMOVE DEMONSTRATION TABLES
-- =====================================================

SELECT 'Final account balances before cleanup:' as info;
SELECT * FROM accounts ORDER BY account_id;

SELECT 'Final transaction log:' as info;
SELECT * FROM transaction_log ORDER BY log_id;

-- Clean up temporary tables
DROP TABLE transaction_log;
DROP TABLE accounts;
DROP TABLE isolation_test;

SELECT 'Cleanup completed - all temporary tables removed' as info;

-- =====================================================
-- TRANSACTION BEST PRACTICES SUMMARY
-- =====================================================

-- BEST PRACTICES:
-- 1. Keep transactions as short as possible to reduce lock contention
-- 2. Always handle errors and use appropriate rollback strategies
-- 3. Use savepoints for complex multi-step operations
-- 4. Acquire locks in consistent order to prevent deadlocks
-- 5. Choose appropriate isolation levels based on consistency requirements
-- 6. Test transaction logic thoroughly, especially error conditions
-- 7. Monitor transaction performance and optimize long-running operations
-- 8. Use batch processing for multiple related operations
-- 9. Implement proper error handling and logging
-- 10. Consider the impact of transaction size on system performance

-- COMMON PITFALLS TO AVOID:
-- ✗ Long-running transactions that hold locks too long
-- ✗ Forgetting to handle error conditions and rollback appropriately
-- ✗ Inconsistent lock ordering leading to deadlocks
-- ✗ Using inappropriate isolation levels for the use case
-- ✗ Not testing rollback scenarios thoroughly
-- ✗ Mixing DDL and DML operations in the same transaction
-- ✗ Not monitoring transaction performance and resource usage
-- ✗ Assuming savepoint support (DuckDB doesn't support SQL savepoint syntax)