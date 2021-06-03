# 语法

## 数据库操作语句

查看所有数据库：

```sql
SHOW DATABASES;
```

创建数据库：

```sql
CREATE DATABASE IF NOT EXISTS DB_NAME
CHARACTER SET = utf8mb4
COLLATE = utf8mb4_general_ci;
```

切换当前数据库：

```sql
USE DB_NAME;
```

删除数据库：

```sql
DROP DATABASE IF EXISTS DB_NAME;
```
## 表操作语句

查看所有表：

```sql
SHOW TABLES;
```

创建表：

```sql
CREATE TABLE tbl_name (
  col_name data_type [NULL | NOT NULL] [DEFAULT expr] [AUTO_INCREMENT] [PRIMARY KEY] [COMMENT 'string'],
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='string';
```

删除表：

```sql
DROP TABLE IF EXISTS tbl_name;
```

查看表结构：

```sql
DESC tbl_name;
```

修改表名：

```sql
ALTER TABLE tbl_name RENAME TO new_tbl_name;
```

增加列：

```sql
ALTER TABLE tbl_name ADD COLUMN col_name data_type [NULL | NOT NULL] [DEFAULT expr] [AUTO_INCREMENT] [PRIMARY KEY] [COMMENT 'string'] [AFTER pre_col_name];
```

删除列：

```sql
ALTER TABLE tbl_name DROP COLUMN col_name;
```

修改列：

```sql
ALTER TABLE tbl_name CHANGE COLUMN old_col_name new_col_name data_type [NULL | NOT NULL] [DEFAULT expr] [AUTO_INCREMENT] [PRIMARY KEY] [COMMENT 'string'] [AFTER pre_col_name];
```

## 存储过程

创建存储过程：

```sql
create procedure db_name.sp_name()
  begin
    sql statments
  end
; 
```

> 注意：存储过程和具体的数据库是关联在一起的，所以在创建存储过程时，最好在存储过程的名称前指定数据库名称：`db_name.sp_name` 。

删除存储过程：

```sql
DROP PROCEDURE IF EXISTS sp_name;
```

简单示例：

创建一个统计 user 表记录数的存储过程：

```sql
create procedure auth.countUser()
  begin
    select count(1) from user;
  end
;
```

调用：

```sql
call countUser();
```

## 视图

### 什么是视图

视图本质上是其对应查询语句的别名。视图也称为虚拟表。

创建视图时，MySQL 并不会把视图对应查询语句的结果集维护在硬盘或者内存里。

对视图进行查询时，MySQL 会把对视图的查询语句转换为对底层表的查询语句，然后执行。

### 创建视图

基于普通表创建视图：

```mysql
CREATE VIEW 视图名 AS 查询语句;
```

如：

```mysql
CREATE VIEW user_view AS SELECT username, real_name FROM user;
```

我们也可以基于一个已有的视图创建视图，如：

```mysql
CREATE VIEW view_by_user_view AS SELECT username FROM user_view;
```

创建视图时也可以自定义列名，自定义列名要和查询语句中的列名一一对应，如：

```mysql
CREATE VIEW view_self_column(u,r) AS SELECT username, real_name FROM user;
```

### 使用视图

视图创建好之后，就可以像普通表一样，对其进行查询操作。如：

```mysql
SELECT * FROM user_view;
```

### 查看视图

查看库里定义了哪些视图：

```mysql
SHOW TABLES;
```

视图就是虚拟表，和查看库里有哪些表语法相同。



查看视图的定义：

```mysql
SHOW CREATE VIEW 视图名;
```

### 删除视图

语法：

```mysql
DROP VIEW 视图名;
```

## 查询语句

### 语法

```sql
SELECT DISTINCT <select_list>
FROM <left_table>
<join_type> JOIN <right_table_1> ON <join_condition>
<join_type> JOIN <right_table_2> ON <join_condition>
WHERE <where_condition>
GROUP BY <group_by_list> HAVING <having_condition>
ORDER BY <order_by_list> asc|desc
LIMIT offset, row_count
;
```

### JOIN 类型

MySQL 支持四种类型的 JOIN :

- cross join
- inner join
- outer join
  - left outer join (left join)
  - right outer join (right join)

### 执行顺序

