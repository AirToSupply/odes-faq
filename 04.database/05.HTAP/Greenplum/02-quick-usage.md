# 数据库对象管理

## 数据库

克隆数据库（备份）

```sql
create database target_db TEMPLATE source_db;
```

查看当前模式下的表

```shell
\d
```

查看数据库

```shell
\l
select dat name from pg_database;
```


## 表空间

列出当前系统表空间

```shell
\db
```


## 模式

创建模式，查看当前系统有哪些模式

```shell
-- 1
\dn
-- 2
(2)select current_schema();
-- 3
(3)show search_path;
```

默认情况下不指定情况下会采用缺省的public模式

```sql
create schema sc01;
```

在创建模式同时将owner设置为其他的用户角色（模式owner是gpadmin）

```sql
grant all on database testdw to dylan;
create schema sc02 authorization dylan;
```

删除模式

```sql
drop schema sc01;
```


# 表


## 查看表结构

```shell
\d xxx
```

## 建表时需要考虑哪些？

1.哪些列以及数据类型

2.约束限定可以存储什么样的数据

3.表的分布策略

4.存储方式，压缩和列存

5.大表分区策略


## 如何选择数据类型？

1.对于字符类型，多数选择TEXT或者VARCHAR

2.对于数值类型，尽量选择更小的数据类型

3.对于用作链接的列，选择相同的数据类型


## 如何创建表时设置列约束

1.检查约束（通过制定数据必须满足一个布尔表达式来约束）

```sql
CREATE TABLE products(
product_no integer,
name text,
proce numeric CHECK(price>0)
);
```

2.非空约束

```sql
CREATE TABLE products(
product_no integer NOT NULL,
name text NOT NULL,
proce numeric
);
```

3.唯一约束（确保字段的数据在表唯一）

```sql
CREATE TABLE products(
product_no integer UNIQUE,
name text,
proce numeric
)
DISTRUBUTED BY(product_no);
```

4.主键约束

```sql
CREATE TABLE products(
product_no integer PRIMARY KEY,
name text,
proce numeric
)
DISTRUBUTED BY(product_no);
```

## 如何选择表的分布策略

### 分布策略

1.DISTRUBUTED BY（HASH分布）

2.DISTRUBUTED RANDOMLY BY（随机分布）


### 如何选择

1.均匀数据分布

  尽量确保每个segment实例存储了等量的数据；

  尽可能使用具有唯一性的约束

2.本地操作与分布式操作

  确保查询的处理尽可能在每个实例的本地完成，避免数据重分布；

  不同表尽量使用相同约束，避免使用随机分布

3.均衡查询处理

  尽可能确保每个segment实例能处理等量的工作负载


### 如何定义分布键

  如果没有显式指定，系统会依此考虑使用主键或第一个字段作为HASH分布的分布键

1.HASH分布

```sql
CREATE TABLE products(
name varchar(40),
prod_id integer,
supplier_id integer
)
DISTRUBUTED BY(prod_id);
```

2.随机分布

```sql
CREATE TABLE random_stuff(
things text,
doodads text,
etc text
)
DISTRUBUTED RANDOMLY;
```

## 如何选择存储模式

### 有哪些存储模式

1.堆存储（Heap）：适合数据经常表话的小表，比如维度表

2.只追加（Append-Only）存储：适合仓库中事实大表，通常是批量装载数据并只进行只读查询操作，不支持更新和删除

### 如何查看表的存储模式

\d命令查看storage字段

创建方法：

（1）创建堆表

```sql
CREATE TABLE tb_heap_01(id int) DISTRIDUTED BY (id);
```

（2）创建只追加表

```sql
CREATE TABLE tb_ao_01(id int) WITH (appendonly=true);
```

## 如何选择行存和列存

1.表数据更新：数据需要更新只能选择行存储

2.经常做insert操作：如果经常有数据被insert，考虑选择行存储

3.查询设计的列数量

  如果在select或where中涉及表的全部或大部分列时，考虑行存储。

  列存储适用于在where或having中单列作聚合操作，或者在where条件中使用单个列条件且返回少量的行也合适使用压缩存储。

