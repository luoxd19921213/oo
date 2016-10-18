FROM daocloud.io/library/tomcat:8.0.15-jre8

# Download Maven
RUN wget -O /tmp/apache-maven-3.1.1-bin.tar.gz http://ftp.jaist.ac.jp/pub/apache/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz
RUN cd /usr/local && tar xzf /tmp/apache-maven-3.1.1-bin.tar.gz
RUN ln -s /usr/local/apache-maven-3.1.1 /usr/local/maven
RUN rm /tmp/apache-maven-3.1.1-bin.tar.gz

# Copy start script
ADD start-everything.sh /usr/local/
RUN chmod a+x /usr/local/start-everything.sh

ADD pom.xml /tmp/build/
RUN cd /tmp/build && /usr/local/maven/bin/mvn -q dependency:resolve

ADD src /tmp/build/src
        
RUN cd /tmp/build && /usr/local/maven/bin/mvn -q -DskipTests=true package \
				&& rm -rf $CATALINA_HOME/webapps/* \
        && mv target/*.war $CATALINA_HOME/webapps/ROOT.war \
        && cd / && rm -rf /tmp/build

EXPOSE 8080

CMD /usr/local/start-everything.sh && tail -F /usr/local/tomcat/logs/catalina.out

