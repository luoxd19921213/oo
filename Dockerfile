FROM maven:3.2.3-jdk-8

#安装tomcat
RUN wget -O /tmp/apache-tomcat-8.0.5.tar.gz http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.5/bin/apache-tomcat-8.0.5.tar.gz
RUN cd /usr/local && tar xzf /tmp/apache-tomcat-8.0.5.tar.gz
RUN ln -s /usr/local/apache-tomcat-8.0.5 /usr/local/tomcat
RUN rm /tmp/apache-tomcat-8.0.5.tar.gz

#导入运行脚本 并添加可执行权限
ADD start-everything.sh /usr/local/
RUN chmod a+x /usr/local/start-everything.sh

#解析pom.xml中的依赖
ADD pom.xml /tmp/build/
RUN cd /tmp/build && mvn -q dependency:resolve

#配置环境变量
ENV CATALINA_HOME /usr/local/tomcat

ADD src /tmp/build/src
 
#maven解析编译打包
RUN cd /tmp/build && mvn -q -Dmaven.test.skip=true package \
				&& rm -rf $CATALINA_HOME/webapps/* \
        && mv target/*.war $CATALINA_HOME/webapps/ROOT.war \
        && cd / && rm -rf /tmp/build

#抛出8080端口
EXPOSE 8080

#执行开始脚本并打印日志
CMD /usr/local/start-everything.sh && tail -F /usr/local/tomcat/logs/catalina.out