4.表的列数量

  行查询对于列多或行尺寸相对小的表更高效；

  列存储在只访问宽表的少量列的查询中性能更高

5.压缩

  列存储表具有压缩优势


创建列存储表

需要在WITH子句指定表的存储模式

```sql
CREATE TABLE tb_col_01(
a int,
b text) 
WITH (
appendonly=true,
orientation=column)
DISTRIDUTED BY (a);
```

## 关于压缩表

1.使用压缩只支持append-only表

2.两种压缩方式：表级压缩和列级压缩

### 如何创建压缩表

```sql
CREATE TABLE tb_zlib_01(
a int,
b text) 
WITH (
appendonly=true,
compresstype=zlib,
compresslevel=5);
```
注意：quiclz只有一中压缩级别，而zlib有1-9可选

### 如何检查append-only表的压缩和分布情况

gp提供了内置函数用以检查append-only表的压缩率和分布情况

1.get_ao_distribution(name)

2.get_ao_distribution(oid) # 展示append-only表分布情况

3.get_ao_compression_ratio(name) 

4.get_ao_compression_ratio(oid)  # 计算append-only表的压缩率

### 关于压缩级别

级别越高，压缩效率越高

1.compresstype

  zlib(更高压缩率)

  quicklz(更快压缩)

  rle_type(运行长度编码)

  none(无压缩，缺省)

2.compresslevel

  zlib为1-9级可选 1级最低 9级最高

  quicklz仅1级压缩可选

  rle_type为1-4可选 1级快但压缩率低，4 级较慢但压缩率高

3.blocksize 8k-2M

##  变更表

修改分布策略

```sql
ALTER TABLE tb01 SET DISTRIBUTED BY (b);
```

注意：这样修改之后会递归地引用于所有子分区，表中数据需要在磁盘上进行重新分布

```sql
ALTER TABLE tb01 SET DISTRIBUTED RANDOMLY;
```

注意：这样修改之后不会重新分布数据

## 重分布表数据【重要】

REORGANIZE参数的作用是对于随机分布策略

```sql
ALTER TABLE tb01 SET WITH(REORGANIZE=TRUE);
```

## 删除表

清空表数据

```sql
DROP TABLE tb01; # 会删除与表相关联的索引，触发器等对象，但不会删除与之关联的视图
```

```sql
TRUNCATE tb01;
```

一起删除与表相关的视图

```sql
DROP TABLE tb01 CASCADE;
```

## 分区表

### 分区类型

1.Range分区（日期范围或数字范围）

2.List分区（例如地区，产品）

### 分区表的使用场景

1.表是否足够大？

  大事实表适合做分区表

2.对目前性能不满意

  查询性能低于预期时再考虑分区

3.查询条件是否能匹配分区条件？

  查询语句的WHERE条件是否与考虑分区的列一致

4.数据仓库是否需要滚动历史数据？

  历史数据的滚动需求也是分区设计的考虑因素

5.按照某个规则数据是否可以被均匀的拆分？

  尽量把数据均匀拆分的规则

### 创建分区表

1.定义日期范围分区表

```sql
CREATE TABLE tb_cp_01(
id int,
date date,
amt decimal(10,2))
DISTRIBUTED BY (id)
PARTITION BY RANGE (date)
(
  START (date '2013-01-01') INCLUSIVE
  END   (date '2014-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 day')
);
```

注意：通过使用start end和every子句定义分区增量让GP可以自动产生分区

```sql
create table test_partition_range (
  id int, 
  name varchar(64), 
  fdate varchar(64)
) distributed by (id) 
partition by range(fdate) 
(
  partition p1 start ('2017-01-01') inclusive end ('2017-01-31') exclusive, 
  partition p2 start ('2017-02-01') inclusive end ('2017-02-29') exclusive, 
  default partition default_p
);
```

2.使用单个数字列作为分区键

