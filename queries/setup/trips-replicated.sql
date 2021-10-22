set max_partitions_per_insert_block=1000;
set max_memory_usage=20000000000000;

-- Create Replicated MergeTree tables on the cluster
CREATE TABLE IF NOT EXISTS test.trips_replica ON CLUSTER 'cluster_1'
(
    `vendor_id`                 String,
    `pickup_datetime`           DateTime,
    `tpep_dropoff_datetime`     Nullable(DateTime),
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
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{layer}-{shard}/trips_replica', '{replica}')
ORDER BY (pickup_datetime);

--- Create the distributed table
CREATE TABLE IF NOT EXISTS test.trips_dist  ON CLUSTER 'cluster_1' (
    `vendor_id`                 String,
    `pickup_datetime`           DateTime,
    `tpep_dropoff_datetime`     Nullable(DateTime),
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
 ) ENGINE = Distributed(cluster_1, test, trips_replica, rand());

-- Populate the table with data from the trips_import tables
insert into test.trips_dist select
    `vendor_id`             AS `vendor_id`,
    `pickup_datetime`       AS `pickup_datetime`,
    `ropoff_datetime`       AS `tpep_dropoff_datetime`,
    `passenger_count`       AS `passenger_count`,
    `trip_distance`         AS `trip_distance`,
    `rate_code_id`          AS `rate_code_id`,
    `store_and_fwd_flag`    AS `store_and_fwd_flag`,
    `PULocationID`          AS `PULocationID`,
    `DOLocationID`          AS `DOLocationID`,
    `payment_type`          AS `payment_type`,
    `fare_amount`           AS `fare_amount`,
    `extra`                 AS `extra`,
    `mta_tax`               AS `mta_tax`,
    `tip_amount`            AS `tip_amount`,
    `tolls_amount`          AS `tolls_amount`,
    `improvement_surcharge` AS `improvement_surcharge`,
    `total_amount`          AS `total_amount`,
    `congestion_surcharge`  AS `congestion_surcharge`
    FROM test.trips_import
