CREATE STREAMING TABLE order_bronze
AS
SELECT *,
       _metadata.file_name AS file_name,
       current_timestamp() AS ingest_date
FROM STREAM(read_files(
   '/Volumes/nbn_catalog/sales_schema/sales_volume/orders/',
   format => 'csv'
));

CREATE STREAMING TABLE order_silver_cleaned (
  CONSTRAINT valid_order EXPECT(order_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_customer EXPECT(cust_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_amount EXPECT(order_amount > 0)
)
AS
SELECT orderid as order_id,
      customerid as cust_id,
      orderdate as order_date,
      order_amount,
      order_status,
      file_name,
      ingest_date as load_time
FROM STREAM(order_bronze);

--fact table - apply scd type 1
CREATE STREAMING TABLE order_silver;

APPLY CHANGES INTO order_silver
FROM STREAM(order_silver_cleaned)
KEYS(order_id)
SEQUENCE BY load_time;