```sql
CREATE TABLE tb_cp_03(
id int,
rank int,
year int,
gender char(1),
count int)
DISTRIBUTED BY (id)
PARTITION BY RANGE (year)
(
  START (2010)
  END   (2014)
  EVERY (1),
  DEFAULT PARTITION extra
);
```

3.创建列表分区表

可以使用任何数据类型的列作为分区键；可以使用多个列组合作为分区键

```sql
CREATE TABLE tb_cp_04(
id int,
rank int,
year int,
gender char(1),
count int)
DISTRIBUTED BY (id)
PARTITION BY LIST (gender)
(
  PARTITION girls VALUES('F'),
  PARTITION boys  VALUES('M'),
  DEFAULT PARTITION other
);
```

##  查看分区设计

通过pg_paritions视图查看分区表设计情况

1.通过SQL

```sql
SELECT partitionboundary,
       partitiontablename,
       partitionname,
       partitionlevel,
       partitionrank
  FROM pg_partitions
 WHERE tablename = 'tb_cp_05';
```

2.查看创建SUBPARTITION的template

```sql
  select * from pg_partition_templates;
```

3.查看分区表的分区键

```sql
  select * from pg_partition_columns;
```

## 添加新分区

1.原分区表包含subpartition template设计

```sql
ALTER TABLE tb_cp_05 DROP DEFAULT PARTITION;
ALTER TABLE tb_cp_05 ADD PARTITION START (date '2014-01-01') INCLUSIVE END (date '2014-02-01') EXCLUSIVE;
```

2.原分区表不包含subpartition template设计

```sql
ALTER TABLE tb_cp_05 DROP PARTITION 
START (date '2014-02-01') INCLUSIVE 
END (date '2014-03-01') EXCLUSIVE
(SUBPARTITION usa VALUES('usa'),
 SUBPARTITION asia VALUES('asia'),
 SUBPARTITION europe VALUES('europe'));
```

注意：如果存在默认分区，只能从默认分区中拆分新的分区

### 重命名分区

子表名称格式：<父表名称>_<分区层级>_prt_<分区名称>

修改父表名称，将会影响所以分区表

a.修改父表名称

```sql
ALTER TABLE tb_cp_05 rename to tbcp05;
```

b.修改

```sql
ALTER TABLE tb_cp_05 rename PARTITION FOR('2013-06-01') TO Jun13;
# 删除默认分区
ALTER TABLE tbcp05 DROP DEFAULT PARTITION;
# 删除分区
ALTER TABLE "public".test_partition_range DROP PARTITION p1;
# 添加默认分区
ALTER TABLE tbcp05 ADD DEFAULT PARTITION other;
# 清空分区数据
ALTER TABLE tbcp05 TRUNCATE PARTITION FOR (RANK(1));
```





# 序列

创建序列

```sql
CREATE SEQUENCE myserial START 101; # START表示起始值
```

使用序列

可以nextval函数对序列进行操作

```sql
INSERT INTO tb02 VALUES(nextval('myserial'),'abd');
```

注意：nextval不允许在UPDATE和DELETE中使用

查看序列

```sql
select * from myserial;
```

重置一个序列计数器的值

```sql
SELECT setval('myserial', 201);
```

修改序列

```sql
ALTER SEQUENCE myserial RESTART WITH 105;
```

删除序列

```sql
DROP SEQUENCE myserial;
```





# 索引

## 和普通数据库的区别

1.在分布式数据库GP中，应保守使用索引

2，在返回一定量结果的情况下，索引同样可以有效改善压缩AO表上的查询性能

3.GP会自动为主键建立主键索引

4.需确保索引的创建在查询工作负载中真正被使用到

## 创建索引时需要考虑的问题

1.查询工作负载

2.压缩表

3.避免在频繁更新的列上使用索引

4.创建选择性B-tree索引

5.低选择性列上适应位图索引

6.索引列用于关联

7.索引列经常用在查询条件中

## 索引类型

GP中常用的两种索引为：B-tree和Bitmap索引

