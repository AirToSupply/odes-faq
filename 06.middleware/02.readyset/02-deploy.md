# 容器化部署和测试验证

​		该部署方式用于容器化环境下的快速部署。下面通过readyset代理到postgres数据库为例，且部署模式为本地local（数据库容器和readyset容器在同一个服务器中）。

## 一.启动数据库

​		readyset服务启动重要的先觉条件是基于一个已经存在的数据库。这里尝试通过readyset连接postgres数据库为例，现在通过Docker启动postgres服务。

```shell
docker run -d \
--name=postgres \
--publish=5432:5432 \
-e POSTGRES_PASSWORD=readyset \
-e POSTGRES_DB=testdb \
postgres:14 \
-c wal_level=logical
```

【注意】

​		（1）对于readyset侧来说，推荐postgres数据库版本推荐至少是14+，postgres版本13版本以下并未验证。

​		（2）被readyset服务所代理的postgres数据库必须开启binlog，因为readyset在启动之后需要复制数据库的replica stream（可以理解为数据库binlog event事件），对于Docker化部署需要设置参数**wal_level**为**logical**。

​		

​		启动数据库之后，通过客户端命令验证数据库是否可以连通，这里连接所创建的testdb数据库。

```shell
psql "postgresql://postgres:readyset@127.0.0.1:5432/testdb"
```

