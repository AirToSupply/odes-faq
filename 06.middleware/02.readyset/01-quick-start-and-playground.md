# 前置说明

​		ReadySet为用户提供了一套便捷的交互式测试环境playground，该环境已经为用户部署好了ReadySet服务，通过一个相对比较完整的例子，全链路地演示了使用了ReadySet作为缓存服务中间件的前后比对实验。由于每次会话的时间较短（只有10min）下文为记录了演示过程中所有的演示信息方便深入研究和学习。同时，由于官方网站更迭较快，进入演示页面入口链接无法找到或者消失，这里可以参考：[官方代码仓库文档摘要](https://github.com/readysettech/docs/blob/main/docs/guides/intro/playground.md)，目前演示链接入口为：[instruqt](https://play.instruqt.com/embed/readyset/tracks/readyset-demo?token=em_-XZtFwT9_zvK7lnb) 或者 [ReadySet Playground](https://play.instruqt.com/embed/readyset/tracks/readyset-demo)。

# 演示步骤

​		交互式测试环境分为如下五个步骤。

## 一.👀 Explore the dataset

​		首先探索两个预加载的表：`title_basics`和`title_ratings`。 这些表是[IMDB](https://developer.imdb.com/non-commercial-datasets/)数据集的子集。

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

​		当快照完成后，ReadySet已准备好进行缓存，此时可以运行一些查询，主要用于检查ReadySet是否支持它们，然后缓存。

【步骤-1】通过psql客户端工具链接到数据。注意这里的端口连接到ReadySet，而不是直接连接上游数据库本身。

```shell
PGPASSWORD=readyset psql \
--host=readyset \
--port=5433 \
--username=postgres \
--dbname=imdb
```

【步骤-2】通过`title_ratings`表和`title_basics`表进行查询，主要的业务逻辑是：计算2000年发布的平均评分高于 5的图书数量。

```sql
imdb=> 
  SELECT count(*) 
    FROM title_ratings
    JOIN title_basics 
      ON title_ratings.tconst = title_basics.tconst
   WHERE title_basics.startyear = 2000 
     AND title_ratings.averagerating > 5;

 count 
-------
 14144
(1 row)
```

【步骤-3】由于上述查询尚未缓存，ReadySet将其代理到上游数据库。 使用ReadySet的自定义指令`SHOW PROXIED QUERIES`命令来检查ReadySet是否可以支持该缓存查询。

```sql
imdb=> SHOW PROXIED QUERIES;

 proxied query                                                                                             | rea
dyset supported 
--------------------+-------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------+----
----------------
 q_5348e5187dbf1722 | SELECT count(*) FROM `title_ratings` JOIN `title_basics` ON (`title_ratings`.`tconst` = `t
itle_basics`.`tconst`) WHERE ((`title_basics`.`startyear` = $1) AND (`title_ratings`.`averagerating` > 5)) | yes

(1 row)
```

​		可以观察到在Readyset下看到yes，这表示ReadySet是可以支持该缓存查询的。如果需要成功缓存查询结果，必须使用ReadySet支持查询中的SQL功能和语法。 

【步骤-4】将查询缓存在ReadySet中。

```sql
CREATE CACHE FROM
SELECT count(*) 
  FROM title_ratings
  JOIN title_basics 
    ON title_ratings.tconst = title_basics.tconst
 WHERE title_basics.startyear = 2000 
   AND title_ratings.averagerating > 5;
```

​		需要注意的是`CREATE CACHE FROM`这个语法是ReadySet所有独有的。当执行这个指令之后，缓存将需要几分钟的时间，因为它会为查询构建初始数据流图，并根据需要向相关ReadySet表快照添加索引。

【步骤-5】下面来运行这个查询语句。主要的业务逻辑是：连接上述两个表的结果并获取1950年10部评分最高的电影的标题和平均评分。

```sql
SELECT 
       title_basics.originaltitle, 
       title_ratings.averagerating
  FROM title_basics
  JOIN title_ratings 
    ON title_basics.tconst = title_ratings.tconst
 WHERE title_basics.startyear = 1950 
   AND title_basics.titletype = 'movie'
 ORDER BY title_ratings.averagerating DESC
 LIMIT 10;
```

​		返回结果如下：

```shell
          originaltitle             | averagerating 
--------------------------------------+---------------
 Le mariage de Mademoiselle Beulemans |           9.0
 Sudhar Prem                          |           8.7
 Es kommt ein Tag                     |           8.7
 Nili                                 |           8.7
 Pyar                                 |           8.6
 Jiruba Tetsu                         |           8.5
 Meena Bazaar                         |           8.5
 Tathapi                              |           8.4
 Sunset Blvd.                         |           8.4
 Vidyasagar                           |           8.4
 
(10 rows)
```

【步骤-6】使用`SHOW PROXIED QUERIES`命令检查ReadySet是否可以缓存查询。

```sql
> SHOW PROXIED QUERIES;

query id      |                                                                                               
                                              proxied query                                                         
                                                                                    | readyset supported 
--------------------+-----------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------+--------------------
 q_8dba9d9bee766310 | SELECT `title_basics`.`originaltitle`, `title_ratings`.`averagerating` FROM `title_basics` JOI
N `title_ratings` ON (`title_basics`.`tconst` = `title_ratings`.`tconst`) WHERE ((`title_basics`.`startyear` = $1) A
ND (`title_basics`.`titletype` = $2)) ORDER BY `title_ratings`.`averagerating` DESC | yes

 q_5348e5187dbf1722 | SELECT count(*) FROM `title_ratings` JOIN `title_basics` ON (`title_ratings`.`tconst` = `title
_basics`.`tconst`) WHERE ((`title_basics`.`startyear` = $1) AND (`title_ratings`.`averagerating` > 5))              
                                                                                    | yes
```

​		此时需要检查该状态，如果该值为`pending`，需要再次检查，直到看到出现`yes`或者是`no`。

【步骤-7】缓存查询到ReadySet。

```sql
CREATE CACHE FROM
SELECT 
       title_basics.originaltitle, 
       title_ratings.averagerating
  FROM title_basics
  JOIN title_ratings 
    ON title_basics.tconst = title_ratings.tconst
 WHERE title_basics.startyear = 1950 
   AND title_basics.titletype = 'movie'
 ORDER BY title_ratings.averagerating DESC
 LIMIT 10;
```

​		同样的情况，缓存将需要几分钟的时间，因为它会为查询构建初始数据流图，并根据需要向相关ReadySet表快照添加索引。

【步骤-8】使用ReadySet的自定义`SHOW CACHES`命令验证是否已为上述的查询创建缓存。

```sql
> SHOW CACHES;


         name         |                                                                                             
                                                                                            query                   
                                                                                                                    
                                                   | fallback behavior 
----------------------+---------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
---------------------------------------------------+-------------------
 `q_8dba9d9bee766310` | SELECT `public`.`title_basics`.`originaltitle`, `public`.`title_ratings`.`averagerating` FRO
M `public`.`title_basics` JOIN `public`.`title_ratings` ON (`public`.`title_basics`.`tconst` = `public`.`title_ratin
gs`.`tconst`) WHERE ((`public`.`title_basics`.`startyear` = $1) AND (`public`.`title_basics`.`titletype` = $2)) ORDE
R BY `public`.`title_ratings`.`averagerating` DESC | fallback allowed

(1 row)
```



## 四.✅ Check latencies

​		这里会尝试使用一个简单的Python脚本对数据库和ReadySet运行查询探测，用于比较返回结果的速度（延时）。

【步骤-1】当前工作目录如下：

```shell
> ll

drwx------ 1 root root  4096 Aug  5 13:33 ./
drwxr-xr-x 1 root root  4096 Aug  5 13:32 ../
-rw-r--r-- 1 root root     0 Aug  5 13:32 .bash_history
-rw-r--r-- 1 root root  1708 Aug  5 13:32 .bashrc
drwxr-xr-x 3 root root  4096 Aug  5 13:33 .cache/
-rw-r--r-- 1 root root   148 Aug 17  2015 .profile
drwx------ 2 root root  4096 Aug  5 13:32 .ssh/
-rw------- 1 root root 14583 Aug  5 13:32 .vimrc
-rw-r--r-- 1 root root   254 Jun 13 16:16 .wget-hsts
-rw-r--r-- 1 root root  1674 Aug  5 13:33 quickstart-app.py
```

​		这里的quickstart-app.py为测试和探查准备的脚本：

```python
#!/usr/bin/env python3

import argparse
import psycopg2
import time
import numpy as np

parser = argparse.ArgumentParser(
    description="test performance of ReadySet vs. a backing Postgres database")
parser.add_argument("--query",
                    required=True,
                    help="query to execute")
parser.add_argument("--repeat",
                    type=int,
                    help="number of times to run the query",
                    default = 20)
parser.add_argument("--url",
                    required=True,
                    help="connection URL for ReadySet or Postgres")
args = parser.parse_args()

conn = psycopg2.connect(dsn=args.url)
conn.set_session(autocommit=True)
cur = conn.cursor()

times = list()
for n in range(args.repeat):
    start = time.time()
    query = args.query
    cur.execute(query)
    if n < 1:
        if cur.description is not None:
            colnames = [desc[0] for desc in cur.description]
            print("")
            print("Result:")
            print(colnames)
            rows = cur.fetchall()
            for row in rows:
                print([str(cell) for cell in row])
    end = time.time()
    times.append((end - start)* 1000)

cur.close()
conn.close()

print("")
print("Query latencies (in milliseconds):")
print(["{:.2f}".format(t) for t in times])
print("")

print("Latency percentiles (in milliseconds):")
print(" p50: {:.2f}".format(np.percentile(times, 50)))
print(" p90: {:.2f}".format(np.percentile(times, 90)))
print(" p95: {:.2f}".format(np.percentile(times, 95)))
print(" p99: {:.2f}".format(np.percentile(times, 99)))
print("p100: {:.2f}".format(np.percentile(times, 100)))
print("")
```

​		该应用程序将运行指定的查询20次，并打印每次迭代的延迟以及查询延迟分布（第 50、90、95、99 和 100 个百分位数）。

【步骤-2】对数据库运行第一个JOIN查询。脚本命令如下，需要主要的是这里是直接连接数据本身。

```shell
python3 quickstart-app.py \
--url="postgresql://postgres:readyset@postgres:5432/imdb?sslmode=disable" \
--query="SELECT count(*) FROM title_ratings JOIN title_basics ON title_ratings.tconst = title_basics.tconst WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;"
```

​		返回结果如下：

```shell
Result:
['count']
['14144']

Query latencies (in milliseconds):
['1157.96', '1094.32', '1069.59', '1130.59', '1136.37', '1148.86', '1076.73', '1397.90', '1164.88', '1088.02', '1111.15', '1120.10', '1118.61', '1166.39', '1109.65', '1239.69', '1320.27', '1104.54', '1099.56', '1095.61']

Latency percentiles (in milliseconds):
 p50: 1119.35
 p90: 1247.75
 p95: 1324.15
 p99: 1383.15
p100: 1397.90
```

【步骤-3】再次运行步骤二中脚本，需要特别注意的是，这次运行的是ReadySet。

​		所以在启动脚本命令时，需要更改连接字符串。在本例中，只需将主机和端口从`postgres:5432`更改为`readyset:5433`。

```shell
python3 quickstart-app.py \
--url="postgresql://postgres:readyset@readyset:5433/imdb?sslmode=disable" \
--query="SELECT count(*) FROM title_ratings JOIN title_basics ON title_ratings.tconst = title_basics.tconst WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;"
```

​		运行结果如下：

```shell
Result:
['count(coalesce(`public`.`title_ratings`.`tconst`, 0))']
['14144']

Query latencies (in milliseconds):
['16.87', '0.52', '0.39', '0.29', '0.37', '0.24', '0.21', '0.19', '0.20', '0.20', '0.24', '0.18', '0.21', '0.18', '0.17', '0.20', '0.17', '0.74', '0.29', '0.33']

Latency percentiles (in milliseconds):
 p50: 0.22
 p90: 0.54
 p95: 1.54
 p99: 13.80
p100: 16.87
```

​		再次尝试运行结果如下：

```shell
Result:
['count(coalesce(`public`.`title_ratings`.`tconst`, 0))']
['14144']

Query latencies (in milliseconds):
['2.45', '0.34', '0.31', '0.23', '0.18', '0.22', '0.20', '0.21', '0.20', '0.17', '0.39', '0.19', '0.18', '0.21', '0.18', '0.16', '0.17', '0.28', '0.18', '0.17']

Latency percentiles (in milliseconds):
 p50: 0.20
 p90: 0.34
 p95: 0.49
 p99: 2.06
p100: 2.45
```

​		可以看到这个结果和【步骤-2】中的结果对比还是非常恐怖的！

【步骤-4】下面尝试运行第二个JOIN语句，注意此时直接连接方式。

```shell
python3 quickstart-app.py \
--url="postgresql://postgres:readyset@postgres:5432/imdb?sslmode=disable" \
--query="SELECT title_basics.originaltitle, title_ratings.averagerating FROM title_basics JOIN title_ratings ON title_basics.tconst = title_ratings.tconst WHERE title_basics.startyear = 1950 AND title_basics.titletype = 'movie' ORDER BY title_ratings.averagerating DESC LIMIT 10;"
```

​		返回结果如下：

```shell
Result:
['originaltitle', 'averagerating']
['Le mariage de Mademoiselle Beulemans', '9.0']
['Es kommt ein Tag', '8.7']
['Nili', '8.7']
['Sudhar Prem', '8.7']
['Pyar', '8.6']
['Meena Bazaar', '8.5']
['Jiruba Tetsu', '8.5']
['Sunset Blvd.', '8.4']
['Tathapi', '8.4']
['Vidyasagar', '8.4']

Query latencies (in milliseconds):
['696.24', '657.42', '651.81', '944.09', '732.25', '724.68', '703.75', '684.91', '731.70', '735.55', '704.20', '697.84', '695.98', '767.63', '732.02', '745.85', '876.30', '918.40', '778.56', '671.78']

Latency percentiles (in milliseconds):
 p50: 728.19
 p90: 880.51
 p95: 919.68
 p99: 939.21
p100: 944.09
```

【步骤-5】继续运行步骤-4的脚本，注意这次是连接ReadySet。

​		此时需要注意从数据库返回结果时的延迟。会发现通过ReadySet返回结果的速度要快得多。

​		启动脚本如下：

```shell
python3 quickstart-app.py \
--url="postgresql://postgres:readyset@readyset:5433/imdb?sslmode=disable" \
--query="SELECT title_basics.originaltitle, title_ratings.averagerating FROM title_basics JOIN title_ratings ON title_basics.tconst = title_ratings.tconst WHERE title_basics.startyear = 1950 AND title_basics.titletype = 'movie' ORDER BY title_ratings.averagerating DESC LIMIT 10;"
```

​		返回结果如下：

```shell
Result:
['originaltitle', 'averagerating']
['Le mariage de Mademoiselle Beulemans', '9.0']
['Es kommt ein Tag', '8.7']
['Nili', '8.7']
['Sudhar Prem', '8.7']
['Pyar', '8.6']
['Jiruba Tetsu', '8.5']
['Meena Bazaar', '8.5']
['Pardes', '8.4']
['Showkar', '8.4']
['Siete muertes a plazo fijo', '8.4']

Query latencies (in milliseconds):
['34.15', '0.59', '0.38', '0.38', '0.37', '0.39', '0.41', '0.52', '0.39', '0.48', '0.41', '0.37', '0.42', '0.43', '0.40', '0.42', '0.38', '0.42', '0.49', '0.32']

Latency percentiles (in milliseconds):
 p50: 0.41
 p90: 0.52
 p95: 2.27
 p99: 27.77
p100: 34.15
```

​		再次运行，会有不一样的发现，结果如下：

```shell
Result:
['originaltitle', 'averagerating']
['Le mariage de Mademoiselle Beulemans', '9.0']
['Es kommt ein Tag', '8.7']
['Nili', '8.7']
['Sudhar Prem', '8.7']
['Pyar', '8.6']
['Jiruba Tetsu', '8.5']
['Meena Bazaar', '8.5']
['Pardes', '8.4']
['Showkar', '8.4']
['Siete muertes a plazo fijo', '8.4']

Query latencies (in milliseconds):
['3.49', '0.39', '0.32', '0.28', '0.28', '0.24', '0.33', '0.28', '0.43', '0.32', '0.30', '0.29', '0.52', '0.40', '0.33', '0.32', '0.21', '0.26', '0.30', '0.33']

Latency percentiles (in milliseconds):
 p50: 0.32
 p90: 0.44
 p95: 0.67
 p99: 2.93
p100: 3.49
```

​		经过缓存之后，访问延时到达了微妙级别！

## 五.✨ Cause a cache refresh

​		对于ReadySet来说最重要的功能是当写入应用于上游数据库时，它能够使缓存保持最新状态。 在下面的实验中将看到它的实际效果。同时这个效果有点类型于CDC。

【步骤-1】通过psql客户端，向`title_basics`表插入一条数据。

```shell
PGPASSWORD=readyset psql \
--host=postgres \
--port=5432 \
--username=postgres \
--dbname=imdb \
-c "INSERT INTO title_basics (tconst, titletype, primarytitle, originaltitle, isadult, startyear, runtimeminutes, genres)
      VALUES ('tt9999998', 'movie', 'The ReadySet movie', 'The ReadySet movie', false, 2000, 0, 'Adventure');
    INSERT INTO title_ratings (tconst, averagerating, numvotes)
      VALUES ('tt9999998', 10, 1000000);"
```

【步骤-2】通过之前编写的quickstart-app.py脚本工具，测试`Check latencies`环节中的【步骤-2】的SQL语句。

```shell
python3 quickstart-app.py \
--url="postgresql://postgres:readyset@readyset:5433/imdb?sslmode=disable" \
--query="SELECT count(*) FROM title_ratings JOIN title_basics ON title_ratings.tconst = title_basics.tconst WHERE title_basics.startyear = 2000 AND title_ratings.averagerating > 5;"
```

​		返回结果如下：

```shell
Result:
['count']
['14145']

Query latencies (in milliseconds):
['1213.07', '1065.08', '1044.02', '1081.41', '1161.04', '1330.36', '1146.43', '1077.38', '1053.77', '1197.35', '1048.96', '1060.93', '1040.77', '1271.69', '1140.29', '1079.56', '1128.97', '1061.77', '1084.34', '1100.33']

Latency percentiles (in milliseconds):
 p50: 1082.87
 p90: 1218.93
 p95: 1274.63
 p99: 1319.22
p100: 1330.36
```

​		千万不要忘记这里的总条数之前是14144条。而现在的总数为14145，查询延迟几乎没有变化。这里演示了ReadySet如何使用数据库的复制流自动更新缓存，而不需要像其它缓存方案通过额外增加代码维护数据库和缓存的一致性，对于ReadySet无需执行任何操作即可保持数据库和缓存同步。