GP中使用唯一索引时必须包含DK，唯一索引不支持AO表

## Bitmap索引

适宜场景：

a.distinct值数据量在100和100000之间时可以有比较好的表现

b.在特征合适的列上使用Bitmap索引好于B-tree索引

c.位图索引在分析查询方面性能较好

不宜场景：

a.不适合用于唯一性列和distinct值非常高的列

b.不适合大量并发事物更新数据的oltp类型应用

## 创建索引

默认缺省创建B-tree索引

```sql
CREATE INDEX idx_01 ON tb_cp_02(id);
```

创建位图索引

```sql
CREATE INDEX bmidx_01 ON tb_cp_02 USING BITMAP(date);
```

## 检查索引使用

通过explain命令来检查是否使用了索引，在输出结果中查找下面的查询节点以确认索引的使用

a.Index Scan:扫描索引

b.Bitmap Heap Scan:从BitmapAnd,BitmapOr或BitmapIndexScan和数据文件生成的记录所产生的Bitmap中检索数据

c.Bitmap Index Scan:从索引底层扫描那些与查询相匹配的位图索引

d.BitmapAnd,BitmapOr:将来自多个位图索引扫描的节点进行And或Or连接，生成一个新的位图作为输出

## 重建索引

1.重建全部索引

```sql
REINDEX TABLE tb_cp_02;
```

2.重建特定索引

```sql
REINDEX INDEX bmidx_01;
```

注意：更新和删除操作不更新位图索引

删除索引

```sql
DROP INDEX bmidx_01;
```



# 视图

创建视图

```sql
CREATE VIEW vw_01 AS
SELECT * FROM tb_cp_03
WHERE gender='F';
```

注意：视图会忽略ORDER BY操作

删除视图

```sql
DROP VIEW vw_01;
```



# 管理数据

## 插入新纪录

1.全字段插入

```sql
INSERT INTO tb_cp_02 VALUES(1, '2013-12-31', 9.99);
```

2.显式指定列名插入数据

```sql
INSERT INTO tb_cp_02(date, id, amt) VALUES('2013-12-31', 1, 9.99);
```

3.从另一个表中获取并插入到当前表

```sql
INSERT INTO tb_cp_02 SELECT * FROM tb_cp_02 WHERE date > '2013-12-01';
```

4.使用一个命令插入多条记录

```sql
INSERT INTO tb_cp_02(date, id, amt) VALUES
('2013-12-31', 1, 9.99),
('2013-12-31', 2, 1.99),
('2013-12-31', 3, 4.99);
```

## 更新记录

```sql
UPDATE tb_cp_02 SET amt = 11.99 WHERE id = 3;
```

注意：GP中不允许对分布键（DK）进行更新

## 删除记录

1.根据主键删除

```sql
DELETE FROM tb_cp_02 WHERE id = 1;
```

2.删除所有记录

```sql
DELETE FROM tb_cp_02;
```

3.使用TRUNCATE命令快速删除所有记录

```sql
TRUNCATE tb_cp_02;
```

## 事务管理

1.使用BEGIN或START TRANSACTION开始一个事务块

2.使用END和COMMIT提交事务块

3.使用ROLLBACK回滚事务而不提交任何修改

4.使用SAVEPOINT选择性的保存事务点，之后可以使用ROLLBACK TO SAVEPOINT回滚到之前保存的事务

## 事务隔离级别

1.已提交读（缺省）read_committed

当事务使用该隔离级别，SELECT查询稚嫩刚看到查询开始前的数据，读不到SELECT查询期间其他并发事务未提交或已提交的修改

2.可串行化

这谁严格的事务隔离级别。该级别要求事务被串行执行，也就是事务必须一个接一个的执行而不是并行执行

3.未提交读

在GP中与已提交读等同

4.可重复读

在GP中与串行化等同

可以通过show transaction_isolation;命令查看当前事务隔离级别




# 回收空间和分析

## 为什么要进行回收

1.在每个数据库每2百万个事务的时候，对每张表执行回收非常有必要的

