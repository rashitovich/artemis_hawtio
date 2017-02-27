FROM alpine:latest

MAINTAINER Timur Akanaev <akanaevtr@mosreg.ru>

RUN apk --no-cache add bash openjdk8-jre wget

ENV ARTEMIS_VERSION 1.5.3

RUN mkdir /opt && cd /opt && \
wget https://archive.apache.org/dist/activemq/activemq-artemis/$ARTEMIS_VERSION/apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \
tar xf apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \
rm apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \
./apache-artemis-$ARTEMIS_VERSION/bin/artemis create broker --password admin --user admin --allow-anonymous --role admin && \
cd ./apache-artemis-$ARTEMIS_VERSION && \
rm -rf examples

EXPOSE 61616

EXPOSE 8161

VOLUME ["/opt/broker/data"]

WORKDIR /opt/broker

CMD ["/opt/broker/bin/artemis-service"]

