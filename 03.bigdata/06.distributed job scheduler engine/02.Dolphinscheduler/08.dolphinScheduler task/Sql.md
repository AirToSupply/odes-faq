## 任务类型： SQL

### 创建数据源

可在 数据源中心配置对应的数据源。

### 创建任务

#### 任务参数

- 数据源：选择对应的数据源

- sql类型：支持查询和非查询两种。

  - 查询：支持 `DML select` 类型的命令，是有结果集返回的，可以指定邮件通知为表格、附件或表格附件三种模板；

  - 非查询：支持

    ```
    DDL
    ```

    全部命令 和

    ```
    DML update、delete、insert
    ```

    三种类型的命令；

    - 分段执行符号：提供在数据源不支持一次执行多段SQL语句时，拆分SQL语句的符号来进行多次调用数据源执行方法。 例子：1.当数据源选择Hive数据源时，不需要填写此参数。因为Hive数据源本身支持一次执行多段SQL语句； 2.当数据源选择MySQL数据源时，并且要执行多段SQL语句时，需要填写此参数为分号 `;`。因为MySQL数据源不支持一次执行多段SQL语句；

- sql参数：输入参数格式为key1=value1;key2=value2…

- sql语句：SQL语句

- UDF函数：对于HIVE类型的数据源，可以引用资源中心中创建的UDF函数，其他类型的数据源暂不支持UDF函数。

- 自定义参数：SQL任务类型，而存储过程是自定义参数顺序，给方法设置值自定义参数类型和数据类型，同存储过程任务类型一样。区别在于SQL任务类型自定义参数会替换sql语句中${变量}。

- 前置sql:前置sql在sql语句之前执行。

- 后置sql:后置sql在sql语句之后执行。



#### 任务样例

##### **1、HIVE SQL任务**

```shell
任务类型: sql 任务
当前节点设置: hive
节点名称:  TASK_SQL_HIVE_O
描述: 连接2-120的hive 数据源，操作数据

脚本:
select * from ds_hive

前置SQL语句：
insert into ds_hive values(5,'zl')
````

**[注意]： hive sql 不可以有`；`,不然会报错：**

**Error while compiling statement: FAILED: ParseException line 1:34 extraneous input ';'**



##### **2、MYSQL 任务**

```shell
任务类型: sql 任务
当前节点设置: mysql
节点名称:  TASK_SQL_MYSQL_O
描述: 连接2-120的MYSQL 数据源，合并两张表并生成一张新表

脚本:
CREATE TABLE IF NOT EXISTS Students(
SELECT a.*,b.Hobby, b.`Birthday`
FROM  nametest as a
inner join namebby as b
ON a.id = b.id);

````



##### **3、POSTGRESQL 任务**

```shell
任务类型: sql 任务
当前节点设置: postgres
节点名称:  TASK_SQL_POSTGRESQL_O
描述: 连接2-120的 postgres 数据源，操作 postgres 数据

脚本:
select custom_name,count(1) as counts from datatype group by custom_name;

````





**工作流实例保存**

```shell
基本信息
工作流名称: WKF_SQL_DEMO
描述： 创建 sql 任务，测试连接并操作预发布环境数据源
```