## 官方文档

[官方文档](https://www.kingbase.com.cn/tyxsjk/index.htm)



## 安装与部署

[如何在Window系统安装金仓数据库？](https://help.kingbase.com.cn/v8/install-updata/install-windows/index.html)

[如何在Linux系统安装金仓数据库？](https://help.kingbase.com.cn/v8/install-updata/install-linux/index.html) 



## 应用开发

[通过Java操作金仓数据库](https://help.kingbase.com.cn/v8/development/client-interfaces/jdbc/index.html)



## JDBC连接示例

```properties
url=jdbc:kingbase8://172.16.10.12:54321/test
driver=com.kingbase8.Driver
user=system
password=system
dbtable=city
```



## 疑难问题

### 1.如何获取驱动文件？

​	如果是Window本地部署，可以从$KINGBASE_HOME/Interface/jdbc/kingbase8-8.6.0.jar路径下获取驱动文件

​	如果需要应用开发则需要引入maven依赖：(目前maven公共仓库没有相关依赖，需要将jar包上传私服)

​	将jar包上传私服：

```shell
mvn deploy:deploy-file -DgroupId=com.kingbase -DartifactId=kingbase8 -Dversion=8.6.0 -Dpackaging=jar 
-Dfile=$KINGBASE_HOME/Interface/jdbc/kingbase8-8.6.0.jar -Durl=http://172.16.2.124:9089/repository/maven-releases/ 
-DrepositoryId=releases
```

```xml
<dependency>
    <groupId>com.kingbase8</groupId>
    <artifactId>kingbase8</artifactId>
    <version>8.6.0</version>
</dependency>
```

### 2.如何通过第三方客户端工具连接金仓数据库服务端？

​	下载[dbeaver](https://dbeaver.io/download/)，然后可以参考：[如何通过第三方工具连接国产数据库](https://blog.csdn.net/mgxiaomage/article/details/119618549)。相关驱动文件：[kingbase8-8.6.0.jar](./driver/kingbase8-8.6.0.jar)

### 3.金仓数据库和其他数据库的区别？

​	[金仓数据库与MySQL区别](https://blog.csdn.net/BuildH/article/details/120059843)

### 4.如何对金仓数据进行性能测试？

​	[金仓数据库和达梦性能测试实践](https://blog.csdn.net/qq_19524879/article/details/103718274)

### 5.金仓支持的数据类型？

​	[金仓数据库数据类型](https://help.kingbase.com.cn/v8/development/sql-plsql/sql/datatype.html#id2)
