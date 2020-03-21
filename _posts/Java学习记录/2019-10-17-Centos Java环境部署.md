<center><font size="7" ><b>Java环境部署</b></font> </center>
# 1 CentOS7自启动

- sss 

1. 写个 shell 脚本

   写一个启动 startup 脚本，在系统启动的时候执行它
   在一个你想放启动脚本的地方创建一个 `startup.sh`，我这里创建在了 `/usr/local/startup.sh`

   文件内容如下：

   ```
   #!/bin/bash
   # start docker container
   docker start auth-server
   docker start $(docker ps -aq -f status=exited)
   ```

   设置文件权限：

   sudo chmod +x /usr/local/scripts/startup.sh

2. 设置开机启动 

   在 `/etc/rc.d/rc.local` 文件中添加开机启动执行脚本

   `sudo vi /etc/rc.d/rc.local` 编辑文件，添加自定义的启动脚本

   ```
   #!/bin/bash
   # THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
   #
   # It is highly advisable to create own systemd services or udev rules
   # to run scripts during boot instead of using this file.
   #
   # In contrast to previous versions due to parallel execution during boot
   # this script will NOT be run after all other services.
   #
   # Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
   # that this script will be executed during boot.
   
   touch /var/lock/subsys/local
   /usr/local/scripts/startup.sh # 新增自定义启动脚本
   ```

   设置文件权限

   ```
   chmod +x /etc/rc.d/rc.local
   ```

# 2 redis部署

 	https://www.jianshu.com/p/cb3f94b263da 

1. docker pull redis:5.0.6

2. docker volume create redis

3. docker run -p 6379:6379  --restart=always  --mount source=redis,destination=/var/lib/redis  -v /etc/localtime:/etc/localtime  --name redis  -d redis:5.0.6 redis-server --appendonly yes --requirepass "weighbridge_123456"

4. 登录验证

   redis-cli -h 127.0.0.1 -p 6379 -a myPassword

5.  通过config set指令来在线keyspace配置. 

   ```js
   开启所有的事件
   redis-cli config set notify-keyspace-events KEA
   
   开启keyspace Events
   redis-cli config set notify-keyspace-events KA
   
   开启keyspace 所有List 操作的 Events
   redis-cli config set notify-keyspace-events Kl
   ```

# 3 Docker部署

1. **安装Docker**

   https://www.cnblogs.com/qgc1995/p/9553572.html

   ```
   1.yum包更新到最新
   yum update
   2.安装需要的软件包， yum-util 提供yum-config-manager功能，另外两个是devicemapper驱动依赖的
   yum install -y yum-utils device-mapper-persistent-data lvm2
   3.设置yum源
   yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   4.可以查看所有仓库中所有docker版本，并选择特定版本安装
   yum list docker-ce --showduplicates | sort -r
   5.安装Docker
   yum install docker-ce-17.12.1.ce
   6.启动Docker
   systemctl start docker
   7.加入开机启动
   systemctl enable docker
   8.验证安装是否成功
   docker version 
   ```

2. 安装docker compose

   https://www.jianshu.com/p/658911a8cff3

   ```ruby
   sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. docker compose 部署

4. 详见 https://github.com/autowanglei/autowanglei.github.io/tree/master/_posts/Java学习记录/compose

5. 创建容器时[Warning] IPv4 forwarding is disabled. Networking will not work.**

   https://blog.csdn.net/zhydream77/article/details/81902457
   在docker的宿主机中更改以下

   [root@localhost ~]# vi /usr/lib/sysctl.d/00-system.conf

   添加如下代码：
       net.ipv4.ip_forward=1

   重启network服务

   systemctl restart network

6. **docker常用指令**

   docker rmi [image]

   docker stop $(docker ps -a -q)  
   //首先停掉所有的容器

   docker rm $(docker ps -aq) 
   //然后删除所有的容器

   curl www.baidu.com

   docker logs -f --tail -f/100 user-uat

   docker run -d --net host weighbridgecloudservice

7. **linux时间**

   date 查看当前时间
   安装时间同步插件yum install ntpdate
   开启时间同步service ntpdate restart
   设置时区：
   	1）ntpdate time.nist.gov 与一个已知的时间服务器同步
   	2）rm -rf /etc/localtime 删除本地时间
   	3）ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 设置时区为上海

8. **docker镜像导出  导入**

   **8.1 save load**

   - save 示例

   ​		docker save -o nginx.tar nginx:latest
   ​		或
   ​		docker save > nginx.tar nginx:latest
   ​		其中-o和>表示输出到文件，nginx.tar为目标文件，nginx:latest是源镜像名（name:tag）

   - load 示例

   ​		docker load -i nginx.tar
   ​		或
   ​		docker load < nginx.tar
   ​		其中-i和<表示从文件输入。会成功导入镜像及相关元数据，包括tag信息

   **8.2 export import** 

   - export 示例

     docker export -o nginx-test.tar nginx-test
     ​其中-o表示输出到文件，nginx-test.tar为目标文件，nginx-test是源容器名（name）

   - import 示例

     docker import nginx-test.tar nginx:imp
     ​或
     ​cat nginx-test.tar | docker import - nginx:imp

   **8.3 区别**

   1. export命令导出的tar文件略小于save命令导出的
   2. export命令是从容器（container）中导出tar文件，而save命令则是从镜像（images）中导出
   3. 基于第二点，export导出的文件再import回去时，无法保留镜像所有历史（即每一层layer信息，不熟悉的可以去看Dockerfile），不能进行回滚操作；而save是依据镜像来的，所以导入时可以完整保留下每一层layer信息。如下图所示，nginx:latest是save导出load导入的，nginx:imp是export导出import导入的。

   

# 4 rabbitmq

## 4.1 下载rlang和rabbitmq

```
wget https://zysd-shanghai.oss-cn-shanghai.aliyuncs.com/software/linux/erlang/erlang-21.1-1.el7.centos.x86_64.rpm 