2.大量的CREATE和DROP命令会导致系统表迅速膨胀，以至于影响系统性能

3.由于MVCC事务并发模型，已经删除或者更新的记录仍然会占据着磁盘空间

4.如果数据库有大量更新和删除操作，将会产生大量过期记录

## 定期运行可以删除过期记录来回收空间

```sql
VACUUM tb01;
```

## 回收所有过期记录，但耗时会非常长，并且非常不安全

```sql
VACUUM FULL;
```

## 为优化查询进行回收和分析

```sql
VACUUM ANALYZE tb_cp_02;
```

注意：ANALYZE命令收集查询优化器需要统计信息


# 日志文件

## 数据库服务日志文件

GP的日志输出量大而且不需要无期限的保存这些日志，管理员需要定期滚动日志文件

GP的Master和所有Segment实例上开启日志文件按天滚动

服务器日志文件存在每个实例数据目录的$MASTER_DATA_DIRECTORY/pg_log目录下格式：gpdb-YYYY-MM-DD_TIME.csv

## 搜索数据库服务日志文件

通过gplogfilter工具可以查找匹配指定的日志数据

显式master日志文件的最近3行记录

```shell
gplogfilter -n 3
gplogfilter -n 3 /data/.../gpdb-YYYY-MM-DD_*.csv
```

## 程序日志文件

缺省位于～/gpAdminLogs目录下：<script_name>_<date>.log 
-
日志记录格式：
<timestamp>:<utility>:<host>:<user>:[INFO|WARN|FATAL]:<message>



# 系统数据字典


所有的系统数据字段都存放在pg_catalog模式下

标准的postgresql系统数据字典为pg_*

1.列出所有系统字典：\dtS

2.列出所有系统视图：\dvS

案例：

1.查看所有当前连接的进程：

```sql
  select * from pg_stat_activity;
```



# 数据类型

1.CHAR/VARCHAR/TEXT

2.smallint/integer/bigint

3.numeric/real/double/precision

4.timestamp/date/time

5.boolen

6.Array，例如：integer[]


# SQL表达式（高级用法）

1.聚合时进行过滤

```sql
select sum(amt) filter(where id = 1) from tb_cp_02;
```

2.窗口表达式

```sql
select sum(amt) over(partition by id) from tb_cp_02;
```

3.类型转换

```sql
select '2014-01-01'::date;
select cast('2014-01-01' as date);
```

4.关联子查询

```sql
select * from tb01 where exists (
 select 1 from tb03 where tb01.a=tb03.a
);
```


5.数组构造函数

```sql
CREATE TABLE tb_ar_01(
a int[],
b int[]
);

insert into tb_ar_01 values(ARRAY[[1, 2], [3, 4]], ARRAY[[5, 6], [7, 8]]);
```

6.行构造函数

```sql
select row(1, 2,5, 'this is a test');
```


# 函数（高级用法）

1.抓取时间

```sql
select extract(month from date '2013-07-23');
select date_part('day', timestamp '2013-07-23 20:38:40');
```

2.时间计算

```sql
select date '2013-07-23' + interval '1 day';
select date '2013-04-23' + time '3:13';
```

3.时间截取(填补)

```sql
select date_trunc('hour', timestamp '2013-07-23 20:38:40');
```

4.睡眠函数

```sql
select pg_sleep(1); --休眠1s
```

5.系统日期变量

```sql
select current_date;
select current_time;
select now();
select timeofday();
```

6.字符串连接

```sql
select 'a'||'b';
```
7.匹配模式

```sql
select 'abc' similar to '%b%';
```

8.窗口函数

```sql
select a.*, row_number() over(partiton by id order by amt) as rn from tb_cp_02; 
```

9.高级分析函数

```sql
select sum(array[1, 3, 4]); -- 数组汇总
select matrix_transpose(array[[1, 1, 1], [2, 2, 2]]); -- 矩阵转制
select merge_tstats(y, array[1, x1, x2]); -- 回归分析
```




# 自定义函数