1. FROM：对 left_table 和 right_table_1 执行笛卡尔积，生成虚拟表 VT1 。
2. ON：对 VT1 应用 ON 筛选器。只有那些使 join_condition 为 true 的行才被插入 VT2 。
3. JOIN：
   - 如果是 INNER JOIN ，则直接使用 VT2 作为 VT3 。
   - 如果是 LEFT JOIN ，将 left_table 里未匹配到的行作为外部行添加到 VT2 ，生成 VT3 。
   - 如果是 RIGHT JOIN ，将 right_table_1 里未匹配到的行作为外部行添加到 VT2 ，生成 VT3 。
   - 如果还有其他 JOIN 子句，则将上述 VT3 作为 left_table 和 right_table_2 重复步骤 1-3 ，生成新的 VT3 。
4. WHERE：对 VT3 应用 WHERE 筛选器。只有使 where_condition 为 true 的行才被插入 VT4 。
5. GROUP BY：按 GROUP BY 子句中的 group_by_list 对 VT4 中的行进行分组，生成 VT5 。
6. HAVING：对 VT5 应用 HAVING 筛选器。只有使 having_condition 为 true 的组才会被插入 VT6 。注意 HAVING 子句里可以使用 select_list 里的别名。
7. SELECT：处理 SELECT 列表，产生 VT7 。
8. DISTINCT：将重复的行从 VT8 中移除，产生 VT8 。
9. ORDER BY：将 VT8 中的行按 ORDER BY 子句中的 order_by_list 排序，生成 VT9 。
10. LIMIT：从 VT9 中按 offset, row_count 将相应的行返回。

# 数据类型

## 数据类型概览

MySQL 常用数据类型：

| 类型         | 存储字节数 |
| ------------ | ---------- |
| int          | 4          |
| bigint       | 8          |
| varchar(n)   |            |
| char(n)      |            |
| decimal(m,n) |            |
| datetime     |            |

## 整数类型

### 四种整数类型
MySQL 支持以下四种长度的整数类型：
|类型|存储字节数|
|-|-|
|TINYINT|1|
|SMALLINT|2|
|MEDIUMINT|3|
|INT|4|
|BIGINT|8|


### 宽度修饰
在声明整数类型时，我们通常会加上 `宽度修饰` ，例如将某一列的数据类型声明为：
```sql
INT(4)
```
括号里的 4 并不表示该列最大只能存放 4 位数的数值，而是表示当该列存放的数值长度小于 4 位，并且该列设置了自动填充 0 时，则当该列的值不满足 4 位时，自动在数值的左边补上 0 ，以达到显示时占用 4 位数字宽度的效果。

所以宽度修饰并不影响字段的存值范围。

### UNSIGNED 修饰
我们可以在整数类型前加上 `UNSIGNED` 修饰符，限制该列不能存放负数。如：
```sql
UNSIGNED INT
```
此时，往列里存放负数会报错。

### AUTO_INCREMENT 修饰
AUTO_INCREMENT 是自增修饰，当往列里存放 NULL 时，会自动填入 value + 1 ，value 是该列的当前最大值，value 的起始值是 0 。

上述自增必须满足一个前提，那就是该列必须声明为 NOT NULL 。如果该列声明为 NULL ，往列里存放 NULL 时，就直接将 NULL 存入了，不会自增。
## 固定位小数类型

固定位数的小数也用于表示精确的数值，例如金额。其类型关键字是 `DECIMAL` 。

在声明某一列为 DECIMAL 类型时，我们常用的语法是：
```sql
DECIMAL(m,n) 
```

其中，m 代表总位数（precision），n 代表小数位数（scale）。

m + n 的最大值是 65 。

如：DECIMAL(5,2) 表示的小数的范围是 -999.99 ~ 999.99 。超过该范围则会报错 `Out of range value for column` 。
## 字符串类型
在 MySQL 中，最常用的两种字符串类型是 CHAR 和 VARCHAR 。

### CHAR
CHAR 类型称为定长字符串类型。语法如下：
```sql
CHAR(n)
```

其中 n 表示该列最多存放 n 个字符（一个汉字也是一个字符），n 可以在 0~255 之间取值。

存入时，值后面的空格是不起作用的。可以理解为先把值后面的空格全部 trim 掉，然后按下面的原则存入。

如果值（trim 后）的字符数 < n ，在存入的时候，会自动在值的后面填充空格，使整个值的长度达到 n 。当取出值的时候，填充的空格又会被自动 trim 掉。

如果值（trim 后）的字符数 > n ，在存入的时候，会报错（Data too long for column ...）。

### CHAR 示例
创建 sample1 表：
```sql
create table sample1
(
    str_char char(4) null
);
```

