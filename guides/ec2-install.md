# Ec2 Install

The following guide will walk you through setting up clickhouse and zookeeper nodes on EC2.

Create a launch template with the following:

* OS - Ubuntu 20.04
* Instance Type - C5d.9xlarge (36 vCPU, 72 GiB Memory)
* Disk - EBS gp3, 3000 IOPS ([formatted to ext4](https://askubuntu.com/questions/44908/what-is-the-difference-between-ext3-ext4-from-a-generic-users-perspective)),
* Security Groups:
  * Full access within the group
  * Opened port 22 to public access (for ssh access), a [AWS key-pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) was used for authentication.

Create an [auto scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html), and set the desired number of instances to 3.

Launch the groups and wait a moment for the instances to spin up.

## Clickhouse installation guide

Execute the following steps on **all nodes**, notice the remarks, some files will need to be adjusted based on the node you are running on.

It's recommended to `ssh` to all nodes and run the following sections at once.

### Setting nodes identity and hostnames

We will setup the hostnames and `/etc/hosts/` configuration on all nodes.
This will allow us to reference the nodes by hostname instead of by IP, this is useful incase a node is recycled and the public IP changes.
We can then change the `/etc/hosts` file with the new IP and both clickhouse and zookeeper will pick up the new setting.

Run the following, supply a unique node name on each physical instance:

```shell
hostnamectl set-hostname node[Supply your identifier here!]
```

Update the `/etc/hosts` file with the following configuration:

```shell
127.0.0.1 node1 localhost # Add the hostname you set here before the localhost name, this will ensure that clickhouse identifies itself as this node

xxx.yyy.zzz.www node2 # Update with the public IPv4 address of node2
XXX.YYY.ZZZ.WWW node3 # Update with the public IPv4 address of node2
```

This file will be different on each node, the other 2 nodes in the cluster should be specified and the `127.0.0.1` address should be mapped to the hostname you defined in the previous step.

### Installing zookeeper

We'll now install java8 and zookeeper on all nodes

```shell
apt install openjdk-8-jre-headless
useradd -m zookeeper
cd /home/zookeeper/
wget https://apache.mivzakim.net/zookeeper/zookeeper-3.6.3/apache-zookeeper-3.6.3-bin.tar.gz
chown zookeeper:zookeeper apache-zookeeper-3.6.3-bin.tar.gz
tar -xvf apache-zookeeper-3.6.3-bin.tar.gz

# Create needed Dirs
mkdir /var/lib/zookeeper;mkdir /var/log/zookeeper

# On each node enter a unique integer ID (usually 1,2,3 depending on the node)
echo '$node ID' > /var/lib/zookeeper/myid

cd /home/zookeeper/apache-zookeeper-3.6.3-bin/conf/
cp zoo_sample.cfg zoo.cfg
```

Update the following in the `zoo.cfg` file:

* Change the `datadir` key to `/var/lib/zookeeper`
* Add the server identities, the node you are running on should have an IP of `0.0.0.0:2888:3888`, for example the file on `node1` should look like:

```shell
server.1=0.0.0.0:2888:3888
server.2=node2:2888:3888
server.3=node3:2888:3888
```

Update the following in the `log4j.properties` file:

* `zookeeper.log.dir` to `/var/log/zookeeper`

Start zookeeper and check status:

```shell
./bin/zkServer.sh start
./bin/zkServer.sh status
```

You should see an output similar to this (one instance should have the mode set as `leader`):

```/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /home/zookeeper/apache-zookeeper-3.6.3-bin/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower
```

### Installing Clickhouse

```shell
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4
echo "deb http://repo.yandex.ru/clickhouse/deb/stable/ main/" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt update
sudo apt install clickhouse-server clickhouse-client

# You will be prompted to set a default password here (click)
sudo service clickhouse-server start
sudo service clickhouse-server status

# Start client
clickhouse-client --password
```

Copy the files from the [configs](../configs/) directory to `/etc/clickhouse-server/config.d/` on each instance.
In the `macros.xml` file, change the values per each node, so that each node has unique identifiers, for example:

***node1***

```xml
<yandex>
    <macros>
        <replica>node1</replica>
        <shard>01</shard>
        <layer>01</layer>
    </macros>
</yandex>
```

***node2***

```xml
<yandex>
    <macros>
        <replica>node2</replica>
        <shard>02</shard>
        <layer>02</layer>
    </macros>
</yandex>
```

Run the following to update the changes:

```shell
sudo service clickhouse-server restart
```

### Confirm setup

Connect to the `clickhouse-client` and confirm cluster setup.

```shell
clickhouse-client
select * from system.clusters where cluster='cluster_1' format Vertical
```

You should receive and output similar to:

```shell
SELECT *
FROM system.clusters
WHERE cluster = 'cluster_1'
FORMAT Vertical

Query id: a41c7e53-c5c8-4382-80b6-cc149c3090cc

Row 1:
──────
cluster:                 cluster_1
shard_num:               1
shard_weight:            1
replica_num:             1
host_name:               node1
host_address:            127.0.0.1
port:                    9000
is_local:                1
user:                    default
default_database:
errors_count:            0
slowdowns_count:         0
estimated_recovery_time: 0

Row 2:
──────
cluster:                 cluster_1
shard_num:               2
shard_weight:            1
replica_num:             1
host_name:               node2
host_address:            34.204.99.65
port:                    9000
is_local:                0
user:                    default
default_database:
errors_count:            0
slowdowns_count:         0
estimated_recovery_time: 0

Row 3:
──────
cluster:                 cluster_1
shard_num:               3
shard_weight:            1
replica_num:             1
host_name:               node3
host_address:            54.89.121.55
port:                    9000
is_local:                0
user:                    default
default_database:
errors_count:            0
slowdowns_count:         0
estimated_recovery_time: 0
```

Congratulations! You now have a clickhouse cluster up and running!

Refer to the [README.md](../README.md) to setup some tables and import data.
