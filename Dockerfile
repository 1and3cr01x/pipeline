FROM ubuntu:14.04

ENV SCALA_VERSION=2.10.4
ENV CASSANDRA_VERSION=2.2.3
ENV SPARK_CASSANDRA_CONNECTOR_VERSION=1.4.0
ENV CONFLUENT_VERSION=1.0.1
ENV ELASTICSEARCH_VERSION=1.7.3
ENV ELASTICSEARCH_SPARK_CONNECTOR_VERSION=2.1.2
ENV LOGSTASH_VERSION=2.0.0
ENV KIBANA_VERSION=4.2.0
ENV NEO4J_VERSION=2.2.3
ENV REDIS_VERSION=3.0.5
ENV JEDIS_VERSION=2.7.3
ENV SBT_VERSION=0.13.9
ENV SPARK_VERSION=1.5.1
ENV SPARKNOTEBOOK_VERSION=0.6.1
ENV HADOOP_VERSION=2.6.0
ENV TACHYON_VERSION=0.7.1
ENV ZEPPELIN_VERSION=0.6.0
ENV ALGEBIRD_VERSION=0.11.0
ENV GENSORT_VERSION=1.5

EXPOSE 80 4042 9160 9042 9200 7077 38080 38081 6060 6061 8090 10000 50070 50090 9092 6066 9000 19999 6081 7474 8787 5601 8989 7979 4040 6379 8888 54321 8099

RUN \
 apt-get update \
 && apt-get install -y software-properties-common \
 && add-apt-repository ppa:webupd8team/java \
 && apt-get update \
 && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
 && apt-get install -y oracle-java8-installer \
 && apt-get install -y oracle-java8-set-default \
 && apt-get install -y curl \
 && apt-get install -y wget \
 && apt-get install -y vim \
 && apt-get install -y linux-tools-common linux-tools-generic linux-tools-`uname -r` \
 && apt-get install -y nodejs \
 && apt-get install -y npm \

# Add syntax highlighting for vim
 && mkdir -p ~/.vim/{ftdetect,indent,syntax} && for d in ftdetect indent syntax ; do curl -o ~/.vim/$d/scala.vim \        https://raw.githubusercontent.com/derekwyatt/vim-scala/master/syntax/scala.vim; done \

# Start in Home Dir (/root)
 && cd ~ \

# Git
 && apt-get install -y git \

# Pip
# && apt-get install -y python-pip \

# SSH
 && apt-get install -y openssh-server \

# Java
 && apt-get install -y default-jdk \

# Apache2 Httpd
 && apt-get install -y apache2 \

# cmake
 && apt-get install -y cmake \

# perf-map-agent
 && git clone --depth=1 https://github.com/jrudolph/perf-map-agent \
 && cd perf-map-agent \
 && cmake . \
 && make \
 && cd ~ \

# Flame Graph
 && git clone --depth=1 https://github.com/brendangregg/FlameGraph \

# Vector
# && git clone git://git.pcp.io/pcp \
# && cd pcp \
# && ./configure --prefex=/usr --sysconfdir=/etc --localstatedir=/var \
# && make \
# && make install \
# && cd ~ \
# && git clone https://github.com/Netflix/vector.git \

# Sbt
 && wget https://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.tgz \
 && tar xvzf sbt-${SBT_VERSION}.tgz \
 && rm sbt-${SBT_VERSION}.tgz \
 && ln -s /root/sbt/bin/sbt /usr/local/bin \

# Get Latest Pipeline Code
 && cd ~ \
 && git clone https://github.com/fluxcapacitor/pipeline.git \

# Sbt Clean
 && sbt clean clean-files

RUN \
# Start from ~
 cd ~ \

# iPython
# && pip install jupyter \

# Ganglia
 && DEBIAN_FRONTEND=noninteractive apt-get install -y ganglia-monitor rrdtool gmetad ganglia-webfrontend \

# MySql (Required by Hive Metastore)
 && DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server \
 && apt-get install -y mysql-client \
 && apt-get install -y libmysql-java \

# Python Data Science Libraries
 && apt-get install -y python-matplotlib \
 && apt-get install -y python-numpy \
 && apt-get install -y python-scipy \
 && apt-get install -y python-sklearn \
 && apt-get install -y python-dateutil \
 && apt-get install -y python-pandas-lib \
 && apt-get install -y python-numexpr \
 && apt-get install -y python-statsmodels \

# R
 && apt-get install -y r-base \
 && apt-get install -y r-base-dev \