插入测试值：
```sql
-- 字符数 < n ，存入 ab__ ，取出 ab
insert into sample1 (str_char) value ('ab');

-- 字符末尾有空格，空格无效，自动 trim 掉。
-- 字符数 < n ，仍然存入 ab__ ，取出 ab
insert into sample1 (str_char) value ('ab ');

-- 字符数 > n ，但是 trim 后的字符数 < n
-- 存入 ab__ ，取出 ab
insert into sample1 (str_char) value ('ab   ');

-- 字符数（trim 后） > n ，报错
insert into sample1 (str_char) value ('abcde');
insert into sample1 (str_char) value ('abcde ');
```

### VARCHAR
VARCHAR 类型称为变长字符串类型。语法如下：
```sql
VARCHAR(n)
```

其中 n 表示该列最多存放 n 个字符（一个汉字也是一个字符），n 可以在 0~65535 之间取值。但由于 MySQL 最大的 row-size 是 65535 字节，加上字符编码的不同，有的字符占一个字节，有的字符占两个或三个字节。所以，n 一般是取不到 65535 的。

如果值（无 trim）的字符数 < n ，在存入的时候，值是什么就存入什么（即使末尾有空格，也照样存入），没有自动填充，也没有自动 trim 。取出时也不处理，存入末尾有空格，取出时也会有空格。

如果值（无 trim）的字符数 > n ，在存入的时候，

如果把值末尾的空格 trim 掉之后，字符数 <= n ，就按 n 个字符存入，并发出警告（Data truncated for column ...）；

如果把值末尾的空格 trim 掉之后，字符数仍然 > n ，则直接报错（Data too long for column ...）。

VARCHAR 类型的列会在值的前面增加一个字节或两个字节用于记录值实际占用的字节数。如果值占用的字节数小于 255 字节，就用一个字节记录；如果大于 255 字节，就用两个字节记录。

### VARCHAR 示例
创建 sample1 表：
```sql
create table sample2
(
    str_varchar varchar(4) null
);
```

插入测试值：
```sql
-- 字符数 < n ，存入 ab ，取出 ab
insert into sample2 (str_varchar) value ('ab');

-- 字符数 < n ，存入 ab_ ，取出 ab_
-- 空格保留
insert into sample2 (str_varchar) value ('ab ');

-- 字符数 > n ，但是 trim 后的字符数 < n
-- 按 n 个字符处理，存入 ab__ ，警告，取出 ab__
insert into sample2 (str_varchar) value ('ab   ');

-- 字符数（trim 后） > n ，报错
insert into sample2 (str_varchar) value ('abcde');
insert into sample2 (str_varchar) value ('abcde ');
```
## 时间类型

### 概述
MySQL 有如下五种时间类型：

|类型|零值|
|-|-|
|DATE|'0000-00-00'|
|DATETIME|'0000-00-00 00:00:00'|
|TIMESTAMP|'0000-00-00 00:00:00'|
|TIME|'00:00:00'|
|YEAR|&emsp;0000|

其中最常用的应该是 DATETIME 类型。用于表示日期和时间，如 `'2018-04-28 13:54:42'` 。

在建表时，对于表示日期和时间的列，推荐使用 DATETIME 类型，不推荐使用 TIMESTAMP 类型，后文会讲述原因。

<!-- more -->

### 时间类型
下表展示了五种时间类型表示的数据，标准格式和范围：

|类型|表示的数据|标准格式|范围|
|-|-|-|-|
|DATE|日期|'YYYY-MM-DD'|'1000-01-01' ~ '9999-12-31'|
|DATETIME|日期和时间|'YYYY-MM-DD HH:MM:SS'|'1000-01-01 00:00:00' ~ '9999-12-31 23:59:59'|
|TIMESTAMP|日期和时间|'YYYY-MM-DD HH:MM:SS'|'1970-01-01 00:00:01' UTC ~ '2038-01-19 03:14:07' UTC|
|TIME|时间|'HH:MM:SS'|'-838:59:59' ~ '838:59:59'|
|YEAR|年|YYYY|1901 ~ 2155|

### DATETIME 和 TIMESTAMP 的区别
由于 DATETIME 和 TIMESTAMP 都可以表示完整的时间戳（日期 + 时间），这在建表时给我们带来了极大的困惑，我们到底是应该选择 DATETIME 类型呢，还是选择 TIMESTAMP 类型？

下面我们来阐述一下这两个类型的区别：

#### 范围不同

