#!/bin/bash

SCRIPT_LOCATION=$(dirname "$0")

clickhouse-client --host node1 --queries-file=/queries/setup/trips_import.sql

COUNT=$(clickhouse-client --host node1 --query="select count(*) from test.trips_import")

if [[ $COUNT -eq 0 ]]; then
  echo "Creating test data table for parquet import"

  SCRIPT_LOCATION=$(dirname "$0")

  if [ ! -f "$SCRIPT_LOCATION/../dataset/yellow_tripdata_2020-01" ]; then
    wget --timestamping https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2020-01.csv -P "$SCRIPT_LOCATION/../dataset/"
  fi

  for filename in $SCRIPT_LOCATION/../dataset/yellow_tripdata*.csv; do
    echo "Inserting data from CSV to clickhouse table (test.trips_import)"
    # Clickhouse has issues handling the first row, so we skip it
    tail -n +2 "$SCRIPT_LOCATION"/../dataset/"$filename" |
      python "$SCRIPT_LOCATION"/handle_nulls.py |
      clickhouse-client --host node1 --query="INSERT INTO test.trips_import FORMAT CSV"
  done

  clickhouse-client --host node1 --queries-file=/queries/setup/trips-replicated.sql
  echo "Test data imported, creating replicated and distributed tables"
else
  echo "Test data is already imported, skipping importing again."
  echo "If want to start fresh run the following:"
  echo 'clickhouse-client --host node1 --query="drop database test"'
fi

echo "Done!"
