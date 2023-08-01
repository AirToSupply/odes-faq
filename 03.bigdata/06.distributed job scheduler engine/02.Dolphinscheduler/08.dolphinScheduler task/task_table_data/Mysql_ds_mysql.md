```
{
"user": "root",
"password": "******",
"database": "ds_mysql",
"jdbcUrl": "jdbc:mysql://172.0.0.1:3306/ds_mysql",
"driverClassName": "com.mysql.cj.jdbc.Driver"
}
```

数据库：ds_mysql



### stuname

```sql
DROP TABLE IF EXISTS `stuname`;
CREATE TABLE `stuname`  (
  `id` int(11) NOT NULL,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `sex` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `createTime` datetime(0) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------

-- Records of stuname

-- ----------------------------

INSERT INTO `stuname` VALUES (1, 'zs', '女', 23, 98, '2022-05-05 15:59:40');
INSERT INTO `stuname` VALUES (2, '', '女', 104, 95, '2022-05-04 15:59:43');
INSERT INTO `stuname` VALUES (3, 'bb', '男', 25, 100, '2022-05-05 15:59:48');
INSERT INTO `stuname` VALUES (4, '', '男', 126, 90, '2022-04-30 15:59:50');
INSERT INTO `stuname` VALUES (5, 'we', '男', 25, 89, '2022-05-18 14:00:00');
INSERT INTO `stuname` VALUES (6, 'wa', '女', 25, 89, '2022-05-18 14:00:00');
INSERT INTO `stuname` VALUES (7, '', '女', 111, 98, '2022-05-16 14:00:00');
```







### Stu

```sql
DROP TABLE IF EXISTS `Stu`;
CREATE TABLE `Stu`  (
  `id` int(11) NOT NULL,
  `sname` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `ssex` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `sage` int(11) DEFAULT NULL,
  `sscore` int(11) DEFAULT NULL,
  `createTime` datetime(0) DEFAULT NULL,
  `hobby` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `birthday` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of Stu
-- ----------------------------
INSERT INTO `Stu` VALUES (1, 'zs', '女', 23, 98, '2022-05-05 15:59:40', '唱歌', '2022-05-25 15:59:45');
INSERT INTO `Stu` VALUES (2, 'aa', '女', 24, 95, '2022-05-04 15:59:43', '跳舞', '2022-05-24 16:01:52');
INSERT INTO `Stu` VALUES (3, 'bb', '男', 25, 100, '2022-05-05 15:59:48', '运动', '2022-05-24 16:02:00');
INSERT INTO `Stu` VALUES (4, 'll', '男', 26, 90, '2022-04-30 15:59:50', '阅读', '2022-05-24 16:02:08');
INSERT INTO `Stu` VALUES (5, 'tt', '男', 27, 91, '2022-05-26 15:40:54', '哈哈', '2022-05-26 15:40:57');
```







### Students

```sql
DROP TABLE IF EXISTS `Students`;
CREATE TABLE `Students`  (
  `id` int(11) NOT NULL,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `sex` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `createTime` datetime(0) DEFAULT NULL,
  `Hobby` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `Birthday` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of Students
-- ----------------------------
INSERT INTO `Students` VALUES (2, 'aa', '女', 24, 95, '2022-05-04 15:59:43', '跳舞', '2022-05-13 16:01:52');
INSERT INTO `Students` VALUES (3, 'bb', '男', 25, 100, '2022-05-05 15:59:48', '运动', '2022-05-13 16:02:00');
INSERT INTO `Students` VALUES (4, 'll', '男', 26, 90, '2022-04-30 15:59:50', '阅读', '2022-05-13 16:02:08');
INSERT INTO `Students` VALUES (5, 'we', '男', 25, 89, '2022-05-18 14:00:00', '滑板', '2022-05-18 11:30:30');
INSERT INTO `Students` VALUES (1, 'zs', '女', 23, 98, '2022-05-05 15:59:40', '唱歌', '2022-05-10 15:59:45');
```