DATETIME 和 TIMESTAMP 能表示的时间范围不同：

|类型|范围|
|-|-|
|DATETIME|'1000-01-01 00:00:00' ~ '9999-12-31 23:59:59'|
|TIMESTAMP|'1970-01-01 00:00:01' UTC ~ '2038-01-19 03:14:07' UTC|

#### 转换
TIMESTAMP 类型的时间在存入数据库时，会先由服务器时区时间转换为标准时区时间（UTC 时间），从数据库中取出来时再由 UTC 时间转换为服务器时区时间。例如：

假设服务器在中国，中国属于东八区（UTC+08:00），那么上述的转换过程为：`UTC+08:00 --> UTC --> UTC+08:00` 。DATETIME 类型的时间在存储时没有这种转换。

#### 夸时区问题
上述第 2 点带来的另一个不同之处是：从数据库取出来的 TIMESTAMP 类型的时间会随着服务器时区的变化而变化，而DATETIME 类型的时间则一直保持一致，不会随服务器时区的变化而变化。见示例。

#### 索引支持
TIMESTAMP 类型不允许 NULL 值，所以它是支持索引的，DATETIME 类型允许 NULL 值，不支持索引。

#### 查询缓存
查询时，TIMESTAMP 类型的时间会被缓存，DATETIME 类型的时间不会。

### 示例
下面的示例演示 TIMESTAMP 如何受时区的影响。

先创建一个 employee 表，这个表中的 create_time 字段的类型是 TIMESTAMP ，update_time 字段的类型是 DATETIME ：
```sql
CREATE TABLE employee
(
  id          BIGINT UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP  NULL,
  CONSTRAINT employee_id_uindex
  UNIQUE (id)
) ENGINE = InnoDB;
```

往表里插入一条记录，当前时区为 UTC+08:00 。

第一次查询：
```sql
mysql> select * from employee;

+----+---------------------+---------------------+
| id | create_time         | update_time         |
+----+---------------------+---------------------+
|  1 | 2018-04-27 16:13:10 | 2018-04-27 16:13:10 |
+----+---------------------+---------------------+
```

现在把时区改为 UTC-05:00
```sql
SET @@session.time_zone = '-05:00';
```

再次查询：
```sql
mysql> select * from employee;

+----+---------------------+---------------------+
| id | create_time         | update_time         |
+----+---------------------+---------------------+
|  1 | 2018-04-27 03:13:10 | 2018-04-27 16:13:10 |
+----+---------------------+---------------------+
```

可已看到第二次查询得到的 create_time 和第一次查询得到的 create_time 不同，但是 update_time 两次查询的结果相同。说明 TIMESTAMP 类型的时间随时区的变化而变化，而 DATETIME 类型的时间不会。

综上所述，TIMESTAMP 类型会带来跨时区问题，所以不建议使用。建议使用 DATETIME 类型。

# 运维

## Docker 安装单实例 MySQL

### 拉取镜像
拉取 MySQL 镜像：
```
docker pull mysql/mysql-server:tag
```

tag 即 MySQL 的版本，可以是 5.7 ，8.0 或者 lastest 。

查看拉取下来的镜像：
```
docker images
```
```
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
mysql/mysql-server   latest              716286be47c6        3 weeks ago         381MB
```

### 创建容器
接下来我们要创建并启动一个 MySQL 容器，取名为 mysql80 。启动时要考虑配置文件和数据的持久化问题。我们将配置文件持久化到宿主主机的 /etc/my.cnf 文件，数据文件持久化到宿主主机的 /var/lib/mysql 目录。

在 mysql80 容器内，配置文件为 /etc/my.cnf 文件，数据文件位于容器内的 /var/lib/mysql 目录。

也就是说，配置文件和数据文件目录在我们的宿主主机和容器内是同一套命名。
```
docker run --name=mysql80 \
--mount type=bind,src=/path-on-host-machine/my.cnf,dst=/etc/my.cnf \
--mount type=bind,src=/path-on-host-machine/datadir,dst=/var/lib/mysql \
-d mysql/mysql-server:tag
```
```
docker run --name=mysql80 \
-p 3306:3306 \
--mount type=bind,src=/etc/my.cnf,dst=/etc/my.cnf \
--mount type=bind,src=/var/lib/mysql,dst=/var/lib/mysql \
-d mysql/mysql-server:latest
```

