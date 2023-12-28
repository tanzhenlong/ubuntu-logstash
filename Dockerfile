FROM ubuntu:23.04
MAINTAINER devops@citicsinfo.com


WORKDIR /usr/share/logstash


ENV LOGSTASH_VERSION 6.5.4
ENV LOGSTASH_BASE_URL https://www.elastic.co/cn/downloads/past-releases#logstash

ENV TZ=Asia/Shanghai
ENV TIME_ZONE Asia/Shanghai
ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/local/jdk1.8.0_221
ENV JRE_HOME=$JAVA_HOME/jre
ENV CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib
ENV PATH=/usr/share/logstash/bin:$PATH
ENV PATH=$JAVA_HOME/bin:$PATH

ADD  logstash.conf  pipeline/logstash.conf
ADD  jdk-8u221-linux-x64.tar.gz /usr/local/
COPY logstash-6.5.4.tar.gz /tmp
COPY pipelines.yml /tmp
ADD  env2yaml /usr/local/bin/
ADD  docker-entrypoint  /usr/local/bin/


RUN apt-get update && apt-get upgrade -y \
                   && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata  \
                   && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
		  && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \ 
                  && tar -zxf /tmp/logstash-6.5.4.tar.gz  -C /usr/share/ \
	          && groupadd --gid 1001 logstash &&     useradd --uid 1001 --gid 1001       --home-dir /usr/share/logstash --no-create-home       logstash \
	          && mv /usr/share/logstash-6.5.4/* /usr/share/logstash  \
                  && cp -rf /tmp/pipelines.yml  /usr/share/logstash/config/pipelines.yml \
		  && rm -rf /usr/share/logstash-6.5.4 \
		  && chown --recursive logstash:logstash /usr/share/logstash/  \
		  && chown -R logstash:root /usr/share/logstash  \
		  && chmod -R g=u /usr/share/logstash  \
		  && find /usr/share/logstash -type d -exec chmod g+s {} \; \
	          && ln -s /usr/share/logstash /opt/logstash \
		  && chmod 0755 /usr/local/bin/docker-entrypoint  \
		  && chmod 0755 /usr/local/bin/env2yaml \
	          && apt-get clean \
		  && rm -rf /tmp/* /var/cache/* /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/*  

EXPOSE 5044 9600
USER 1001
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
