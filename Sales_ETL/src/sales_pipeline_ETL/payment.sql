CREATE STREAMING TABLE payment_bronze
AS
SELECT *,
      _metadata.file_name as file_name,
      current_timestamp() as load_time
FROM STREAM(read_files(
      '/Volumes/nbn_catalog/sales_schema/sales_volume/payment/',
      format => 'csv'
));

CREATE STREAMING TABLE payment_silver_cleaned(
  CONSTRAINT valid_order EXPECT(order_id is NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_payment EXPECT(payment_id is NOT NULL) ON VIOLATION DROP ROW
) 
AS
SELECT * EXCEPT (_rescued_data)
FROM STREAM(payment_bronze)
WHERE payment_status IN ('SUCCESS','FAILED');

--Implement scd type 1
CREATE STREAMING TABLE payment_silver;

CREATE FLOW payment_silver_flow AS AUTO CDC INTO payment_silver
FROM STREAM(payment_silver_cleaned)
keys(payment_id)
sequence by load_time
Stored as scd type 1;