一个存储过程就是一个事务，一个简单例子如下：

```sql
CREATE OR REPLACE FUNCTION increment(i integer) RETURNS
integer AS $$
    DECLARE
        j int := 100;
    BEGIN
        RETURN i * j;
    END;
$$ LANGUAGE plpgsql;
```


# 查询计划

获取评估查询计划

```sql
EXPLAIN SELECT * FROM tb_cp_02 WHERE date = '2013-01-01';
```

会真正执行语句，获取实际查询执行情况和审计

```sql
EXPLAIN ANALYZE SELECT * FROM tb_cp_02 WHERE date = '2013-01-01';
```

GP执行计划特点：

1.EXPLAIN输出一个计划为节点组成的树

2.每个节点表示一个独立的操作

3.计划应该从下向上读，每个节点得到的记录向上传递

## EXPLAIN 

1.cost:  获取的磁盘页数，1.0等于一个连续的磁盘页读取第一个评估是开始成本，第二个评估是总成本

2.rows:  输出的记录数，通常小于真实处理的数量。顶层节点评估的数量接近真实值

3.width: 输出的总字节数

简单实例

```sql
EXPLAIN SELECT * FROM tb_cp_02 WHERE date='2013-01-01';
```

输出如下：

```sql
1: Gather Motion 2: 1 (slice1; segments: 2) (cost=0.00..2.02 rows=1 width=17)
2:  -> Append (cost=0.00..2.02 rows=1 width=17)
3:    -> Append-only Scan on tb_cp_02_1_prt_jan131to15 tb_cp_02 (cost=0.00..2.02 rows=1 width=17)
4:      Filter: date = '2013-01-01'::date
```

解读：

[4] 表示进行了数据的过滤

[3] 表示对当前ao表的某个分区进行过滤操作，总成本为2.02，查询出1条数据

[1] 表手从从节点执行该计划之后汇总到主节点的Motion操作，这里从两个segment节点读取数据，并且最终返回1条查询数据


## EXPLAIN ANALYZE

EXPLAIN ANALYZE与EXPLAIN区别在于输出真实运行的评估结果，并不单单是查询计划，主要有如下几个额外信息：

（1）执行查询花费总时间

（2）参与每个节点计划的节点数，只有返回记录的segment实例被统计

（3）操作中的segment实例返回的最大结果数量及其ID

（4）返回最大结果数量的segment实例产生记录的开始时间和结束时间

（5）slice数量以及内存消耗

## 如何查看执行计划

1.计划中是否有一个操作花费时间过长？

2.优化器的评估是否接近实际情况？

3.选择性强的条件是否较早出现？

4.优化器是否选择了最佳的关联顺序？

5.优化器是否选择性的扫描分区表？

6.优化器是否合适的选择了HASH聚合与HASH关联操作？

  HASH操作通常比其他类型的操作要快；

  记录在内存中的比较排序比磁盘块；

  Work_mem wanted: 33649K bytes avg, 33649K byte max(seg0) to lesson





# 系统参数

## 系统数据字典表和视图

1.查询执行SQL请求的对应相关信息以及追踪查询明细

```sql
  select * from pg_stat_activity;
```

2.查询是否有锁的竞争和等待状态，需要如下两个视图的关联

```sql
  select * from pg_locks;
  select * from pg_class;
```

## 参数设置

1.参数类型

  local[本地参数]:  每台节点上的postgres数据库中的postgres.conf配置文件

  global[全局参数]: 在master节点上进行设置

  master-only:    只针对master节点生效


2.master参数

  /data/master/gpseg-1/postgresql.conf

3.segment local参数

  /data/primary/gpseg0/postgresql.conf

  /data/primary/gpseg1/postgresql.conf

4.设置本地化配置参数

  查看当前参数：

```shell
  gpconfig -s gp_vmem_protect_limit

```
  必须修改所有的postgresql.conf文件才能生效

```shell
gpconfig -c gp_vmem_protect_limit -v 4096MB
```

  然后重启gpdb使其生效

