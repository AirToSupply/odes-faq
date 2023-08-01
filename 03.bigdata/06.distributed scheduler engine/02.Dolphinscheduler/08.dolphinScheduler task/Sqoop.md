# 任务类型： Sqoop

```shell
任务类型： sqoop
节点名称:  TASK_SQOOP_MYSQL_TO_HIVE_D
描述: 
【任务目的】测试sqoop任务
【任务场景】通过sqoop抽取mysql数据导入到hive

Worker分组： sqoop
环境名称： sqoop
任务名称： SQOOP_MYSQL_TO_HIVE
流向： import
Hadoop参数： org.apache.sqoop.splitter.allow_text_splitter      true

数据来源
类型： MYSQL
数据源： MYSQL           120_mysql_caif_xmw
模式： 单表
表名： xmw_permission
列类型： 全表导入

数据目的
类型： HIVE
数据库： ds
表名： ods_caif_xmw_xmw_permission

是否覆盖数据源： 是
Hive目标路径： /tmp/ods/caif_xmw/xmw_permission
并发度： 2
````



```shell
任务类型： sql
节点名称:  TASK_SQOOP_MYSQL_TO_HIVE_CHECK_D
描述: 统计 hive ods_caif_xmw_xmw_permission 的 数据量
数据源类型： HIVE
数据源实例: 2-120_hive
SQL类型: 查询
日志显示： 10

SQL语句：
select count(1) from ds.ods_caif_xmw_xmw_permission

前置任务： TASK_SQOOP_MYSQL_TO_HIVE_D
```



**工作流实例保存**

```shell
基本信息
工作流名称: WKF_TASK_SQOOP_DEMO
描述： 测试sqoop任务
```