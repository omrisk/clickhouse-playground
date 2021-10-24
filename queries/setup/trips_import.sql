CREATE DATABASE IF NOT EXISTS test ON CLUSTER cluster_1;
CREATE TABLE IF NOT EXISTS test.trips_import (
    `vendor_id`                 String,
    `pickup_datetime`           DateTime,
    `ropoff_datetime`           Nullable(DateTime),
    `passenger_count`           Nullable(UInt8),
    `trip_distance`             Nullable(Float64),
    `rate_code_id`              Nullable(UInt8),
    `store_and_fwd_flag`        Nullable(FixedString(1)),
    `PULocationID`              Nullable(UInt8),
    `DOLocationID`              Nullable(UInt8),
    `payment_type`              Nullable(String),
    `fare_amount`               Nullable(Float32),
    `extra`                     Nullable(Float32),
    `mta_tax`                   Nullable(Float32),
    `tip_amount`                Nullable(Float32),
    `tolls_amount`              Nullable(Float32),
    `improvement_surcharge`     Nullable(Float32),
    `total_amount`              Nullable(Float32),
    `congestion_surcharge`      Nullable(Float32)
) ENGINE = Log;