```shell
  gpstop -r
```
5.设置master配置参数

  需要在gpdb master实例上设置

  在系统级别设置参数步骤如下：

  a.编辑$MASTER_DATA_DIRECTORY/postgresql.conf文件

  b.对需要修改的参数去掉注释，设置新的值

  c.对于会话级别参数，不需要重启，执行gpstop -u

  d.对于需要重启的参数，执行gpstop -r

6.参数查看

  系统命令：

```shell
     gpconfig --show <...>
     gpconfig -s <...>
```

  数据库命令：

```shell
     show all;
```

## 重要参数

### 1.连接与认证参数

  a.连接参数

    max_connections

    max_prepared_transactions

  b.安全与认证参数

    password_encryption

    ssl

### 2.系统资源消耗参数

  a.内存消耗参数

    控制系统内存使用

    gp_vmen_protect_limit（segment节点使用系统最大的内存）

    shared_buffers

  b.自由空间映射参数

    控制自由空间映射的尺寸

    max_fsm_pages

    max_fsm_relations

  c.操作系统资源参数

    max_files_per_process

    shared_preload_libraries

  d.基于成本的延迟回收参数

    配置VACCUM和ANALYZE的执行成本，不建议在GP中使用

    vacuum_cost_delay

### 3.查询调优参数

  a.查询计划控制参数
    控制查询优化器选择什么样的计划操作类型

    enable_bitmapscan

    enable_indexscan

    enable_sort

  b.查询规划成本估算

    默认已调整最合适GP硬件配置和工作负载特征的状态，建议不要调整

    cpu_*

  c.数据库统计抽样参数

    调整ANALYZE操作数据抽样的数量

    default_statistics_target

    gp_analyze_relactive_error

  d.排序操作配置参数

    gp_enable_sort_*

  e.聚合操作配置参数
    gp_enable_agg_*

### 4.错误报告和日志参数

  a.日志滚动

    log_rotation_*

  b.日志级别

    log_min_*

  c.日志内容

    debug_*

### 5.系统检测参数

  a.SNMP提醒

    GP系统发生意外事件时发送SNMP通知

    gp_snmp_*

  b.邮件提醒

    配置系统发送致命错误事件的邮件提醒

    gp_email_*

  c.GP命令中心代理

    *gpperfmon*

### 6.运行时统计信息收集参数

  控制统计信息收集功能

  track_*

### 7.统计信息自动收集参数

  *autostats*

### 8.工作负载管理参数

  配置GP资源队列，查询优先级，内存使用和并发控制

  gp_vmen_*

  gp_resqueue_*

### 9.锁管理参数

  deadlock_timeout

  max_locks_per_transaction

### 10.外部表参数

   gp_external_*

### 11.AO表参数

   max_appendonly_tables

### 12.数据库和表空间/文件空间参数

   gp_max_tablespaces/filespaces/databases

### 13.GP集群配置参数

   互联网配置参数：gp_interconnect_*

   分派配置参数：gp_enable_direct_dispatch

   故障操作参数：gp_fts_*

   分布式事务管理参数：gp_max_local_distributed_cache

   只读参数：gp_session_id


# 高可用

1.查看nirror和segment的对应关系

```sql
select * from gp_segment_configuration;
```

2.查看standby是否处于同步状态

```sql
select * from gp_stat_replication;
```

如果state字段为NotSynchronized说明同步存在问题

3.恢复一个已经不痛不的standby master

```sql
gpinitstandby -s <standby_master_hostname> -n
```

4.查看primary segment与mirror segment之间的映射关系

```sql
gpstate -m
```

5.从master主机执行命令恢复失败的实例

```sql
gprecoverseg
```

6.如何激活standby
```sql
gpactivestandby -d /data/master/gpseg0
```

-d参数表示指定被激活的standby的数据路径

如果想同时指定另一个主机作为新的standby可以采用-c参数

```sql
gpactivestandby -d /data/master/gpseg0 -c new_host
```
7.检查standby master配置

```sql
gpstate -f
```
