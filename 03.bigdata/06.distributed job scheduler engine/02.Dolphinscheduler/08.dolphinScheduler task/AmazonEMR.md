# 任务类型： AmazonEMR

## 综述

Amazon EMR任务类型，用于在AWS上创建EMR集群并执行计算任务。 后台使用[aws-java-sdk](https://aws.amazon.com/cn/sdk-for-java/) 将json参数转换为[RunJobFlowRequest](https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/elasticmapreduce/model/RunJobFlowRequest.html) 对象，提交到AWS

## 任务参数

- 节点名称：一个工作流定义中的节点名称是唯一的。
- 运行标志：标识这个节点是否能正常调度,如果不需要执行，可以打开禁止执行开关。
- 描述信息：描述该节点的功能。
- 任务优先级：worker线程数不足时，根据优先级从高到低依次执行，优先级一样时根据先进先出原则执行。
- Worker分组：任务分配给worker组的机器机执行，选择Default，会随机选择一台worker机执行。
- 失败重试次数：任务失败重新提交的次数，支持下拉和手填。
- 失败重试间隔：任务失败重新提交任务的时间间隔，支持下拉和手填。
- 超时告警：勾选超时告警、超时失败，当任务超过"超时时长"后，会发送告警邮件并且任务执行失败.
- json: [RunJobFlowRequest](https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/elasticmapreduce/model/RunJobFlowRequest.html) 对象对应的json，详细json定义参见 [API_RunJobFlow_Examples](https://docs.aws.amazon.com/emr/latest/APIReference/API_RunJobFlow.html#API_RunJobFlow_Examples)

## json参数样例

```json
{
  "Name": "SparkPi",
  "ReleaseLabel": "emr-5.34.0",
  "Applications": [
    {
      "Name": "Spark"
    }
  ],
  "Instances": {
    "InstanceGroups": [
      {
        "Name": "Primary node",
        "InstanceRole": "MASTER",
        "InstanceType": "m4.xlarge",
        "InstanceCount": 1
      }
    ],
    "KeepJobFlowAliveWhenNoSteps": false,
    "TerminationProtected": false
  },
  "Steps": [
    {
      "Name": "calculate_pi",
      "ActionOnFailure": "CONTINUE",
      "HadoopJarStep": {
        "Jar": "command-runner.jar",
        "Args": [
          "/usr/lib/spark/bin/run-example",
          "SparkPi",
          "15"
        ]
      }
    }
  ],
  "JobFlowRole": "EMR_EC2_DefaultRole",
  "ServiceRole": "EMR_DefaultRole"
}
```





#### 任务样例

```shell
节点名称:  TASK_EMR_PI_D
描述: 
【任务目的】测试AmazonEMR任务

jobFlowDefineJson:
{
  "Name": "SparkPi",
  "ReleaseLabel": "emr-5.35.0",
  "Applications": [
    {
      "Name": "Spark"
    }
  ],
  "Instances": {
    "InstanceGroups": [
      {
        "Name": "ElasticMapReduce-master",
        "InstanceRole": "MASTER",
        "InstanceType": "m5.xlarge",
        "InstanceCount": 1
      }
    ],
    "KeepJobFlowAliveWhenNoSteps": false,
    "TerminationProtected": false
  },
  "Steps": [
    {
      "Name": "calculate_pi",
      "ActionOnFailure": "CONTINUE",
      "HadoopJarStep": {
        "Jar": "command-runner.jar",
        "Args": [
          "/usr/lib/spark/bin/run-example",
          "SparkPi",
          "15"
        ]
      }
    }
  ],
  "JobFlowRole": "EMR_EC2_DefaultRole",
  "ServiceRole": "EMR_DefaultRole"
}
````





**工作流实例保存**

```shell
基本信息
工作流名称: WKF_TASK_EMR_DEMO
描述： 测试AmazonEMR任务工作流
````



[ds调用云端大数据任务操作详解](https://git.jshcbd.com.cn/hc-zhongtai/common/empowerbook/blob/master/Deploy/%E5%B9%B3%E5%8F%B0%E7%BB%84%E4%BB%B6%E8%BF%90%E7%BB%B4%E4%B8%8E%E9%83%A8%E7%BD%B2/03.%E5%A4%A7%E6%95%B0%E6%8D%AE%E7%BB%84%E4%BB%B6%E7%9B%B8%E5%85%B3/06.%E5%88%86%E5%B8%83%E5%BC%8F%E8%B0%83%E5%BA%A6/02.Dolphinscheduler/05.Dolphinscheduler3.0.0%E8%B0%83%E5%BA%A6%E4%BA%9A%E9%A9%AC%E9%80%8A%E4%BA%91%E6%9C%8D%E5%8A%A1.md)