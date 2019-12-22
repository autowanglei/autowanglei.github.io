<center><font size="7" ><b>Java环境部署</b></font> </center>

# 安装Docker

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

# 安装docker compose

https://www.jianshu.com/p/658911a8cff3

```ruby
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

# CentOS7自启动

1. 写个 shell 脚本

   写一个启动 startup 脚本，在系统启动的时候执行它
   在一个你想放启动脚本的地方创建一个 `startup.sh`，我这里创建在了 `/usr/local/scripts/startup.sh`

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

# redis部署

 	https://www.jianshu.com/p/cb3f94b263da 

1. docker pull redis:5.0.6
2. docker volume create redis
3. docker run -p 6379:6379  --restart=always  --mount source=redis,destination=/var/lib/redis  -v /etc/localtime:/etc/localtime  --name redis  -d redis:5.0.6 redis-server --appendonly yes

# Docker部署

1. **CentOS7下安装Docker-Compose**

   https://www.cnblogs.com/YatHo/p/7815400.html 

   yum -y install epel-release
   yum install python-pip
   pip install --upgrade pip
   pip install docker-compose

2. **centos7.5 下docker部署springboot应用**

   https://blog.csdn.net/u012371097/article/details/83622812

   docker build -t weighbridgecloudservice .

3. **创建容器时[Warning] IPv4 forwarding is disabled. Networking will not work.**

   https://blog.csdn.net/zhydream77/article/details/81902457
   在docker的宿主机中更改以下

   [root@localhost ~]# vi /usr/lib/sysctl.d/00-system.conf

   添加如下代码：
       net.ipv4.ip_forward=1

   重启network服务

   systemctl restart network

4. **docker常用指令**

   docker rmi [image]

   docker stop $(docker ps -a -q)  
   //首先停掉所有的容器

   docker rm $(docker ps -aq) 
   //然后删除所有的容器

   curl www.baidu.com

   docker logs -f --tail -f/100 user-uat

   docker run -d --net host weighbridgecloudservice

5. **linux时间**

   date 查看当前时间
   安装时间同步插件yum install ntpdate
   开启时间同步service ntpdate restart
   设置时区：
   	1）ntpdate time.nist.gov 与一个已知的时间服务器同步
   	2）rm -rf /etc/localtime 删除本地时间
   	3）ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 设置时区为上海

6. **docker镜像导出  导入**

   **6.1save load**

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

   **6.2 export import** 

   - export 示例

     docker export -o nginx-test.tar nginx-test
     ​其中-o表示输出到文件，nginx-test.tar为目标文件，nginx-test是源容器名（name）

   - import 示例

     docker import nginx-test.tar nginx:imp
     ​或
     ​cat nginx-test.tar | docker import - nginx:imp

   **6.3 区别**

   1. export命令导出的tar文件略小于save命令导出的
   2. export命令是从容器（container）中导出tar文件，而save命令则是从镜像（images）中导出
   3. 基于第二点，export导出的文件再import回去时，无法保留镜像所有历史（即每一层layer信息，不熟悉的可以去看Dockerfile），不能进行回滚操作；而save是依据镜像来的，所以导入时可以完整保留下每一层layer信息。如下图所示，nginx:latest是save导出load导入的，nginx:imp是export导出import导入的。

   

   

   





