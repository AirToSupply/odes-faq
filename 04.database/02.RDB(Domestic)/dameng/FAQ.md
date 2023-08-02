## 官方文档

[官方文档](https://eco.dameng.com/docs/zh-cn/start/index.html)



## 安装与部署

[如何在Window系统安装达梦数据库？](https://eco.dameng.com/document/dm/zh-cn/start/install-dm-windows-prepare.html)

[如何在Linux系统安装达梦数据库？](https://eco.dameng.com/document/dm/zh-cn/start/install-dm-linux-prepare.html) **该方式也支持信创环境部署**。



## 应用开发

[通过Java操作达梦数据库](https://eco.dameng.com/document/dm/zh-cn/start/java-development.html)

[通过Spark操作达梦数据库](https://wenku.baidu.com/view/7d8814d8f405cc1755270722192e453610665bd1.html)

[Spark操作达梦数据库采坑实录](https://blog.csdn.net/dickysun1987/article/details/110874056)



## JDBC连接示例

```properties
url=jdbc:dm://172.16.10.171:5236
driver=dm.jdbc.driver.DmDriver
user=SYSDBA
password=SYSDBA
dbtable=DMHR.EMPLOYEE
```



## 疑难问题

### 1.如何获取驱动文件？

​	如果是Window本地部署，可以从${HOME}\opt\dmdbms\drivers\jdbc\路径下获取驱动文件？

​	如果需要应用开发则需要引入maven公共仓库依赖：

```xml
<dependency>
    <groupId>com.dameng</groupId>
    <artifactId>DmJdbcDriver18</artifactId>
    <version>8.1.2.141</version>
</dependency>
```

### 2.如何通过第三方客户端工具连接达梦数据库服务端？

​	下载[dbeaver](https://dbeaver.io/download/)，然后可以参考：[如何通过第三方工具连接国产数据库](https://blog.csdn.net/u012063422/article/details/123759444)。相关驱动文件：[DmJdbcDriver18.jar](./driver/DmJdbcDriver18.jar)

### 3.达梦数据库和其他数据库的区别？

​	[达梦数据库与MySQL区别](https://www.cnblogs.com/fanblogs/p/12836849.html)

### 4.如何对达梦数据进行性能测试？

​	[数据库安装和部署](https://eco.dameng.com/community/post/20220308163713HRI3RMFQZP8EW1L949)

​	[达梦数据库部署和性能测试实践](https://eco.dameng.com/community/post/20220513165845Y2127MA8W2LDNV2NTZ)