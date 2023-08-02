## 官方文档

[官方文档](https://www.microsoft.com/zh-cn/sql-server/sql-server-downloads)



## 应用开发

[Spring Boot连接SqlServer数据库](https://bibichuan.github.io/posts/abd4fdb7.html)

[jdbc连接sql server 2017(mssql)](https://cloud.tencent.com/developer/article/1537248)


## 安装与部署

[Linux下安装SQL Server 及SqlServer基本命令CRUD](https://cloud.tencent.com/developer/article/1456190)

[Linux安装SQL Server 2017（安装篇SQL Server on linux）](https://blog.csdn.net/sqlserverdiscovery/article/details/79193959)



### JDBC连接示例

```shell
url=jdbc:sqlserver://172.16.2.124:1433;DatabaseName=master
driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
user=sa
password=msql@123
dbtable=t_student1
```

[JDBC 连接 SQL Server 数据库 - 创建连接 URL](https://blog.csdn.net/cfhacker007/article/details/4356044)

[Building the connection URL](https://learn.microsoft.com/en-us/sql/connect/jdbc/building-the-connection-url?view=sql-server-ver15)


## FAQ

### 1.如何获取驱动文件？

​	如果需要应用开发则需要引入依赖：

```
<dependency>
    <groupId>com.microsoft.sqlserver</groupId>
    <artifactId>mssql-jdbc</artifactId>
    <version>11.2.1.jre18</version>
</dependency>
```

[Microsoft JDBC Driver for SQL Server 支持矩阵](https://learn.microsoft.com/zh-cn/sql/connect/jdbc/microsoft-jdbc-driver-for-sql-server-support-matrix?view=sql-server-ver16)

### 2.如何通过第三方客户端工具连接SQL Server数据库？

​	下载[dbeaver](https://dbeaver.io/download/)，然后可以参考：[DBeaver连接sqlserver数据库](https://blog.51cto.com/51power/5181813)。

### 3.SQL Server数据库参数配置

[配置数据库引擎实例 (SQL Server)](https://learn.microsoft.com/zh-cn/sql/database-engine/configure-windows/configure-database-engine-instances-sql-server?view=sql-server-2017)

### 4.SQL Server常见问题

[SQL Server常见问题总结](https://www.cnblogs.com/double-K/p/6264814.html)

[SQL Server数据库常见问题（一）](https://blog.csdn.net/Miha_Singh/article/details/79797076)

### 5.SQL Server压测

[【sql server压测】sql server压测工具对比](https://www.cnblogs.com/gered/p/13723193.html)

[测试结果：SQL Server 关键性能指标](https://learn.microsoft.com/zh-cn/biztalk/technical-guides/test-results-sql-server-key-performance-indicators)
