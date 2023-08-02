# Postgresql备份与还原命令

## 1、创建模拟数据库并添加数据

```sql
--创建数据库
create DATABASE runoobdb;
-- 创建表
CREATE TABLE COMPANY(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);
-- 添加数据
INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY) VALUES (1, 'Paul', 32, 'California', 20000.00);
```



## 2、备份数据库

### 1、备份：

一般在安装PG数据库的时候，都会有个bin目录，在这个目录下有pg_dump、pg_restore、psql这些可执行文件。
linux备份（这是没有配置环境变量的时候，需要进入这个目录，否则不需要）
到bin目录下：

```shell
pg_dump -U postgres -d myDBname -f dump.sql
```

其中

- postgres是用户名
- myDBname是数据库名
- dump.sql是文件名

例如：

```shell
./pg_dump -h 127.0.0.1 -U postgres -p 5432 -F c -f /hd01/pg_back/databack/data.bak  db_test
```

-- 备份数据库命令

```shell
/workspace/postgres/bin/pg_dump -h 172.16.2.120 -p 5432 -U postgres runoobdb > /workspace/postgres/runoobdb.sql
```

```shell
-- 172.16.10.72 postgres 备份命令
cd /usr/pgsql-9.6/bin
./pg_dump -h 172.16.10.72 -p 5432 -U postgres army > /data/psql-data-backup/army.sql
```



### 2、还原

还原也是同理到bin目录下，还原首先要准备一个空库，如果想用之前的库名字，需要先删除之前的库，再新建一个空库：

```shell
createdb newDBname

psql -d newDBname -U postgres -f dump.sql
```

其中

- postgres是用户名
- newDBname是数据库名
- dump.sql是文件名

例如：

```shell
./pg_restore -h 127.0.0.1 -U postgres -p 5432 -d db_test<  /hd01/pg_back/databack/data.bak
```

bin目录下有上述pg_dump和pg_restore的可执行文件，pg_restore有时候根据还原的文件格式来，有时候会用psql，这两个都是还原命令，用错了会有提示的。

-- linux还原数据库

```shell
/workspace/postgres/bin/psql -h 172.16.2.120 -p 5432 -U postgres -d runoobdb -f /workspace/postgres/runoobdb.sql
```

```
-- 还原命令
psql -h 172.16.2.123 -p 5555 -U postgres -d dolphinscheduler300 -f /tmp/psql-data-backup/dolphinscheduler300.sql
```



## 3、删除已备份数据库

PG有时候会提示有会话连接，不能删除，这时候断开PG会话，再删除该库，注意需要在别的库设为活动对象的时候，再执行删库语句删除之前的数据库。

```sql
--断开pg会话  /*如果不断开会话直接删除会报错  there is 1 other session using the database.*/
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='runoobdb';
-- 删除数据库
DROP DATABASE runoobdb;
```

参考文档：https://www.jianshu.com/p/699c03cb139c

## 4、自动化备份恢复工具

​		备份：pg_backup.sh

```shell
#!/bin/bash

# 数据库家目录
export PGHOME=
# 数据库超级用户
export PGUSER=postgres
# 数据库密码
export PGPASSWORD=postgres
# 数据库IP
PGHOST=
# 数据库端口
PGPORT=5432
# 备份数据库白名单
PGDB_WHITE_LIST=
# 备份文件路径
PGDB_DUMP_PATH=

for database in `cat $PGDB_WHITE_LIST | grep '^[^#]'`
do
  st=$(echo "`date +%s.%N`*1000" | bc)
  echo "dump [PGDB: (" $database ")] doing"

  $PGHOME/bin/pg_dump -h $PGHOST -p $PGPORT -U $PGUSER $database > $PGDB_DUMP_PATH/$database.sql

  et=$(echo "`date +%s.%N`*1000" | bc)
  diff=$(echo "$et-$st" | bc) 
  echo "dump [PGDB: (" $database ")] done, [Time cost(ms)]: " $diff
  echo "---------------------------------------------------------------------------------------------------------"
done
```

​		恢复：pg_resume.sh

```shell
#!/bin/bash

# 数据库家目录
export PGHOME=
# 数据库超级用户
export PGUSER=postgres
# 数据库密码
export PGPASSWORD=postgres
# 数据库IP
PGHOST=
# 数据库端口
PGPORT=5432
# 备份数据库白名单
PGDB_WHITE_LIST=
# 备份文件路径
PGDB_DUMP_PATH=

for database in `cat $PGDB_WHITE_LIST | grep '^[^#]'`
do
  st=$(echo "`date +%s.%N`*1000" | bc)
  echo "dump [PGDB: (" $database ")] doing"

  $PGHOME/bin/psql -h $PGHOST -p $PGPORT -U $PGUSER -d $database -f $PGDB_DUMP_PATH/$database.sql

  et=$(echo "`date +%s.%N`*1000" | bc)
  diff=$(echo "$et-$st" | bc) 
  echo "dump [PGDB: (" $database ")] done, [Time cost(ms)]: " $diff
  echo "---------------------------------------------------------------------------------------------------------"
done
```