wget https://zysd-shanghai.oss-cn-shanghai.aliyuncs.com/software/linux/rabbitmq/rabbitmq-server-3.7.8-1.el7.noarch.rpm 
```

## 4.2 安装Erlang和RabbitMQ

 Erlang是一种通用的面向并发的编程语言，目的是创造一种可以应对大规模并发活动的编程语言和运行环境。

```
rpm -ivh erlang-21.1-1.el7.centos.x86_64.rpm 

rpm -ivh rabbitmq-server-3.7.8-1.el7.noarch.rpm 
```

## 4.3  启动、关闭RabbitMQ

```
systemctl start rabbitmq-server
systemctl stop rabbitmq-server
```

## 4.4 开启后台管理页面

```
rabbitmq-plugins enable rabbitmq_management
```

## 4.5 用户管理

- 配置远程用户访问（否则web登录会提示“User can only log in via localhost”）

  ```
  找到这个文件rabbit.app
  /usr/lib/rabbitmq/lib/rabbitmq_server-3.7.8/ebin/rabbit.app
  将：{loopback_users, [<<”guest”>>]}，
  改为：{loopback_users, []}，
  原因：rabbitmq从3.3.0开始禁止使用guest/guest权限通过除localhost外的访问
  ```

- 删除guest用户

  ```
  rabbitmqctl delete_user guest
  ```

- 创建新用户, 具有管理员权限

  ```
  rabbitmqctl add_user admin password
  rabbitmqctl set_user_tags admin administrator
  ```

## 4.6 设置开机自启

```
chkconfig rabbitmq-server on
```

## 4.7 各种启动出错问题

1. Job for rabbitmq-server.service failed because the control process exited with error code. See “systemctl status rabbitmq-server.service” and “journalctl -xe” for details.

   ```
   ● rabbitmq-server.service - RabbitMQ broker
      Loaded: loaded (/usr/lib/systemd/system/rabbitmq-server.service; disabled; vendor preset: disabled)
      Active: activating (auto-restart) (Result: exit-code) since 一 2019-03-25 04:11:59 CST; 9s ago
     Process: 108118 ExecStop=/usr/sbin/rabbitmqctl shutdown (code=exited, status=127)
     Process: 107940 ExecStart=/usr/sbin/rabbitmq-server (code=exited, status=1/FAILURE)
    Main PID: 107940 (code=exited, status=1/FAILURE)
   
   3月 25 04:11:59 localhost.localdomain systemd[1]: rabbitmq-server.service: control process exited, code=exited status=127
   3月 25 04:11:59 localhost.localdomain systemd[1]: Failed to start RabbitMQ broker.
   3月 25 04:11:59 localhost.localdomain systemd[1]: Unit rabbitmq-server.service entered failed state.
   3月 25 04:11:59 localhost.localdomain systemd[1]: rabbitmq-server.service failed.
   ```

   **根本的原因是rabbitMq和erlang版本不匹配问题，官网有说明**

   **RabbitMQ和Erlang / OTP兼容性矩阵**

    

   | RabbitMQ版本 | 最低要求的Erlang / OTP | 支持的最大Erlang / OTP | 笔记                                                         |
   | :----------: | :--------------------: | :--------------------: | ------------------------------------------------------------ |
   | 3.7.7-3.7.13 |         20.3.X         |         21.3.X         | 1.Erlang / OTP 19.3.x支持[自](https://groups.google.com/forum/#!topic/rabbitmq-users/G4UJ9zbIYHs) 2019年1月1日起停止使用。<br>2.为获得最佳TLS支持，建议使用最新版本的Erlang / OTP 21.x。<br>3.在Windows上，Erlang / OTP 20.2更改了默认的cookie文件位置。 |
   | 3.7.0-3.7.6  |          19.3          |         20.3.x         | 1.为获得最佳TLS支持，建议使用最新版本的Erlang / OTP 20.3.x。<br>2.19.3.6.4之前的Erlang版本具有已知的错误（例如[ERL-430](https://bugs.erlang.org/browse/ERL-430)，[ERL-448](https://bugs.erlang.org/browse/ERL-448)），可以阻止RabbitMQ节点接受连接（包括来自CLI工具）并停止。<br>3.19.3.6.4之前的版本容易受到[ROBOT攻击](https://robotattack.org/)（CVE-2017-1000385）。<br>4.在Windows上，Erlang / OTP 20.2更改了默认的cookie文件位置。 |

2. Failed to start LSB: Enable AMQP service provided by RabbitMQ broker.

   ```perl
   # vi /etc/rabbitmq/rabbitmq-env.conf
   
   NODENAME=rabbit@localhost
   ```





