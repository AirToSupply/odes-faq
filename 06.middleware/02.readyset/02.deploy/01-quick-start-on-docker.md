# 前置准备

## 一.启动数据库

​		这里尝试启动一个postgres数据库：

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

​		（1）postgres版本推荐至少是14。

​		（2）必须开启postgres binlog，设置参数wal_level为logical。

​		

​		通过Docker容器本地启动数据库之后，通过客户端命令验证数据库是否可以连通：

```shell
psql "postgresql://postgres:readyset@127.0.0.1:5432/testdb"
```

## 二.准备数据集

```shell
curl -O https://github.com/readysettech/docs/blob/main/docs/assets/imdb-postgres.sql && 
psql "postgresql://postgres:readyset@127.0.0.1:5432/testdb" -f imdb-postgres.sql
```



# 容器化部署

​		通过如下命令启动：

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

​		由于是在单台机器进行实验，为了防止和postgres数据库端口冲突，readyset服务端口设置为5433。启动之后通过如下命令验证readyset连通性：

```shell
psql "postgresql://postgres:readyset@127.0.0.1:5433/testdb"
```

## 

# 测试验证

​		测试的SQL语句如下，尝试将20w数据量的表和40w数据量的表进行关联。

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

​		可以观察到通过readyset代理查询在第一次查询是非常慢的，后续进行连续多次查询的耗时会急剧下降。