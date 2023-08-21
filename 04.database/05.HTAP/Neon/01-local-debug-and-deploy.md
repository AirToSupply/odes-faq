# 前置说明

​		本小节主要介绍如何在MacOS上通过源码编译的方式来启动部署一个本地的Neon数据库服务，这里选用的Neon数据库的版本为：`release-3710`。

# 前置准备

​		【步骤一】准备Rust基础环境。（略）

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

​		【步骤二】准备Python基础环境 (>=3.9)，这里通过Anaconda进行快捷安装。（略）

​		【步骤三】通过MacOS提供的依赖包下载工具下载如下依赖：

```shell
brew install protobuf openssl flex bison
```

​		【步骤四】添加openssl依赖的执行路径到系统环境变量的配置文件中。

```shell
echo 'export PATH="$(brew --prefix openssl)/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

​		【步骤五】下载PostgreSQL客户端，配置一些环境变量值系统中。

```shell
brew install postgresql@15
brew install libpq
brew link --force libpq
```

```shell
> vim ~/.bash_profile

export PG_HOME=/usr/local/Cellar/postgresql@15/15.3_2
export PATH=$PATH:$PG_HOME/bin:$PG_HOME/lib
export LD_LIBRARY_PATH=$PG_HOME/bin:$PG_HOME/lib

> source ~/.bash_profile
```

# 源码编译

​		【步骤一】下载源码，这里下载的是`release-3710`版本。

```shell
git clone --recursive https://github.com/neondatabase/neon.git
git tag
git checkout release-3710
cd neon
```

​		**注意**：这里在源码时，参数`--recursive`不能丢。因为在当前版本源码中的vendor目录下连接到postgres数据库代码仓库中。使用--recursive参数会同时将postgres数据库代码同时克隆下来，因为后续的编译需要vendor目录的源码进行编译。如果没有没有指定--recursive参数需要进入带vendor目录下手动克隆代码。

​		【步骤二】通过系统最大并行度进行编译，编译过程中无异常则编译通过。

```shell
make -j`sysctl -n hw.logicalcpu` -s
```

# 安装部署

​		【步骤一】数据文件初始化。这里默认会在neon源码目录下的`.neon`目录下生成一堆初始化文件。

```shell
cargo neon init
```

```shell
Initializing pageserver node 1 at '127.0.0.1:64000' in ".neon"
```

​		【步骤二】启动pageserver, safekeeper, 以及broker组件然后完成组件之间的互相通信。

```shell
cargo neon start
```

```shell
Starting neon broker at 127.0.0.1:50051.
storage_broker started, pid: 84453

Starting pageserver node 1 at '127.0.0.1:64000' in ".neon".
pageserver started, pid: 84457

Starting safekeeper at '127.0.0.1:5454' in '.neon/safekeepers/sk1'.
safekeeper-1 started, pid: 84458
```

​		同时检查相关组件是否成功启动。

```shell
> ps -ef | grep storage_broker
501 84453     1   0  3:13下午 ttys003    0:00.03 /Users/.../workspace/open_source/neon/target/debug/storage_broker --listen-addr=127.0.0.1:50051

> ps -ef | grep pageserver
501 84457     1   0  3:13下午 ttys003    0:00.04 /Users/.../workspace/open_source/neon/target/debug/pageserver -D .neon -c id=1 -c pg_distrib_dir='/Users/tangch/workspace/open_source/neon/pg_install' -c http_auth_type='Trust' -c pg_auth_type='Trust' -c listen_http_addr='127.0.0.1:9898' -c listen_pg_addr='127.0.0.1:64000' -c broker_endpoint='http://127.0.0.1:50051/'

> ps -ef | grep safekeeper
501 84458     1   0  3:13下午 ttys003    0:00.12 /Users/.../workspace/open_source/neon/target/debug/safekeeper -D .neon/safekeepers/sk1 --id 1 --listen-pg 127.0.0.1:5454 --listen-http 127.0.0.1:7676 --availability-zone sk-1 --broker-endpoint http://127.0.0.1:50051/
```

​		【步骤三】创建初始租户。

```shell
cargo neon tenant create --set-default
```

```shell
tenant c4c45f26bc41e7c82aed532eaeb2b5cb successfully created on the pageserver
Created an initial timeline '3f08dec5c1f8ff26d498e0a4f64af77f' at Lsn 0/14B81F8 for tenant: c4c45f26bc41e7c82aed532eaeb2b5cb
Setting tenant c4c45f26bc41e7c82aed532eaeb2b5cb as a default one
```

​		【步骤四】创建计算端点。

```shell
cargo neon endpoint start main
```

```shell
Starting new endpoint main (PostgreSQL v15) on timeline 3f08dec5c1f8ff26d498e0a4f64af77f ...
Starting postgres node at 'postgresql://cloud_admin@127.0.0.1:55432/postgres'
```

​		通过命令查询计算端点进程是否启动。

```shell
ps -ef | grep compute_ctl
501 86112     1   0  3:56下午 ttys003    0:04.12 /Users/.../workspace/open_source/neon/target/debug/compute_ctl --http-port 55433 --pgdata .neon/endpoints/main/pgdata --connstr postgresql://cloud_admin@127.0.0.1:55432/postgres --spec-path .neon/endpoints/main/spec.json --pgbin /Users/tangch/workspace/open_source/neon/pg_install/v15/bin/postgres
```

​		【步骤五】检查计算端点状态。

```shell
cargo neon endpoint list
```

```shell
 ENDPOINT  ADDRESS          TIMELINE                          BRANCH NAME  LSN        STATUS
 main      127.0.0.1:55432  3f08dec5c1f8ff26d498e0a4f64af77f  main         0/14BD3B0  running
```

​		确认状态计算节点状态是running之后，可以通过psql客户端连接服务端。

```shell
psql "postgresql://cloud_admin@127.0.0.1:55432/postgres"
```

​		【步骤六】进行简单数据库操作来验证数据库服务是否可以正常运行SQL指令。

```sql
psql (15.3 (Homebrew), server 15.4)
Type "help" for help.

postgres=# CREATE TABLE t(key int primary key, value text);
CREATE TABLE

postgres=# insert into t values(1,1);
INSERT 0 1

postgres=# select * from t;
 key | value
-----+-------
   1 | 1
(1 row)
```

​		【步骤七】关闭数据库服务。

```shell
cargo neon stop
```

```shell
.
compute_ctl stopped
Stopping pageserver with pid 84457 gracefully...
pageserver stopped
Stopping safekeeper 1 with pid 84458 gracefully...
safekeeper 1 stopped
Stopping storage_broker with pid 84453 immediately...
storage_broker stopped
```

