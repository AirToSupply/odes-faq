## 官方文档

[官方文档](http://www.gbase.cn/pro/361.html)



## 应用开发

[SpringBoot连接Gbase数据库](https://www.i4k.xyz/article/tyt_XiaoTao/103052061)



## 安装与部署

[南大通用数据库-Gbase-8a-学习-00-单机版安装](https://blog.csdn.net/qq_45111959/article/details/125657035)

[安装GBase8a单机版](https://www.cnblogs.com/braveym/p/16038595.html)

[GBase+8a+MPP+Cluster+V8.6+安装手册](http://www.gbase.cn/tech_info/473.html)



### JDBC连接示例

```shell
url=jdbc:gbase://172.16.2.124:5258/gbcustomer
driver=com.gbase.jdbc.Driver
user=root
password=gbase
dbtable=customer
```

[GBase 8a JDBC连接参数](https://www.gbase8.cn/4879)

[jdbc连接Gbase](https://blog.51cto.com/u_12040951/2169892)



## GBase 8a 用户日常使用手册索引

[GBase 8a 用户日常使用手册索引](https://www.modb.pro/db/81137)



## GBASE 8A 基础管理命令

### 服务的启停

当GBase 8a安装完毕后，其中的gbase.server服务需要手动启动，之后， 每当开机和重新启动机器时，gbase.server服务都需要手动启动。如果用户在 使用中，需要手工进行GBase服务的启停操作，则要使用安装GBase 8a的用户 进行操作。具体命令如下：

```shell
1、启动命令
gbase.server start
2、停止命令
gbase.server stop
3、重新启动命令
gbase.server restart
```

### 修改数据库root用户的密码

安装GBase 8a时，用户将root用户密码设置为空，此时，在 第一次登录GBase 8a时，可以继续为root用户设置密码。

```shell
$ gbase. -uroot
GBase client 8. 5. 1. 2 build 27952. Copyright (c) 2004-2013, GBase. All Rights
Reserved.
gbase> SET PASSWORD FOR root = PASSWORD(,H133%_h,);
Query OK, 0 rows affected
# 退出登录的命令为在gbase>提示符下，键入\q。
gbase> \q
Bye

# 修改root的□令后，重新登录GBase 8a。
$ gbase -uroot
Enter password:
GBase client 8.5.1.2 build 27952. Copyright (c) 2004-2013, GBase. All Rights
Reserved.
gbase >
```


### DDL

#### 数据库

CREATE DATABASE是用给定的名称来创建一个数据库。用户需要获得创建 数据库的权限，才可以使用CREATE DATABASE。
如果用户没有指定IF NOT EXISTS并且该数据库存在，则产生一个错误。

```sql
创建数据库
CREATE DATABASE test;
CREATE DATABASE IF NOT EXISTS test;

删除数据库
DROP DATABASE test;
DROP DATABASE IF EXISTS test;
```

#### 表

用户可以通过CREATE TABLE命令在当前数据库创建一个指定名称的表。
GBase 8a支持两种表类型，普通表、和临时表。
普通表特点: 就是符合SQL标准, 使用CREATE TABLE创建的表。
临时表特点: 使用TEMPORARY关键字，临时表被限制在当前连接 中，当连接关闭时，临时表会自动地删除。

##### 普通表

```sql
GBase 8a支持可以通过下面的语法创建普通表：
CREATE TABLE [IF NOT EXISTS] [database_na^me. ] tbl_na^e
[(create_definition,...)] [table_options];
table_options:
[COMMENT ' comment_value']

删除普通表：
DROP TABLE [IF EXISTS] tbl_name;

创建普通表
CREATE TABLE t3(a int);

删除表
DROP TABLE t3;
```

##### 临时表

临时表生命周期为会话级，当前会话连接结束后自动删除。
临时表支持普通表支持的所有相关操作，包括：DDL、DML、SHOW CREATE TABLE、DESC、SELECT及TEMPORARY TABLE和普通表之间的关联等操作。

```sql
GBase 8a支持临时表，可以通过下面的语法创建临时表：
CREATE TEMPORARY TABLE [IF NOT EXISTS] [database_name. ] tbl_name
[(create_definition,...)] [table_options];
table_options:
[COMMENT ' comment_value']

删除临时表：
DROP [TEMPORARY] TABLE [IF EXISTS] tbl_name;
```

#### 视图

GBase 8a 禁止对视图进行 INSERT，DELETE，UPDATE 动作。

```sql
创建视图
CREATE VIEW v_t AS SELECT a,b FROM t;
CREATE OR REPLACE VIEW v_t AS SELECT b FROM t;
CREATE OR REPLACE VIEW v_t_1 AS SELECT a FROM t;

更改视图
ALTER VIEW v_t(a, b) AS SELECT * FROM t;
ALTER VIEW v_t(aa, bb) AS SELECT a,b FROM t;

删除视图
DROP VIEW IF EXISTS v_t, v_t_1;
```


### DML

使用GBase 8a批量执行INSERT、UPDATE、DELETE等操作的性能，高于单 条执行这些操作。

#### INSERT

GBase 8a支持向表中插入数据。

```sql
INSERT [INTO] [database_name. ]tbl_name [(col_name,...)]
VALUES ({expr | DEFAULT},...),，..)，...；
或
INSERT [INTO] [database_name. ]tbl_name [(col_name,...)]
SELECT ... FROM [database_name. ] tbl_na^e;

创建表t1和t2
CREATE TABLE t1(id int);
CREATE TABLE t2(id int);

示例：插入数据
gbase> INSERT INTO t1 VALUES(1),(2),(3),(4),(5),(6),(2),(3),(1);
Query OK, 9 rows affected
Records:	9 Duplicates:	0 Warnings:	0
gbase> INSERT INTO t2 SELECT * FROM t1;
Query OK, 9 rows affected
Records: 9 Duplicates: 0 Warnings: 0
```

#### UPDATE

GBase 8a支持更新表中数据。

```sql
语法：
UPDATE [database_name.]tbl_name
SET col_name1 = expr1 [, col_name2 = expr2 ...]
[WHERE where_definition]
创建表t1
CREATE TABLE t1(id int);
表t1中插入数据
INSERT INTO t1 VALUES(1),(2),(3),(4),(5),(6),(2),(3),(1);
示例：更新表中数据
gbase> UPDATE t1 SET t0.id = tO.id+1 WHERE t0.id > 1;
Query OK, 7 rows affected
```

#### DELETE

GBase 8a支持删除表中数据。

```sql
语法：
DELETE [FROM] [database_name. ]tbl_name [tbl_alias]
[WHERE where_definition]

创建表t1
CREATE TABLE t(a int);

示例1：标准删除语句。
gbase> INSERT INTO t VALUES(1),(2),(3),(4),(5);
gbase> DELETE FROM t WHERE a = 2;
Query OK, 1 row affected

示例2 :省略关键字FROM的删除。
gbase> INSERT INTO t VALUES(1),(2),(3),(4),(5);
gbase> DELETE t WHERE a = 2;
Query OK, 1 row affected

示例3：按照别名删除，同时省略掉FROM关键字。
gbase> INSERT INTO t VALUES(1),(2),(3),(4),(5);
gbase> DELETE t tt WHERE tt.a=2;
Query OK, 1 row affected
```



## FAQ

### 1.如何获取驱动文件？

​	如果需要应用开发则需要引入依赖：

```
<dependency>
  <groupId>gbase</groupId>
  <artifactId>gbase-connector-java</artifactId>
  <version>8.3.81.53-build-54.5.1-bin</version>
</dependency>
```

### 2.如何通过第三方客户端工具连接GBase 8a数据库服务端？

​	下载[dbeaver](https://dbeaver.io/download/)，然后可以参考：[DBeaver连接GBase数据库](https://blog.csdn.net/ShanHuHai26/article/details/125918233)。相关驱动文件：[gbase-connector.jar](./driver/gbase-connector-java-8.3.81.53-build-54.5.1-bin.jar)

### 3.GBase 8a数据库参数配置

[gbase 8a 配置手册](https://blog.csdn.net/aisirea/article/details/122081934)

### 4.GBase 8a数据库常见问题

[GBase 8a 常见问题](https://www.gbase8.cn/?s=GBase+8a)

[GBase 8a集群导出数据到文件，支持ftp,sftp,hadoop等](https://www.gbase8.cn/119)

### 5.GBase 8a数据库集群安装

[GBase 8a数据库集群新手使用入门](https://codeantenna.com/a/07XqoF7eiZ)

### 6.GBase 8a数据库数据类型与SQL使用

[GBase 8a数据库数据类型与SQL使用](https://www.jaagool.com/member/zaiyuan)


<table>
	<tr>
		<td rowspan="7">数值型</td>
		<td>TINYINT</td>
	</tr>
	<tr>
		<td>SMALLINT</td>
	</tr>
    <tr>
		<td>INT</td>
	</tr>
    <tr>
		<td>BIGINT</td>
	</tr>
    <tr>
		<td>FLOAT</td>
	</tr>
    <tr>
		<td>DOUBLE</td>
	</tr>
    <tr>
		<td>DECIMAL</td>
	</tr>
    <tr>
		<td rowspan="3">字符型</td>
		<td>CHAR</td>
	</tr>
	<tr>
		<td>VARCHAR</td>
	</tr>
    <tr>
		<td>TEXT</td>
	</tr>
    <tr>
        <td>二进制类型</td>
		<td>BLOB</td>
	</tr>
    <tr>
        <td rowspan="4">日期和时间型</td>
		<td>DATE</td>
	</tr>
    <tr>
		<td>DATETIME</td>
	</tr>
    <tr>
		<td>TIME</td>
	</tr>
    <tr>
		<td>TIMESTAMP</td>
	</tr>
</table>







