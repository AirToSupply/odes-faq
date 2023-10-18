# 安装

​	安装较为简单，请参考：[Linux 安装 Maven](https://developer.aliyun.com/article/786760)

# FAQ

（1）如何配置镜像加速？

​	参考：[Linux maven 设置阿里云镜像加速](http://qiushao.net/2020/02/14/Linux/linux-maven-aliyun/index.html)

（2）通过IDEA（2023）结构maven项目在打包时包如下错误：

```shell
[INFO] Compiling 1 source file to /Users/Lagrange/IdeaProjects/test/target/classes
[INFO] -------------------------------------------------------------
[ERROR] COMPILATION ERROR : 
[INFO] -------------------------------------------------------------
[ERROR] 不再支持源选项 5。请使用 7 或更高版本。
[ERROR] 不再支持目标选项 5。请使用 7 或更高版本。
[INFO] 2 errors 
[INFO] -------------------------------------------------------------
```

​	理论上是由于没有指定JAVA版本导致的，需要设置编辑器Java Compile版本和Project中Java SDK版本为项目需要的指定版本。如果设置后没有仍然抱错，推荐在项目的pom.xml文件中显示配置JDK版本，例如：指定为JDK17，则配置如下：

```xml
<properties>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  <maven.compiler.encoding>UTF-8</maven.compiler.encoding>
  <java.version>17</java.version>
  <maven.compiler.source>17</maven.compiler.source>
  <maven.compiler.target>17</maven.compiler.target>
</properties>
```

