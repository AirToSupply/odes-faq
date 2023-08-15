# 一.如何使用Sysbench

​		具体请参考：[《Sysbench Install And Usage》](https://github.com/AirToSupply/odes-faq/blob/master/07.toolkits/03.sysbench/01-install-and-usage.md)。

# 二.测试方案构造

​		ReadySet服务作为代理数据库的查询缓存，重点关注读数据库和读缓存之间的对比，着重关注两个性能指标：**QPS**（每秒查询请求次数）和**TP95**（查询请求延时95%分位数）；**查询请求平均延时**作为特殊辅助性参考。		

​		由于Sysbench主要是偏向TP的性能测试，对于读测试提供的测试用例不够灵活也不够丰富，涉及主要的测试用例梳理大致如下：

| Sysbench读用例           | SQL                                                          | 查询类型             | 涉及对象 | 是否聚合 | 是否排序 |
| ------------------------ | ------------------------------------------------------------ | -------------------- | -------- | -------- | -------- |
| **oltp_point_select**    | SELECT c FROM sbtest1 WHERE id=1;                            | 点查                 | 主键     |          |          |
| **oltp_read_only**       | SELECT c FROM sbtest1 WHERE id=1;                            | 点查                 | 主键     |          |          |
|                          | SELECT c FROM sbtest1 WHERE id BETWEEN 1 AND 100;            | 范围查询（连续区间） | 主键     |          |          |
|                          | SELECT SUM(k) FROM sbtest1 WHERE id BETWEEN 1 AND 100;       | 范围查询（连续区间） | 主键     | ✅        |          |
|                          | SELECT c FROM sbtest1 WHERE id BETWEEN 1 AND 100 ORDER BY c; | 范围查询（连续区间） | 主键     | ✅        | ✅        |
|                          | SELECT DISTINCT c FROM sbtest1 WHERE id BETWEEN 1 AND 100 ORDER BY c; | 范围查询（连续区间） | 主键     | ✅        | ✅        |
| **select_random_points** | SELECT id, k, c, pad FROM sbtest1 WHERE k IN (?, ?);         | 范围查询（离散）     | 索引     |          |          |
| **select_random_ranges** | SELECT count(k) FROM sbtest1 WHERE k BETWEEN ? AND ? OR k BETWEEN ? AND ?; | 范围查询（连续区间） | 索引     | ✅        |          |

​		这里并不覆盖所有类型的查询，因为ReadySet并不支持所有类型的查询，这里主要重点关注如下：

​		（1）ReadySet读缓存是否支持上述提供的4大类测试用例。

​		（2）缓存代理上游数据库前后，QPS和TP95关键性能指标差异性。

​		（3）ReadySet读缓存在并发访问下的表现。

# 三.测试实验

## 3.1 代理PostgreSQL

### 3.1.1 环境说明

| 环境配置项目 | 关键信息                                                    | 备注                                                         |
| ------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
| 操作系统     | MacOS（2 GHz 双核Intel Core i5）                            |                                                              |
| 内存         | 8G                                                          |                                                              |
| 硬盘         | 250GB（HDD）                                                |                                                              |
| 数据库       | PostgreSQL 14+（Docker部署）                                | 开启binlog                                                   |
| 代理服务     | ReadySet Server main分支 和 beta-2023-07-26（源码编译部署） | 内核参数设置：</br>query-caching=async（自关闭按需缓存，对自动化测试友好）</br>eviction-policy=lru（开启内存最近最小使用策略，减小内存不足下测试指标来回震荡） |
| 网络环境     | 单节点本地                                                  | 代理服务访问容器中的数据库有网络损耗但可以忽略不计           |

### 3.1.2 数据集构造

​		这里对postgres数据库中testdb这个数据库下的1张1000w数据量的表进行连续60s读请求压力测试，同时通过分别通过1个并发，4个并发以及8个并发分别进行实验以及相关数据记录。

```shell
sysbench \
--db-driver=pgsql \
--time=60 \
--threads=10 \
--report-interval=1 \
--pgsql-host=127.0.0.1 \
--pgsql-port=5432 \
--pgsql-user=postgres \
--pgsql-password=readyset \
--pgsql-db=testdb \
--tables=1 \
--table_size=10000000 \
--db-ps-mode=disable \
oltp_point_select prepare
```

​		这里在数据准备阶段采用oltp_point_select进行数据初始化，因为第二章《**测试方案构造**》中涉及的4种测试用例构造的表结构都是相同的。

### 3.1.3 测试实验和数据记录

​		压测上游数据库服务结果如下：

| Test Point               | Thread | QPS     | TP95（ms） | TP50（ms） |
| ------------------------ | ------ | ------- | ---------- | ---------- |
| **oltp_point_select**    | 1      | 814.09  | 1.76       | -          |
|                          | 4      | 1698.02 | 4.41       | -          |
|                          | 8      | 1889.43 | 9.73       | -          |
| **oltp_read_only**       | 1      | 739.00  | 30.26      | -          |
|                          | 4      | 1527.45 | 61.08      | -          |
|                          | 8      | 1731.35 | 118.92     | -          |
| **select_random_points** | 1      | 65.39   | 1.94       | -          |
|                          | 4      | 456.07  | 5.99       | -          |
|                          | 8      | 1745.22 | 11.04      | -          |
| **select_random_ranges** | 1      | 40.93   | 3.12       | -          |
|                          | 4      | 947.14  | 78.74      | -          |
|                          | 8      | 999.43  | 16.41      | -          |

​		压测代理服务结果如下：

| Test Point               | Thread | QPS     | TP95（ms） | TP50（ms） |
| ------------------------ | ------ | ------- | ---------- | ---------- |
| **oltp_point_select**    | 1      | 2402.53 | 0.94       | -          |
|                          | 4      | 5355.02 | 1.55       | -          |
|                          | 8      | 6584.16 | 2.14       | -          |
| **oltp_read_only**       | 1      | 213.39  | 253.3      | 97.25      |
|                          | 4      | 584.86  | 287.38     | 109.38     |
|                          | 8      | 676.01  | 376.49     | 189.15     |
| **select_random_points** | 1      | 13.69   | 125.52     | -          |
|                          | 4      | 1531.72 | 4.33       | -          |
|                          | 8      | 1810.52 | 6.91       | -          |
| **select_random_ranges** | 1      | 340.16  | 20.74      | 11.75      |
|                          | 4      | 172.01  | 51.02      | 23.24      |
|                          | 8      | 180.67  | 123.28     | 44.25      |

### 3.1.4 测试结果解读和分析

​		为了使每个测试用例的具有相对的泛化性，减少资源因素下偶然性，需要在每个测试点位下多运行几次之后然后去除相对极端情况下的数据，这对于直接压测数据库本身还好，只要保证资源因素相对稳定。

​		对于缓存服务来说因为其本身具有内存敏感性，在冷启动下缓存数据需要进行“热身”，所以需要对这种结果进行消除，尽可能多次运行测试点位，在运行点位前后保证环境因素的相对稳定，可以让测试结果保持一定的客观性。

#### 3.1.4.1 oltp_point_select

<div align=center>
  <img src="./assert/image/poc/sysbench/proxy-postgresql/oltp_point_select_qps.png" alt="qps" style="zoom:29%;" />
  <img src="./assert/image/poc/sysbench/proxy-postgresql/oltp_point_select_tp95.png" alt="tp95" style="zoom:29%;" /></div>

<div align=right></div>

#### 3.1.4.2 oltp_read_only

<div align=center>
  <img src="./assert/image/poc/sysbench/proxy-postgresql/oltp_read_only_qps.png" alt="qps" style="zoom:29%;" />
  <img src="./assert/image/poc/sysbench/proxy-postgresql/oltp_read_only_tp95.png" alt="tp95" style="zoom:29%;" />
</div>

#### 3.1.4.3 select_random_points

<div align=center>
  <img src="./assert/image/poc/sysbench/proxy-postgresql/select_random_points_qps.png" alt="qps" style="zoom:29%;" />
  <img src="./assert/image/poc/sysbench/proxy-postgresql/select_random_points_tp95.png" alt="tp95" style="zoom:29%;" />
</div>

#### 3.1.4.4 select_random_ranges

<div align=center>
  <img src="./assert/image/poc/sysbench/proxy-postgresql/select_random_ranges_qps.png" alt="qps" style="zoom:29%;" />
  <img src="./assert/image/poc/sysbench/proxy-postgresql/select_random_ranges_tp95.png" alt="tp95" style="zoom:29%;" />
</div>