# Logstash
 && wget https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz \
 && tar xvzf logstash-${LOGSTASH_VERSION}.tar.gz \
 && rm logstash-${LOGSTASH_VERSION}.tar.gz \

# Kibana
 && wget http://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz \
 && tar xvzf kibana-${KIBANA_VERSION}-linux-x64.tar.gz \
 && rm kibana-${KIBANA_VERSION}-linux-x64.tar.gz \

# Apache Cassandra
 && wget http://www.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
 && tar xvzf apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
 && rm apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \

# Apache Kafka (Confluent Distribution)
 && wget http://packages.confluent.io/archive/1.0/confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \
 && tar xvzf confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \
 && rm confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \

# ElasticSearch
# && wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ELASTICSEARCH_VERSION}/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
 && wget http://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
 && tar xvzf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
 && rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \

# Apache Spark
 && wget https://s3.amazonaws.com/fluxcapacitor.com/packages/spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \
 && tar xvzf spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \
 && rm spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \

# Apache Zeppelin
 && wget https://s3.amazonaws.com/fluxcapacitor.com/packages/zeppelin-${ZEPPELIN_VERSION}-spark-${SPARK_VERSION}-hadoop-${HADOOP_VERSION}-fluxcapacitor.tar.gz \
 && tar xvzf zeppelin-${ZEPPELIN_VERSION}-spark-${SPARK_VERSION}-hadoop-${HADOOP_VERSION}-fluxcapacitor.tar.gz \
 && rm zeppelin-${ZEPPELIN_VERSION}-spark-${SPARK_VERSION}-hadoop-${HADOOP_VERSION}-fluxcapacitor.tar.gz \

# Tachyon 
 && wget https://github.com/amplab/tachyon/releases/download/v${TACHYON_VERSION}/tachyon-${TACHYON_VERSION}-hadoop2.6-bin.tar.gz \
 && tar xvfz tachyon-${TACHYON_VERSION}-hadoop2.6-bin.tar.gz \
 && rm tachyon-${TACHYON_VERSION}-hadoop2.6-bin.tar.gz \

# Spark Notebook
# && apt-get install -y screen \
# && wget https://s3.amazonaws.com/fluxcapacitor.com/packages/spark-notebook-${SPARKNOTEBOOK_VERSION}-scala-${SCALA_VERSION}-spark-1.5.0-hadoop-${HADOOP_VERSION}-with-hive-with-parquet.tgz \
# && tar xvzf spark-notebook-${SPARKNOTEBOOK_VERSION}-scala-${SCALA_VERSION}-spark-1.5.0-hadoop-${HADOOP_VERSION}-with-hive-with-parquet.tgz \
# && rm spark-notebook-${SPARKNOTEBOOK_VERSION}-scala-${SCALA_VERSION}-spark-1.5.0-hadoop-${HADOOP_VERSION}-with-hive-with-parquet.tgz \

# Redis
 && wget http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz \
 && tar -xzvf redis-${REDIS_VERSION}.tar.gz \
 && rm redis-${REDIS_VERSION}.tar.gz \
 && cd redis-${REDIS_VERSION} \
 && make install \
 && cd ~ \

# Apache Hadoop
 && wget http://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \ 
 && tar xvzf hadoop-${HADOOP_VERSION}.tar.gz \
 && rm hadoop-${HADOOP_VERSION}.tar.gz \

# Gensort (Daytona GraySort Challenge Data Generator)
 && wget http://www.ordinal.com/try.cgi/gensort-linux-${GENSORT_VERSION}.tar.gz \
 && tar xvzf gensort-linux-${GENSORT_VERSION}.tar.gz \
 && rm gensort-linux-${GENSORT_VERSION}.tar.gz 

RUN \
# Retrieve Latest Datasets, Configs, Code, and Start Scripts
 cd ~/pipeline \
 && git reset --hard && git pull \
 && chmod a+rx *.sh \

# .profile Shell Environment Variables
 && mv ~/.profile ~/.profile.orig \
 && ln -s ~/pipeline/config/bash/.profile ~/.profile \

# Sbt Assemble Standalone Feeder Apps
 && cd ~/pipeline/myapps \
 && sbt feeder/assembly \

# Sbt Package Streaming Apps
 && cd ~/pipeline/myapps \
 && sbt streaming/package \

# Sbt Package DataSource Libraries
 && cd ~/pipeline/myapps \
 && sbt datasource/package \

# Sbt Package Tungsten Apps 
 && cd ~/pipeline/myapps \
 && sbt tungsten/package 

WORKDIR /root
