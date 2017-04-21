FROM java:8

MAINTAINER Timur Akanaev <takanaev@gmail.com>

RUN apt-get update && apt-get install -y vim maven tree

ENV ARTEMIS_VERSION 1.5.3
ENV HAWTIO_VERSION 1.5.0

RUN cd /opt && \

# getting Artemis
wget https://archive.apache.org/dist/activemq/activemq-artemis/$ARTEMIS_VERSION/apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \
tar xf apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \
rm apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \

# getting hawt.io
wget https://oss.sonatype.org/content/repositories/public/io/hawt/hawtio-default/$HAWTIO_VERSION/hawtio-default-$HAWTIO_VERSION.war && \
mv *.war apache-artemis-$ARTEMIS_VERSION/web/hawtio.war && \

# getting Artemis hawt.io plugin
git clone https://github.com/rh-messaging/artemis-hawtio && \
cd artemis-hawtio/artemis && \
mvn clean package && \
cd ../.. && \
mv artemis-hawtio/artemis/target/*.war apache-artemis-$ARTEMIS_VERSION/web/artemis-plugin.war && \

# creating Artemis instance
./apache-artemis-$ARTEMIS_VERSION/bin/artemis create broker --password admin --user admin --role admin --allow-anonymous && \
cd ./apache-artemis-$ARTEMIS_VERSION && \
rm -rf examples && \
cd .. && \

# Artemis settings
echo 'JAVA_ARGS="$JAVA_ARGS -Dhawtio.realm=activemq -Dhawtio.role=admin -Dhawtio.rolePrincipalClasses=org.apache.activemq.artemis.spi.core.security.jaas.RolePrincipal -Dhawtio.proxyWhitelist=0.0.0.0"' >> broker/etc/artemis.profile && \
sed -i 's/<\/web>/<app url="hawtio" war="hawtio.war"\/><app url="artemis-plugin" war="artemis-plugin.war"\/><\/web>/g' broker/etc/bootstrap.xml && \
sed -i 's/http:\/\/localhost:8161/http:\/\/0.0.0.0:8161/g' broker/etc/bootstrap.xml

EXPOSE 8161 61616

VOLUME ["/opt/broker/data", "/opt/broker/log", "/opt/broker/tmp"]

WORKDIR /opt/broker

CMD ["/opt/broker/bin/artemis", "run"]
