# How to benchmark Clickhouse queries

To benchmark clickhouse performance we could use the [built-in clickhouse benchmark tool](https://clickhouse.tech/docs/en/operations/utilities/clickhouse-benchmark/).

## How to run

1. Each query should be a single line in the query file. You can copy one query from the example queries file [queries.sql](./queries.sql), into a new file `benchmark-query.sql` and make sure the query is in one line (in vim, use `:%s/\n/\s/g`). First query is already prepared in the [benchmark-query.sql](./benchmark-query.sql).
2. Ensure the last character is a newline `\n`
3. Run

```shell
clickhouse-benchmark -c 5 -i 20 --host node1 --distributed_product_mode='local' --json=results.json < benchmark-query.sql
```
