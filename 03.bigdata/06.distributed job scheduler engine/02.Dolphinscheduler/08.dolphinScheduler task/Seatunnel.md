# 任务类型： WATERDROP  / sea-tunnel 

SeaTunnel 是一个分布式、高性能的数据集成平台，用于海量数据（离线和实时）的同步和转换。

官网：https://seatunnel.apache.org/docs/2.1.3/intro/about/



#### 任务样例

```shell
节点名称:  TASK_SEA_TUNNEL_BATCH_D
描述: 
【任务目的】测试waterdrop任务
【任务场景】通过waterdrop完成跑批任务

Worker分组: waterdrop
环境名称: waterdrop

部署方式: client
Master： local
资源： batch.conf
````





 **工作流实例保存**  

```shell
基本信息
工作流名称: WKF_TASK_SEA_TUNNEL_DEMO
描述： 测试sea-tunnel任务工作流
````



**数据集成，只能适配spark 2.x**