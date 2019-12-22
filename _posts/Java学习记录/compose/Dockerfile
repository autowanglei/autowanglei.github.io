FROM java:8
VOLUME /tmp
ADD start/start.sh /start.sh
ADD jars/weighbridgeCloudService-0.0.1-SNAPSHOT.jar weighbridgeCloudService-0.0.1-SNAPSHOT.jar
ENV JAVA_OPTS="-server -Xms1536m -Xmx1536m -XX:NewSize=320m -XX:MaxNewSize=320m -XX:PermSize=96m -XX:MaxPermSize=256m -Xmn500m -XX:MaxTenuringThreshold=5"
ENV TZ="Asia/Shanghai"
ENV LANG="C.UTF-8"
#reset shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENTRYPOINT ["/bin/bash","-c","source /start.sh"]
