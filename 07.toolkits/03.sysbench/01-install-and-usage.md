# 一.如何安装？

​		在Linux操作系统安装如下：

```shell
# 修改yum源
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
# 安装依赖
sudo yum -y install sysbench
# 如果正常打印版本则表示安装成功
sysbench --version
```

​		在MacOS操作系统安装如下：

```shell
# 安装依赖
brew install sysbench
# 如果正常打印版本则表示安装成功
sysbench --version
```

# 二.基本使用

​		参考：[MySQL 性能压测工具-sysbench，从入门到自定义测试项](https://www.cnblogs.com/ivictor/p/16955580.html)

# 三.测试案例-数据库性能压测

​		【硬件环境】Linux Version: CentOS 7.x；Memory: 300GB；Disk: 8T。

​		【数据库】MySQL 8.x （单机）

​		【压测需求】基于压测工具在数据库中构建20个测试表，每表数据量大约在100W，使用10个并发线程对数据路连续1分钟的混合读写测试。

## 1.创建数据库

```sql
CREATE DATABASE test_db;
```

## 2.构建数据集

```shell
sysbench \
--db-driver=mysql \
--time=60 \
--threads=10 \
--report-interval=1 \
--mysql-host=172.16.10.206 \
--mysql-port=3306 \
--mysql-user=root \
--mysql-password=root \
--mysql-db=test_db \
--tables=20 \
--table_size=1000000 \
--db-ps-mode=disable \
oltp_read_write prepare
```

## 3.压力测试

```shell
sysbench \
--db-driver=mysql \
--time=60 \
--threads=10 \
--report-interval=1 \
--mysql-host=172.16.10.206 \
--mysql-port=3306 \
--mysql-user=root \
--mysql-password=root \
--mysql-db=test_db \
--tables=20 \
--table_size=1000000 \
--db-ps-mode=disable \
oltp_read_write run
```

​		测试结果如下：

```shell
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 10
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 10 tps: 1380.88 qps: 27741.45 (r/w/o: 19438.19/5531.52/2771.75) lat (ms,95%): 12.75 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 10 tps: 356.03 qps: 7127.69 (r/w/o: 4997.49/1418.14/712.07) lat (ms,95%): 33.12 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 10 tps: 391.99 qps: 7837.74 (r/w/o: 5477.82/1575.95/783.97) lat (ms,95%): 11.24 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 10 tps: 526.00 qps: 10517.94 (r/w/o: 7358.96/2106.99/1051.99) lat (ms,95%): 26.20 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 10 tps: 74.00 qps: 1484.97 (r/w/o: 1045.98/290.99/148.00) lat (ms,95%): 376.49 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 10 tps: 46.00 qps: 925.95 (r/w/o: 651.96/181.99/91.99) lat (ms,95%): 943.16 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 10 tps: 2.00 qps: 53.00 (r/w/o: 41.00/8.00/4.00) lat (ms,95%): 282.25 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 10 tps: 5.00 qps: 134.01 (r/w/o: 74.00/50.00/10.00) lat (ms,95%): 2362.72 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 10 tps: 68.95 qps: 1298.03 (r/w/o: 917.31/242.82/137.90) lat (ms,95%): 3151.62 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 10 tps: 1198.86 qps: 24026.29 (r/w/o: 16814.10/4815.47/2396.72) lat (ms,95%): 10.09 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 10 tps: 291.99 qps: 5798.81 (r/w/o: 4063.87/1149.96/584.98) lat (ms,95%): 33.12 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 10 tps: 26.00 qps: 528.04 (r/w/o: 371.03/105.01/52.00) lat (ms,95%): 520.62 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 10 tps: 191.99 qps: 3870.78 (r/w/o: 2703.85/782.96/383.98) lat (ms,95%): 53.85 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 10 tps: 758.95 qps: 15188.95 (r/w/o: 10635.26/3035.79/1517.89) lat (ms,95%): 24.38 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 10 tps: 619.01 qps: 12344.30 (r/w/o: 8637.21/2469.06/1238.03) lat (ms,95%): 25.74 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 10 tps: 447.02 qps: 8939.46 (r/w/o: 6260.32/1785.09/894.05) lat (ms,95%): 27.66 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 10 tps: 27.00 qps: 522.00 (r/w/o: 365.00/103.00/54.00) lat (ms,95%): 893.56 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 10 tps: 2.00 qps: 34.00 (r/w/o: 22.00/8.00/4.00) lat (ms,95%): 502.20 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 10 tps: 1.00 qps: 17.00 (r/w/o: 14.00/1.00/2.00) lat (ms,95%): 2880.27 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 10 tps: 0.00 qps: 93.00 (r/w/o: 56.00/37.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 10 tps: 649.96 qps: 12957.20 (r/w/o: 9077.44/2579.84/1299.92) lat (ms,95%): 9.73 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 10 tps: 1056.00 qps: 21118.01 (r/w/o: 14785.01/4221.00/2112.00) lat (ms,95%): 21.89 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 10 tps: 964.00 qps: 19234.01 (r/w/o: 13455.01/3851.00/1928.00) lat (ms,95%): 25.28 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 10 tps: 751.00 qps: 15007.05 (r/w/o: 10513.03/2992.01/1502.00) lat (ms,95%): 23.95 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 10 tps: 218.00 qps: 4425.99 (r/w/o: 3104.99/885.00/436.00) lat (ms,95%): 28.16 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 10 tps: 61.00 qps: 1206.95 (r/w/o: 838.97/245.99/122.00) lat (ms,95%): 694.45 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 10 tps: 32.98 qps: 661.68 (r/w/o: 463.78/131.94/65.97) lat (ms,95%): 475.79 err/s: 0.00 reconn/s: 0.00
[ 31s ] thds: 10 tps: 33.01 qps: 668.16 (r/w/o: 478.12/124.03/66.02) lat (ms,95%): 1506.29 err/s: 0.00 reconn/s: 0.00
[ 32s ] thds: 10 tps: 148.04 qps: 2936.81 (r/w/o: 2046.57/594.16/296.08) lat (ms,95%): 746.32 err/s: 0.00 reconn/s: 0.00
[ 33s ] thds: 10 tps: 886.00 qps: 17724.99 (r/w/o: 12409.99/3543.00/1772.00) lat (ms,95%): 20.37 err/s: 0.00 reconn/s: 0.00
[ 34s ] thds: 10 tps: 625.00 qps: 12505.00 (r/w/o: 8757.00/2498.00/1250.00) lat (ms,95%): 27.66 err/s: 0.00 reconn/s: 0.00
[ 35s ] thds: 10 tps: 689.00 qps: 13784.06 (r/w/o: 9654.04/2752.01/1378.01) lat (ms,95%): 23.95 err/s: 0.00 reconn/s: 0.00
[ 36s ] thds: 10 tps: 56.00 qps: 1081.02 (r/w/o: 742.02/227.00/112.00) lat (ms,95%): 101.13 err/s: 0.00 reconn/s: 0.00
[ 37s ] thds: 10 tps: 2.00 qps: 58.00 (r/w/o: 44.00/10.00/4.00) lat (ms,95%): 1708.63 err/s: 0.00 reconn/s: 0.00
[ 38s ] thds: 10 tps: 3.99 qps: 42.95 (r/w/o: 23.97/10.99/7.99) lat (ms,95%): 1869.60 err/s: 0.00 reconn/s: 0.00
[ 39s ] thds: 10 tps: 5.01 qps: 104.12 (r/w/o: 75.09/19.02/10.01) lat (ms,95%): 3773.42 err/s: 0.00 reconn/s: 0.00
[ 40s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 41s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 42s ] thds: 10 tps: 1335.06 qps: 26730.31 (r/w/o: 18713.92/5346.26/2670.12) lat (ms,95%): 12.52 err/s: 0.00 reconn/s: 0.00
[ 43s ] thds: 10 tps: 657.00 qps: 13151.03 (r/w/o: 9204.02/2633.01/1314.00) lat (ms,95%): 25.74 err/s: 0.00 reconn/s: 0.00
[ 44s ] thds: 10 tps: 1203.00 qps: 24070.05 (r/w/o: 16864.03/4800.01/2406.00) lat (ms,95%): 20.37 err/s: 0.00 reconn/s: 0.00
[ 45s ] thds: 10 tps: 732.00 qps: 14663.96 (r/w/o: 10249.97/2949.99/1464.00) lat (ms,95%): 23.10 err/s: 0.00 reconn/s: 0.00
[ 46s ] thds: 10 tps: 231.00 qps: 4585.05 (r/w/o: 3212.03/911.01/462.00) lat (ms,95%): 59.99 err/s: 0.00 reconn/s: 0.00
[ 47s ] thds: 10 tps: 97.00 qps: 1969.09 (r/w/o: 1371.06/404.02/194.01) lat (ms,95%): 282.25 err/s: 0.00 reconn/s: 0.00
[ 48s ] thds: 10 tps: 18.99 qps: 349.85 (r/w/o: 254.89/56.98/37.98) lat (ms,95%): 831.46 err/s: 0.00 reconn/s: 0.00
[ 49s ] thds: 10 tps: 1.00 qps: 33.01 (r/w/o: 29.01/2.00/2.00) lat (ms,95%): 1089.30 err/s: 0.00 reconn/s: 0.00
[ 50s ] thds: 10 tps: 0.00 qps: 39.97 (r/w/o: 15.99/23.98/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 51s ] thds: 10 tps: 0.00 qps: 13.01 (r/w/o: 1.00/12.01/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 52s ] thds: 10 tps: 10.99 qps: 187.86 (r/w/o: 147.89/17.99/21.98) lat (ms,95%): 4055.23 err/s: 0.00 reconn/s: 0.00
[ 53s ] thds: 10 tps: 1281.93 qps: 25640.52 (r/w/o: 17952.97/5123.70/2563.85) lat (ms,95%): 8.43 err/s: 0.00 reconn/s: 0.00
[ 54s ] thds: 10 tps: 0.00 qps: 29.97 (r/w/o: 0.00/29.97/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 55s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 56s ] thds: 10 tps: 104.23 qps: 1999.42 (r/w/o: 1407.11/383.85/208.46) lat (ms,95%): 2198.52 err/s: 0.00 reconn/s: 0.00
[ 57s ] thds: 10 tps: 2.00 qps: 67.94 (r/w/o: 57.95/5.99/4.00) lat (ms,95%): 707.07 err/s: 0.00 reconn/s: 0.00
[ 58s ] thds: 10 tps: 10.01 qps: 163.09 (r/w/o: 102.05/41.02/20.01) lat (ms,95%): 1938.16 err/s: 0.00 reconn/s: 0.00
[ 59s ] thds: 10 tps: 0.00 qps: 94.04 (r/w/o: 60.02/34.01/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 60s ] thds: 10 tps: 685.03 qps: 13700.68 (r/w/o: 9590.47/2740.14/1370.07) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 61s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
[ 62s ] thds: 10 tps: 1.00 qps: 1.00 (r/w/o: 0.00/0.00/1.00) lat (ms,95%): 2045.74 err/s: 0.00 reconn/s: 0.00
[ 63s ] thds: 10 tps: 0.00 qps: 0.00 (r/w/o: 0.00/0.00/0.00) lat (ms,95%): 0.00 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            265608
        write:                           75888
        other:                           37944
        total:                           379440
    transactions:                        18972  (300.19 per sec.)
    queries:                             379440 (6003.71 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          63.1994s
    total number of events:              18972

Latency (ms):
         min:                                    2.06
         avg:                                   33.23
         max:                                 5962.41
         95th percentile:                       26.68
         sum:                               630355.96

Threads fairness:
    events (avg/stddev):           1897.2000/12.91
    execution time (avg/stddev):   63.0356/0.48
```

【注意】着重需要关注的几个指标如下：

​			1⃣️ transactions (xxx per sec.)：表达数据库的TPS。

​			2⃣️ queries (xxx per sec.)：表达数据库的QPS。

​			3⃣️ 95th percentile：表达数据库TP95延时。

## 4.清理数据

```shell
sysbench \
--db-driver=mysql \
--time=60 \
--threads=10 \
--report-interval=1 \
--mysql-host=172.16.10.206 \
--mysql-port=3306 \
--mysql-user=root \
--mysql-password=root \
--mysql-db=test_db \
--tables=20 \
--table_size=1000000 \
--db-ps-mode=disable \
oltp_read_write cleanup
```

```sql
DROP DATABASE test_db;
```

## PS：对于数据库测试用例的解读

​		sysbench为数据库压力测试提供了非常多的测试用例（主要偏TP类型），这些测试用例基于lua语言进行封装，默认存储在/usr/local/share/sysbench目录下。

```shell
> cd /usr/local/share/sysbench
> ll

-rwxr-xr-x  1 tangch  admin   1.4K  4 24  2020 bulk_insert.lua
-rw-r--r--  1 tangch  admin    14K  4 24  2020 oltp_common.lua
-rwxr-xr-x  1 tangch  admin   1.3K  4 24  2020 oltp_delete.lua
-rwxr-xr-x  1 tangch  admin   2.4K  4 24  2020 oltp_insert.lua
-rwxr-xr-x  1 tangch  admin   1.2K  4 24  2020 oltp_point_select.lua
-rwxr-xr-x  1 tangch  admin   1.6K  4 24  2020 oltp_read_only.lua
-rwxr-xr-x  1 tangch  admin   1.8K  4 24  2020 oltp_read_write.lua
-rwxr-xr-x  1 tangch  admin   1.1K  4 24  2020 oltp_update_index.lua
-rwxr-xr-x  1 tangch  admin   1.1K  4 24  2020 oltp_update_non_index.lua
-rwxr-xr-x  1 tangch  admin   1.4K  4 24  2020 oltp_write_only.lua
-rwxr-xr-x  1 tangch  admin   1.9K  4 24  2020 select_random_points.lua
-rwxr-xr-x  1 tangch  admin   2.1K  4 24  2020 select_random_ranges.lua
drwxr-xr-x  5 tangch  admin   160B  8  8 09:39 tests
```

​		各种测试用例都是通过oltp_common.lua这个脚本进行抽离和封装。对于sysbench来说定义的测试用例相对**泛化**，当然可以自定义那么需要修改这些lua脚本来达到测试预期。

​		默认情况下对于除了bulk_insert用例来说会创建单独的测试表，其它场景都会使用下面的表结构：

```sql
CREATE TABLE `sbtest%u` (
  `id` int NOT NULL AUTO_INCREMENT,
  `k` int NOT NULL DEFAULT '0',
  `c` char(120) NOT NULL DEFAULT '',
  `pad` char(60) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `k_%u` (`k`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

​		只有bulk_insert用例是采用如下表结构：

```sql
CREATE TABLE `sbtest%u` (
  `id` int NOT NULL,
  `k` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

​		对于默认场景下每个场景的基本情况如下：

| 测试用例              | 测试描述                     | 读   | 写   | 测试详情                                                     |
| --------------------- | ---------------------------- | ---- | ---- | ------------------------------------------------------------ |
| bulk_insert           | **批量**插入                 |      | ✅    | ```INSERT INTO sbtest%u VALUES(?, ?),(?, ?),(?, ?),(?, ?);``` |
| oltp_delete           | 基于**主键**删除             |      | ✅    | ```DELETE FROM sbtest%u WHERE id=?;```                       |
| oltp_insert           | 插入测试                     |      | ✅    | ```INSERT INTO sbtest%u (id, k, c, pad) VALUES (?, ?, ?, ?);``` |
| oltp_point_select     | 基于主键查询                 | ✅    |      | ```SELECT c FROM sbtest%u WHERE id=?;```                     |
| oltp_read_only        | **只读**测试                 | ✅    |      | ```SELECT c FROM sbtest%u WHERE id=?; -- 默认会执行 10 次，由 --point_selects 选项控制```<br/>```SELECT c FROM sbtest%u WHERE id BETWEEN ? AND ?;```<br/>```SELECT SUM(k) FROM sbtest%u WHERE id BETWEEN ? AND ?;```<br/>```SELECT c FROM sbtest%u WHERE id BETWEEN ? AND ? ORDER BY c;```<br/>```SELECT DISTINCT c FROM sbtest%u WHERE id BETWEEN ? AND ? ORDER BY c;``` |
| oltp_read_write       | 读写测试                     | ✅    | ✅    | ```SELECT c FROM sbtest%u WHERE id=?; -- 默认会执行 10 次，由 --point_selects 选项控制```<br/>```SELECT c FROM sbtest%u WHERE id BETWEEN ? AND ?;```<br/>```SELECT SUM(k) FROM sbtest%u WHERE id BETWEEN ? AND ?;```<br/>```SELECT c FROM sbtest%u WHERE id BETWEEN ? AND ? ORDER BY c;```<br/>```SELECT DISTINCT c FROM sbtest%u WHERE id BETWEEN ? AND ? ORDER BY c;```<br/>```UPDATE sbtest%u SET k=k+1 WHERE id=?;```<br/>```UPDATE sbtest%u SET c=? WHERE id=?;```<br/>```DELETE FROM sbtest%u WHERE id=?;```<br/>```INSERT INTO sbtest%u (id, k, c, pad) VALUES (?, ?, ?, ?);``` |
| oltp_update_index     | 基于主键更新(更新索引字段)   |      | ✅    | ```UPDATE sbtest%u SET k=k+1 WHERE id=?;```                  |
| oltp_update_non_index | 基于主键更新(更新非索引字段) |      | ✅    | ```UPDATE sbtest%u SET c=? WHERE id=?;```                    |
| oltp_write_only       | **只写**测试                 |      | ✅    | ```UPDATE sbtest%u SET k=k+1 WHERE id=?;```<br/>```UPDATE sbtest%u SET c=? WHERE id=?;```<br/>```DELETE FROM sbtest%u WHERE id=?;```<br/>```INSERT INTO sbtest%u (id, k, c, pad) VALUES (?, ?, ?, ?);``` |
| select_random_points  | 基于**索引随机**查询         | ✅    |      | ```SELECT id, k, c, pad FROM sbtest%u WHERE k IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);``` |
| select_random_ranges  | 基于**索引随机范围**查询     | ✅    |      | ```SELECT count(k)```<br/>```  FROM sbtest%u```<br/>``` WHERE k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ? OR ```<br/>```       k BETWEEN ? AND ?;``` |