​		如果当前节点没有postgres数据库客户端工具，需要优先下载，具体各个平台安装可以参考：[《Packages and Installers》](https://www.postgresql.org/download/)。

```shell
# MacOS
brew install postgresql@15
# Ubuntu/Debian
apt-get install postgresql-client
# CentOS（这里安装的PG13版本的源，所以指定下版本，若不指定版本则会安装9.2版本）
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install postgresql13 -y
```

## 二.准备数据集

```shell
curl -O https://github.com/readysettech/docs/blob/main/docs/assets/imdb-postgres.sql
psql "postgresql://postgres:readyset@127.0.0.1:5432/testdb" -f imdb-postgres.sql
```

## 三.启动服务

```shell
docker run -d \
--name=readyset \
--publish=5433:5433 \
--platform=linux/amd64 \
--volume='readyset:/tmp/readyset' \
--pull=always \
-e DEPLOYMENT_ENV=quickstart_github \
public.ecr.aws/readyset/readyset:beta-2023-07-26 \
--standalone \
--deployment='github-postgres' \
--database-type=postgresql \
--upstream-db-url=postgresql://postgres:readyset@<database_ip>:5432/testdb \
--address=0.0.0.0:5433 \
--username='postgres' \
--password='readyset' \
--db-dir='/tmp/readyset'
```

​		这里需要非常注意的是，由于在单台机器进行实验，并且readyset和数据库是部署在两个单独的容器内，readyset所在的容器需要连接数据库所在容器的虚拟IP地址，可以通过如下命令查找数据库容器的虚拟IP地址：

```shell
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <CONTAINER_ID>
```

​		由于是在单台机器进行实验，为了防止和postgres数据库端口冲突，这里readyset服务端口设置为5433。启动之后通过如下命令验证readyset连通性：

```shell
psql "postgresql://postgres:readyset@127.0.0.1:5433/testdb"
```

## 四.测试验证

​		在本小节【准备数据集】提供的数据集下尝试如下查询测试，这段逻辑是：将20w数据量的表和40w数据量的表进行关联并进行点茶查和范围筛选再聚合统计。

```shell
SELECT count(*) 
  FROM title_ratings
  JOIN title_basics 
    ON title_ratings.tconst = title_basics.tconst
 WHERE title_basics.startyear = 2000 
   AND title_ratings.averagerating > 5;
```

​		直连数据库进行测试：

```shell
> psql "postgresql://postgres:readyset@127.0.0.1:5432/testdb"

testdb=# \timing
启用计时功能.

testdb=# SELECT count(*) FROM title_ratings
JOIN title_basics ON title_ratings.tconst = title_basics.tconst
WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;

 count
-------
  2418
(1 行记录)

时间：62.766 ms
```

​		连接readyset进行测试：

```shell
> psql "postgresql://postgres:readyset@127.0.0.1:5433/testdb"

testdb=# \timing
启用计时功能.

testdb=> CREATE CACHE FROM SELECT count(*) FROM title_ratings
JOIN title_basics ON title_ratings.tconst = title_basics.tconst
WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;

testdb=> show caches;

         name         |                                                                                                                           query                                                                                                                            | fallback behavior
----------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------
 "q_5348e5187dbf1722" | SELECT count(*) FROM "public"."title_ratings" JOIN "public"."title_basics" ON ("public"."title_ratings"."tconst" = "public"."title_basics"."tconst") WHERE (("public"."title_basics"."startyear" = $1) AND ("public"."title_ratings"."averagerating" > 5)) | fallback allowed
 
testdb=> SELECT count(*) FROM title_ratings
JOIN title_basics ON title_ratings.tconst = title_basics.tconst
WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;
 count(*)
----------
     2418
(1 行记录)

时间：124.406 ms
testdb=> SELECT count(*) FROM title_ratings
JOIN title_basics ON title_ratings.tconst = title_basics.tconst
WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;
 count(*)
----------
     2418
(1 行记录)

时间：2.239 ms
testdb=> SELECT count(*) FROM title_ratings
JOIN title_basics ON title_ratings.tconst = title_basics.tconst
WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;
 count(*)
----------
     2418
(1 行记录)

时间：1.626 ms
```

​		可以观察直连数据库需要花费62.766ms；而到通过readyset代理在第一次查询是非常慢的，这主要是因为在冷启动情况下缓存需要加载数据进行预热，后续进行连续多次查询的耗时会急剧下降，甚至到微妙级别。



# 二进制部署

## 一.本地编译和调试模式

​		该方式通过编译源码来启动readyset服务，这种方式用于本地调试和快速调试比较友好。

### 1.前置准备

​	【准备-1】需要有rust语言runtime基础环境，因为在源码编译过程中需要通过cargo去下载各种依赖文件。

​	【准备-2】需要有正在运行的数据库服务，这里推荐postgres14+。

​	【准备-3】所在节点需要安装些依赖。

​			如果是MacOS操作系统需要安装如下依赖：

```shell
brew install lz4 openssl@1.1
```

​			如果是Ubuntu操作系统需要安装如下依赖：

```shell
sudo apt update
sudo apt install -y build-essential libssl-dev pkg-config llvm clang liblz4-dev
sudo apt-get -y install cmake
```

​			如果是CentOS操作系统需要安装如下依赖：

```shell
sudo yum -y update
sudo yum -y groupinstall "Development Tools"
sudo yum -y install clang lz4-devel openssl-devel
```

### 2.源码编译和运行

​		这里采用的是**beta-2023-07-26**这个tag对应的release版本进行源码编译。

```shell
git clone https://github.com/readysettech/readyset.git
git tag beta-2023-07-26
```

​		在readyset的家目录下，执行如下命令，编译并同时以非守护进程模式启动readyset服务：

```shell
cargo run --bin readyset --release -- \
--standalone \
--deployment="readyset-proxy-postgres" \
--upstream-db-url=postgresql://postgres:readyset@127.0.0.1:5432/testdb \
--database-type=postgresql \
--query-caching=async \
--eviction-policy=lru \
--username=postgres \
--password=readyset \
--address=0.0.0.0:5433 \
--prometheus-metrics \
--metrics-address=0.0.0.0:6034 \
--query-log \
--query-log-ad-hoc \
--db-dir=/tmp/readyset
```

​		（1）这里采用的是standalone模式，这种方式适用于本地快速测试，也就是说当在单机模式下让ReadySet Server和ReadySet Adapter在同一个进程中启动。

​		（2）--database-type表示需要指定所代理的数据库类型，目前官方仅支持MySQL和PostgreSQL两种类型的数据库。

​		（3）--upstream-db-url表示指定所代理的数据库连接字符串。

​		（4）--username和--password表示指定客户端连接ReadySet服务的用户名和密码，但是这里不是必须指定的。

​		（5）--query-caching表示ReadySet查询缓存模式，默认情况下也是async模式。这表示当时查询来临时ReadySet会自动代理到上游数据库，并自动根据规则进行查询缓存。这种方式不需要手动通过`CREATE CACHE FROM`来对指定的查询进行手动缓存，官方推荐在生产环境中explicit模式，因为这种模式可以按需缓存。这里采用async模式是为了后续的POC性能测试，因为一个用例可能跑多个不同类型的查询，设置为自动模式来减少手动缓存的成本。

​		（6）--eviction-policy=lru表示指定ReadySet缓存策略，这里推荐使用lru策略。默认情况下是random策略，因为本地测试内存可能不是非常的充裕，在进行POC测试时不至于因为缓存数据占用内存而增加请求时间的高频震荡，设置为lru策略可能对性能测试相对友好。

​		（7）--address参数表示指定ReadySet服务的访问地址，需要注意的是如果ReadySet服务和数据库服务在同一台节点，ReadySet服务端口不能和数据库端口冲突。

​		（8）--prometheus-metrics参数一般用于ReadySet服务相关指标采集，一般推荐和--metrics-address使用；--metrics-addres参数表示指标采集的HTTP服务地址，方便后续集成Granfa进行友好的指标观测，同时也可以通过 http://127.0.0.1:6034/metrics 地址在浏览器中查看Prometheus所定义的指标。

​		（9）--db-dir参数用于指定ReadySet服务实际数据存储的路径。

### 3.测试验证

​		启动之后大致服务日志如下：

```shell
note: to see what the problems were, use the option `--future-incompat-report`, or run `cargo report future-incompatibilities --id 1`
     Running `target/release/readyset --standalone --deployment=readyset-proxy-postgres '--upstream-db-url=postgresql://postgres:readyset@127.0.0.1:5432/testdb' --database-type=postgresql --query-caching=async --username=postgres --password=readyset '--address=0.0.0.0:5433' --prometheus-metrics '--metrics-address=0.0.0.0:6034' --query-log --query-log-ad-hoc --db-dir=/tmp/readyset`

# 会打印ReadySet服务的所有系统参数，可用于验证参数设置是否成功
2023-08-10T01:53:13.274483Z  INFO readyset: Starting ReadySet adapter options=Options { address: Some(0.0.0.0:5433), deployment: "readyset-proxy-postgres", database_type: Some(PostgreSQL), standalone: true, authority: Standalone, authority_address: ".", log_slow: false, allow_unauthenticated_connections: false, query_caching: Async, max_processing_minutes: 15, migration_task_interval: 20000, metrics_address: 0.0.0.0:6034, username: Some("postgres"), password: Some("readyset"), prometheus_metrics: true, noria_metrics: false, query_log: true, query_log_ad_hoc: true, use_aws_external_address: false, tracing: Options { log_format: Full, log_level: "info", tracing_host: None, tracing_sample_percent: Percent(0.01), statement_logging: false, statement_log_path: None }, psql_options: Options { readyset_identity_file: None, readyset_identity_file_password: None, postgres_authentication_method: ScramSha256 }, allow_unsupported_set: false, unsupported_set_mode: Error, views_polling_interval: 5, migration_request_timeout_ms: 1800000, controller_request_timeout_ms: 5000, query_max_failure_seconds: 9223372036854775, fallback_recovery_seconds: 0, non_blocking_reads: false, embedded_readers: false, server_worker_options: WorkerOptions { durability: Permanent, persistence_threads: 6, memory_limit: 0, memory_check_freq: 1, eviction_kind: LRU, no_partial: false, allow_full_materialization: false, enable_packet_filters: false, min_workers: 1, shards: 0, volume_id: None, enable_experimental_topk_support: false, enable_experimental_paginate_support: false, enable_experimental_mixed_comparisons: false, db_dir: Some("/tmp/readyset"), domain_replication_options: ReplicationOptions { reader_replicas: None, non_base_replicas: None }, replicator_config: UpstreamConfig { upstream_db_url: Some("postgresql://postgres:readyset@127.0.0.1:5432/testdb"), disable_upstream_ssl_verification: false, ssl_root_cert: None, disable_setup_ddl_replication: false, replication_server_id: None, replicator_restart_timeout: 1s, replication_tables: None, snapshot_report_interval_secs: 30, replication_pool_size: 50 }, worker_request_timeout_seconds: 1800 }, disable_telemetry: false, wait_for_failpoint: false, fallback_cache_options: FallbackCacheOptions { enable_fallback_cache: false, ttl_seconds: 120, model_disk: false, eviction_options: FallbackCacheEvictionOptions { model_eviction: false, eviction_rate: 0.01 } }, experimental_placeholder_inlining: false, no_upstream_connections: false, cleanup: false, controller_address: None }
2023-08-10T01:53:13.275676Z  INFO readyset: version={release-version: unknown-release-version, commit_id: e7cd91cce60f7b8fd69defa7b8f82cda815f3fcd, platform: x86_64-apple-darwin, rustc_version: rustc 1.70.0-nightly (f63ccaf25 2023-03-06), profile: release, opt_level: 3}
2023-08-10T01:53:13.275796Z  INFO readyset: Listening for new connections listen_address=0.0.0.0:5433
2023-08-10T01:53:13.275861Z  INFO Connecting to RS server: readyset: options.authority_address=. options.deployment=readyset-proxy-postgres
2023-08-10T01:53:13.289925Z  INFO Connecting to RS server: readyset: ReadySetHandle created
2023-08-10T01:53:13.289990Z  INFO Connecting to RS server: readyset: Now capturing ctrl-c and SIGTERM events
2023-08-10T01:53:13.351875Z  INFO Connecting to RS server: readyset: PrometheusHandle created
2023-08-10T01:53:13.352474Z  INFO Connecting to RS server: readyset: Query logs are enabled. Spawning query logger
2023-08-10T01:53:13.353083Z  INFO Connecting to RS server: readyset: Will perform Blocking Reads
2023-08-10T01:53:13.353106Z  INFO Connecting to RS server: readyset: migration_style=Async
2023-08-10T01:53:13.353637Z  INFO Connecting to RS server: readyset: migration_mode=OutOfBand
2023-08-10T01:53:13.353664Z  INFO Connecting to RS server: readyset: Spawning HTTP request server task
2023-08-10T01:53:13.354193Z  INFO Connecting to RS server: readyset: Spawning migration handler task
2023-08-10T01:53:13.354794Z  INFO migration task upstream database connection:Connecting to upstream database:Connecting to PostgreSQL upstream{host=[Tcp("127.0.0.1")] port=[5432]}: readyset_psql::upstream: Establishing connection
2023-08-10T01:53:13.386743Z  INFO Connecting to RS server: readyset: supported=false
2023-08-10T01:53:13.388317Z  INFO readyset_server::controller: won leader election, creating Leader
2023-08-10T01:53:13.388685Z  INFO readyset_server::controller::inner: received registration payload from worker worker_uri=http://127.0.0.1:6033/ reader_addr=127.0.0.1:4000
2023-08-10T01:53:13.389185Z  INFO readyset_server::worker: worker informed of new controller controller_uri=http://127.0.0.1:6033/
2023-08-10T01:53:13.390363Z  INFO readyset_server::worker: controller requested that this worker clears its existing domains
2023-08-10T01:53:13.391238Z  INFO readyset_server::controller::inner: now have 1 of 1 required workers
2023-08-10T01:53:13.406676Z  INFO migration task upstream database connection:Connecting to upstream database:Connecting to PostgreSQL upstream{host=[Tcp("127.0.0.1")] port=[5432]}: readyset_psql::upstream: Established connection to upstream
2023-08-10T01:53:13.465956Z  INFO replicators::postgres_connector::ddl_replication: Setting up DDL replication
2023-08-10T01:53:13.512652Z  INFO tokio_postgres::connection: NOTICE: schema "readyset" already exists, skipping    
2023-08-10T01:53:13.732838Z  INFO replicators::postgres_connector::ddl_replication: Set up DDL replication
2023-08-10T01:53:13.777793Z  INFO replicators::postgres_connector::connector: Dropping replication slot if exists slot="readyset"
2023-08-10T01:53:13.788816Z  INFO replicators::postgres_connector::connector: Creating replication slot slot="readyset" temporary=false
# 连接所代理的上游数据库
2023-08-10T01:53:13.824909Z  INFO replicators::noria_adapter: Connected to PostgreSQL
# 开始进行数据库binlog事件流的复制
2023-08-10T01:53:14.001918Z  INFO Snapshotting table{table="public"."sbtest1"}: replicators::postgres_connector::snapshot: Snapshotting table
2023-08-10T01:53:14.097919Z  INFO Snapshotting table{table="public"."sbtest1"}: replicators::postgres_connector::snapshot: Snapshotting started approximate_rows=10000000
2023-08-10T01:53:14.389786Z  INFO readyset_server::worker: worker informed of new controller controller_uri=http://127.0.0.1:6033/
# 同时展示binlog事件流的复制进度
2023-08-10T01:53:45.190156Z  INFO Snapshotting table{table="public"."sbtest1"}: replicators::postgres_connector::snapshot: Snapshotting progress rows_replicated=3398656 progress=33.99% estimate=00:01:00
2023-08-10T01:54:16.195643Z  INFO Snapshotting table{table="public"."sbtest1"}: replicators::postgres_connector::snapshot: Snapshotting progress rows_replicated=6148096 progress=61.48% estimate=00:00:38
2023-08-10T01:54:47.195662Z  INFO Snapshotting table{table="public"."sbtest1"}: replicators::postgres_connector::snapshot: Snapshotting progress rows_replicated=9947136 progress=99.47% estimate=00:00:00
2023-08-10T01:54:47.582819Z  INFO Snapshotting table{table="public"."sbtest1"}: replicators::postgres_connector::snapshot: Setting replication offset and compacting table table="public"."sbtest1" wal_position=wal[0/D9425068]
2023-08-10T01:54:49.076032Z  INFO Snapshotting table{table="public"."sbtest1"}: replicators::postgres_connector::snapshot: Snapshotting finished rows_replicated=10000000
```

​		在启动没有ERROR日志下通过如下指令连接ReadySet服务，验证其连通性。

```shell
psql "postgresql://postgres:readyset@127.0.0.1:5433/testdb"
```

​		并注意这里的连接端口是5433，不是数据库服务端口！执行如下SQL指令可以查看所代理数据库下的每张表的快照情况：

```shell
testdb=> show readyset tables;
       table        |   status
--------------------+-------------
 "public"."sbtest1" | Snapshotted
```



# 云原生部署

待补充......