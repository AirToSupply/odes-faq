# 前置说明

​		ReadySet为用户提供了一套便捷的交互式测试环境playground，该环境中通过一个实际的例子，全链路地演示了使用了ReadySet作为存储服务中间件的前后比对实验。由于每次会话的时间较短（10min）下文为记录了演示过程中所有的演示信息方便学习查看。同时，由于官方网站更迭较快，进入playground页面入口链接无法找到或者消失，可以参考：[官方代码仓库文档摘要](https://github.com/readysettech/docs/blob/main/docs/guides/intro/playground.md)，目前演示链接入口为：[instruqt](https://play.instruqt.com/embed/readyset/tracks/readyset-demo?token=em_-XZtFwT9_zvK7lnb) 或者 [ReadySet Playground](https://play.instruqt.com/embed/readyset/tracks/readyset-demo)。

# 演示步骤

​		交互式测试环境playground分为如下五个步骤。

## 一.👀 Explore the dataset

​		首先探索两个预加载的表：`title_basics`和`title_ratings`。 这些表是IMDB数据集的子集。

【步骤-1】通过SQL客户端psql链接数据库服务端。

```shell
PGPASSWORD=readyset psql \
--host=postgres \
--port=5432 \
--username=postgres \
--dbname=imdb
```

【步骤-2】进行简单的采样探查。

```shell
imdb=# SELECT * FROM title_basics WHERE tconst = 'tt0093779';

  tconst   | titletype |    primarytitle    |   originaltitle    | isadult | startyear | endyear | runtimeminute
s |          genres          
-----------+-----------+--------------------+--------------------+---------+-----------+---------+--------------
--+--------------------------
 tt0093779 | movie     | The Princess Bride | The Princess Bride | f       |      1987 |         |             9
8 | Adventure,Family,Fantasy

imdb=# SELEsCT * FROM title_ratings WHERE tconst = 'tt0093779';

  tconst   | averagerating | numvotes 
-----------+---------------+----------
 tt0093779 |           8.0 |   427192
```

【步骤-3】查询表的数据量。

```shell
imdb=# SELECT count(*) from title_basics;

  count  
---------
 5159701
(1 row)

imdb=# SELECT count(*) from title_ratings;

  count  
---------
 1246402
(1 row)
```



## 二.🔗 Confirm ReadySet is ready

​		当ReadySet首次连接到数据库时，它会进行数据快照的相关操作。 该快照是ReadySet缓存查询结果的基础，同时也启动ReadySet之后确认是否已完成或者正在完成快照过程的依据。

​		可以通过检查ReadySet服务日志以了解快照进度，当前工作路径情况如下：

```shell
> ll

drwx------ 1 root root  4096 Aug  2 16:09 ./
drwxr-xr-x 1 root root  4096 Aug  2 16:06 ../
-rw-r--r-- 1 root root     0 Aug  2 16:06 .bash_history
-rw-r--r-- 1 root root  1708 Aug  2 16:06 .bashrc
-rw-r--r-- 1 root root   161 Dec  5  2019 .profile
drwx------ 2 root root  4096 Aug  2 16:06 .ssh/
-rw------- 1 root root 14583 Aug  2 16:06 .vimrc
drwxr-xr-x 2 root root  4096 Aug  2 16:09 readyset-demo.auth/
-rw-r--r-- 1 root root     0 Aug  2 16:08 readyset.err
-rw-r--r-- 1 root root 15245 Aug  2 16:10 readyset.out
drwxr-xr-x 2 root root  4096 Aug  2 16:10 readyset_demo-public-title_basics-0.db/
drwxr-xr-x 2 root root  4096 Aug  2 16:10 readyset_demo-public-title_ratings-0.db/
```

​		通过在日志文件中可以查询如下关键字信息来验证：

```shell
> cat readyset.out | grep 'Snapshotting table'

2023-08-02T16:09:01.236038Z  INFO Snapshotting table{table=`public`.`title_basics`}: replicators::postgres_connector::snapshot: Snapshotting table context=LogContext({"deployment": "readyset-demo"})
2023-08-02T16:09:01.283809Z  INFO Snapshotting table{table=`public`.`title_ratings`}: replicators::postgres_connector::snapshot: Snapshotting table context=LogContext({"deployment": "readyset-demo"})
2023-08-02T16:09:01.668820Z  INFO Snapshotting table{table=`public`.`title_ratings`}: replicators::postgres_connector::snapshot: Snapshotting started context=LogContext({"deployment": "readyset-demo"}) rows=1246402
2023-08-02T16:09:02.596003Z  INFO Snapshotting table{table=`public`.`title_basics`}: replicators::postgres_connector::snapshot: Snapshotting started context=LogContext({"deployment": "readyset-demo"}) rows=5159701
2023-08-02T16:09:11.259795Z  INFO Snapshotting table{table=`public`.`title_ratings`}: replicators::postgres_connector::snapshot: Snapshotting finished context=LogContext({"deployment": "readyset-demo"}) rows_replicated=1246402
2023-08-02T16:09:33.643086Z  INFO Snapshotting table{table=`public`.`title_basics`}: replicators::postgres_connector::snapshot: Snapshotting progress context=LogContext({"deployment": "readyset-demo"}) rows_replicated=2911232 progress=56.42% estimate=00:00:23
2023-08-02T16:09:53.926204Z  INFO Snapshotting table{table=`public`.`title_basics`}: replicators::postgres_connector::snapshot: Snapshotting finished context=LogContext({"deployment": "readyset-demo"}) rows_replicated=5159701
```

​		可以观察到`title_basics`表和`title_ratings`表正在快照进行中。

​		稍等片刻应该会看到`title_basics`表和`title_ratings`表快照已完成消息。 否则，如果表的快照尚未完成，会看到进度和预计剩余时间（例如，进度=84.13% 估计=00:00:23）。

```shell
> cat readyset.out | grep 'Snapshotting finished'

2023-08-02T16:09:11.259795Z  INFO Snapshotting table{table=`public`.`title_ratings`}: replicators::postgres_connector::snapshot: Snapshotting finished context=LogContext({"deployment": "readyset-demo"}) rows_replicated=1246402
2023-08-02T16:09:53.926204Z  INFO Snapshotting table{table=`public`.`title_basics`}: replicators::postgres_connector::snapshot: Snapshotting finished context=LogContext({"deployment": "readyset-demo"}) rows_replicated=5159701
```



## 三.🚀 Cache queries

## 四.✅ Check latencies

## 五.✨ Cause a cache refresh

