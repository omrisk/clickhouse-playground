# Clickhouse POC

## Background

[Clickhouse](https://clickhouse.tech/) is a big data warehouse used by Yandex to analyze click stream data.

We examined it at Dynamic Yield to see if it could be a potential candidate to help us address issues in the analytics space.

The POC itself was conducted on an internal AWS account, this repo is to allow:

1. Simulating a similar cluster topology for local testing
2. Track the queries used for the benchmark and the creation of the cluster
3. The internal benchmark queries were run on a private dataset and are not included here.

## Resources

We used 3 C5d.9xlarge instances (36 vCPU/ 70Gbs RAM).
GP3 disks were used as ephemeral disks with 2 TBs of storage.

## Topology

* 3 Clickhouse Master nodes
* 3 zookeeper nodes (deployed on the clickhouse physical nodes)

## Setup on AWS account

As a POC performed on an external account, the cluster setup in EC2 was done manually.
3 C5d.9xlarge instances were started with a permissive security group applied to allow full communication between instances.

A guide to the manual installation steps can be found [here](./guides/ec2-install.md).

### Caveats

* To simplify the deployment [zookeeper](https://zookeeper.apache.org/) nodes were deployed on the same nodes as the clickhouse nodes.

## Local Docker environment

To allow local experimentation you a docker-compose file is provided.
Run the following to spin up a cluster:

```shell
docker-compose up
```

You can then connect to the cluster using the [clickhouse-client](https://clickhouse.tech/docs/en/interfaces/cli/).

```shell
docker exec -it client /bin/bash
root@client:/# clickhouse-client  --host node1
ClickHouse client version 21.6.5.37 (official build).
Connecting to node1:9000 as user default.
Connected to ClickHouse server version 21.6.5 revision 54448.

node1 :)
```

You can now begin work with the clickhouse cluster.

### Setting up a Sample data set

A normalized data set is available on the  `[New York City government site](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page)`.
Run the following steps script to download and normalize the data set.

```shell
./scripts/prepare-datasets.sh
```

You can setup the needed tables by running:

```shell
docker exec -it client /bin/bash

./scripts/setup-ch.s

```

Confirm by running:

```shell
clickhouse-client --host node1
select count(*) from test.trips_import
```

You should see an output similar to

```shell
SELECT count(*)
FROM test.trips_import

Query id: 0609950b-5979-4471-8ef4-b740ff974ede

┌─count()─┐
│ 6405008 │
└─────────┘

1 rows in set. Elapsed: 0.017 sec. Processed 6.41 million rows, 12.81 MB (377.82 million rows/s., 755.64 MB/s.)
```

See the [schema file](queries/setup/trips_import.sql) for reference to the file/table schema.

## Benchmarks

* The [clickhouse-benchmark](https://clickhouse.tech/docs/en/operations/utilities/clickhouse-benchmark/) tool was used to submit queries concurrently.
* [Glances](https://nicolargo.github.io/glances/) was used to sample CPU and memory usage.

Sample Queries can be found in the [queries directory](./queries/).
