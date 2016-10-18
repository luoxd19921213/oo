FROM maven:3.2.3-jdk-8

RUN wget -O /tmp/apache-tomcat-8.0.5.tar.gz http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.5/bin/apache-tomcat-8.0.5.tar.gz
RUN cd /usr/local && tar xzf /tmp/apache-tomcat-8.0.5.tar.gz
RUN ln -s /usr/local/apache-tomcat-8.0.5 /usr/local/tomcat
RUN rm /tmp/apache-tomcat-8.0.5.tar.gz

ADD start-everything.sh /usr/local/
RUN chmod a+x /usr/local/start-everything.sh

ADD pom.xml /tmp/build/
RUN cd /tmp/build && mvn -q dependency:resolve

ENV CATALINA_HOME /usr/local/tomcat

ADD src /tmp/build/src
        
RUN cd /tmp/build && mvn -q -DskipTests=true package \
				&& rm -rf $CATALINA_HOME/webapps/* \
        && mv target/*.war $CATALINA_HOME/webapps/ROOT.war \
        && cd / && rm -rf /tmp/build

EXPOSE 8080

CMD /usr/local/start-everything.sh && tail -F /usr/local/tomcat/logs/catalina.out

