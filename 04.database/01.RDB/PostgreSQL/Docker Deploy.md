# 安装部署

拉取镜像并运行

```shell
docker run --name postgres-12 \
-e POSTGRES_DB=postgres \
-e POSTGRES_PASSWORD=postgres \
-e POSTGRES_USER=postgres \
-v /data/postgres12:/var/lib/postgresql/data \
-p 5555:5432 \
-d postgres:12
```

进入容器内部

```shell
docker exec -it postgres-12 /bin/bash
```

修改配置文件使得可以远程访问

```shell
> apt-get update && apt-get install vim
> vim /var/lib/postgresql/data/vim pg_hba.conf

host all all 0.0.0.0/0 md5
```

退出容器之后并重启容器。

通过psql客户端进行登录验证：

```shell
psql -h 172.16.2.123 -p 5555 -U postgres -d postgres
```

或者通过docker登录也可以进入数据库：

```shell
docker exec -it postgres-12 psql -h 172.16.2.123 -p 5555 -U postgres -d postgres
```



# FAQ

（1）如何开启CDC数据动态捕获功能？

​		进入容器内部，在postgresql.conf配置文件：

```shell
> vim /var/lib/postgresql/data/postgresql.conf

# - Settings -

wal_level = logical                     # minimal, replica, or logical

# - Archiving -

#archive_mode = on              # enables archiving; off, on, or always
                                # (change requires restart)
```

​		配置完毕之后，需退出容器重启即可。