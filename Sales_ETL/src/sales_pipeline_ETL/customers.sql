CREATE STREAMING TABLE customer_bronze
AS
SELECT *,
        _metadata.file_name as file_name,
        current_timestamp() as ingest_time
FROM STREAM(read_files(
  '/Volumes/nbn_catalog/sales_schema/sales_volume/customers/',
  format => 'csv'
));

CREATE STREAMING TABLE customer_silver_cleaned(
  CONSTRAINT valid_customer EXPECT(cust_id is NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_customer_since EXPECT(customer_since is NOT NULL)
)
AS
SELECT customer_id as cust_id,
       customer_name,
       email,
       city,
       created_date as customer_since,
       file_name,
       ingest_time as load_time
FROM STREAM(customer_bronze);

--Implement SCD Type 2 as Customer is dim table
CREATE STREAMING TABLE customer_silver;

CREATE FLOW customer_silver_flow AS 
AUTO CDC INTO customer_silver
--APPLY CHANGES INTO customer_silver
FROM STREAM(customer_silver_cleaned)
KEYS(cust_id)
SEQUENCE BY load_time
STORED AS SCD TYPE 2;
