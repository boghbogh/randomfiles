-- Create database and schema structure
CREATE DATABASE privacy_demo;
CREATE SCHEMA privacy_demo.sensitive_data;
CREATE SCHEMA privacy_demo.policies;

-- Create roles for different access levels
CREATE ROLE data_analyst;
CREATE ROLE external_partner;
CREATE ROLE privacy_admin;
CREATE ROLE internal_analyst;

GRANT ALL PRIVILEGES ON SCHEMA privacy_demo.policies TO ROLE privacy_admin;


-- Sample customer transaction table
CREATE TABLE privacy_demo.sensitive_data.customer_transactions (
    transaction_id VARCHAR(50),
    customer_id VARCHAR(50),
    transaction_date DATE,
    amount DECIMAL(10,2),
    category VARCHAR(50),
    store_location VARCHAR(100),
    customer_age_group VARCHAR(20),
    customer_income_bracket VARCHAR(30)
);

-- Insert sample data
INSERT INTO privacy_demo.sensitive_data.customer_transactions VALUES
('TXN001', 'CUST001', '2024-01-15', 125.50, 'Electronics', 'New York - Manhattan', '25-34', '50K-75K'),
('TXN002', 'CUST002', '2024-01-15', 89.99, 'Clothing', 'New York - Manhattan', '35-44', '75K-100K'),
('TXN003', 'CUST003', '2024-01-16', 234.75, 'Electronics', 'New York - Brooklyn', '25-34', '50K-75K'),
('TXN004', 'CUST004', '2024-01-16', 45.20, 'Groceries', 'New York - Manhattan', '45-54', '75K-100K'),
('TXN005', 'CUST005', '2024-01-17', 156.80, 'Clothing', 'New York - Queens', '25-34', '100K+'),
('TXN006', 'CUST001', '2024-01-17', 67.30, 'Groceries', 'New York - Manhattan', '25-34', '50K-75K'),
('TXN007', 'CUST006', '2024-01-18', 298.45, 'Electronics', 'New York - Brooklyn', '35-44', '100K+'),
('TXN008', 'CUST007', '2024-01-18', 78.90, 'Clothing', 'New York - Queens', '25-34', '50K-75K'),
('TXN009', 'CUST008', '2024-01-19', 189.60, 'Electronics', 'New York - Manhattan', '45-54', '75K-100K'),
('TXN010', 'CUST009', '2024-01-19', 112.25, 'Groceries', 'New York - Brooklyn', '35-44', '50K-75K'),
('TXN011', 'CUST010', '2024-01-20', 445.80, 'Electronics', 'New York - Queens', '25-34', '100K+'),
('TXN012', 'CUST002', '2024-01-20', 23.50, 'Groceries', 'New York - Manhattan', '35-44', '75K-100K');





-- Switch to privacy admin role
GRANT ROLE privacy_admin TO USER BOGHBOGH;
USE ROLE privacy_admin;
USE SCHEMA privacy_demo.policies;

-- Basic aggregation policy for external partners
CREATE AGGREGATION POLICY external_partner_policy 
AS () RETURNS AGGREGATION_CONSTRAINT -> 
AGGREGATION_CONSTRAINT(MIN_GROUP_SIZE => 5);

-- Advanced conditional policy based on role
CREATE AGGREGATION POLICY role_based_privacy_policy 
AS () RETURNS AGGREGATION_CONSTRAINT -> 
CASE 
    WHEN CURRENT_ROLE() = 'INTERNAL_ANALYST' 
        THEN NO_AGGREGATION_CONSTRAINT()
    WHEN CURRENT_ROLE() = 'DATA_ANALYST' 
        THEN AGGREGATION_CONSTRAINT(MIN_GROUP_SIZE => 3)
    ELSE AGGREGATION_CONSTRAINT(MIN_GROUP_SIZE => 8)
END;

-- Entity-level privacy policy for customer protection
CREATE AGGREGATION POLICY customer_entity_privacy 
AS () RETURNS AGGREGATION_CONSTRAINT -> 
AGGREGATION_CONSTRAINT(MIN_GROUP_SIZE => 4);



-- Apply the conditional policy to our transaction table
ALTER TABLE privacy_demo.sensitive_data.customer_transactions 
SET AGGREGATION POLICY privacy_demo.policies.role_based_privacy_policy;


-- Grant necessary permissions
GRANT USAGE ON DATABASE privacy_demo TO ROLE external_partner;
GRANT USAGE ON SCHEMA privacy_demo.sensitive_data TO ROLE external_partner;
GRANT SELECT ON TABLE privacy_demo.sensitive_data.customer_transactions TO ROLE external_partner;


GRANT ROLE external_partner TO USER BOGHBOGH;
USE ROLE external_partner;


SELECT 
    category,
    customer_age_group,
    COUNT(*) as transaction_count,
    AVG(amount) as avg_amount
FROM privacy_demo.sensitive_data.customer_transactions
GROUP BY category, customer_age_group
HAVING COUNT(*) >= 8;

 SELECT * FROM privacy_demo.sensitive_data.customer_transactions LIMIT 10;


 GRANT ROLE internal_analyst TO USER BOGHBOGH;

 
USE ROLE internal_analyst;
SELECT * FROM privacy_demo.sensitive_data.customer_transactions LIMIT 10;