容器启动之前，宿主主机的 /etc/my.cnf 文件和 /var/lib/mysql 必须存在，并且 /etc/my.cnf 文件必须以以下内容开头：
```
[mysqld]
user=mysql
```

查看运行成功的容器：
```
docker ps
```

```
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS                   PORTS                 NAMES
786f2e95bb85        mysql/mysql-server:latest   "/entrypoint.sh mysq…"   2 minutes ago       Up 2 minutes (healthy)   3306/tcp, 33060/tcp   mysql80
```

首次启动 MySQL 容器，会自动生成一个初始密码，查看密码：
```
docker logs mysql80 2>&1 | grep GENERATED
```
```
[Entrypoint] GENERATED ROOT PASSWORD: =yM2iM8Up(@kNAG3NOkNEpOJsyb
```

命令行登录 MySQl ：
```
docker exec -it mysql80 mysql -uroot -p
```

更改初始密码：
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
```

### 启停
启动：
```
docker start mysql80
```

停止：
```
docker stop mysql80
```

重启：
```
docker restart mysql80
```

### 参考
[7.6.1 Basic Steps for MySQL Server Deployment with Docker](https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/docker-mysql-getting-started.html)

## 参数

### 什么是参数

跟常见的系统一样，MySQL 也提供了一组可定制化的配置项，让我们根据自己的需要，定制 MySQL 的行为。这些配置项就是 MySQL 的参数。本质上，参数就是一组一组的键值对。

我们可以通过下面三种方式指定一个 MySQL 参数的值：

- 命令行指定：程序启动时设置参数的值
- 配置文件指定：在配置文件（my.cnf）中设置参数的值
- SET 语句指定：使用 SET 语句设置参数的值

### 命令行指定

我们可以在启动 MySQL 服务的命令后面设置参数的值，格式如下（以 mysqld 为例）：

```
mysqld --参数1[=值1] --参数2[=值2] ... --参数n[=值n]
```

下面是一些具体的例子：

禁用客户端使用 TCP 连接服务端：

```
mysqld --skip-networking
```

指定默认的存储引擎为 MyISAM ：

```
mysqld --default-storage-engine=MyISAM
```

### 配置文件中设置参数

MySQL 相关服务在启动时，会读取配置文件（my.cnf）里设置的参数。所以我们也可以在配置文件中设置参数。

配置文件的格式如下：

```
[server]
(具体的选项）

[mysqld]
(具体的选项）

[mysqld_safe]
(具体的选项）

[client]
(具体的选项）

[mysql]
(具体的选项）

[mysqladmin]
(具体的选项）
```

可以看出，配置文件对不同的 MySQL 服务能读取的参数做了分组。下表列出了不同服务能读取到的参数组：

| 程序名       | 类别       | 能读取的参数组                      |
| ------------ | ---------- | ----------------------------------- |
| mysqld       | 启动服务器 | [mysqld]、 [server]                 |
| mysqld_safe  | 启动服务器 | [mysqld]、 [server]、[mysqld_safe]  |
| mysql.server | 启动服务器 | [mysqld]、 [server]、[mysql.server] |
| mysql        | 启动客户端 | [mysql]、 [client]                  |
| mysqladmin   | 启动客户端 | [mysqladmin]、 [client]             |
| mysqldump    | 启动客户端 | [mysqldump]、 [client]              |

### SET 语句指定

我们还可以使用 SET 语句设置参数，语法如下：

在全局作用域下设置参数的值。设置后，参数的值全局有效。服务重启，值失效。

```
SET GLOBAL 参数名=参数值
```

在当前会话下设置参数的值。设置后，在当前会话范围内有效，别的已有的会话或新建的会话都使用原来的参数值。会话关闭，值失效。

```
SET SESSION 参数名=参数值
```

### 查看参数的值

```
SHOW GLOBAL VARIABLES LIKE '';
```

```
SHOW SESSION VARIABLES LIKE '';
```

### 参数的优先级

在同一配置文件的不同组中，如果出现了相同的参数，则以最后一个出现的组中的参数为准。如：

```
[server]
default-storage-engine=InnoDB

[mysqld]
default-storage-engine=MyISAM
```

mysqld 服务启动时，以 [mysqld] 中的配置为准，默认的存储引擎被设置为 MyISAM 。 

命令行指定的参数值优先级高于配置文件指定的。如：

```
[server]
default-storage-engine=InnoDB
```

如果启动命令是：

```
mysqld --default-storage-engine=MyISAM
```

则 mysqld 启动后默认的存储引擎是 MyISAM 。