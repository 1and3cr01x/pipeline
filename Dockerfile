FROM ubuntu:14.04

# Notes:
#   The contents ond tools installed in this Dockerfile have only been tested on Ubuntu 14.04.
#   Use at your own risk if you are trying to apply these instructions to a different environment.
#   We've done our best to highlight (Optional) installs - usually around system-level performance monitoring tools like "perf" from the linux-tools package.
#   Feel free to leave out these installs, but you may lose compatibility with future releases of this distribution.
#   It's highly-advised that you run this distributed of Docker/Ubuntu on whatever host system you are running (ie. RHEL, CentOS, etc)

# These are environment variables that match the versions of the sofware tools installed by this Dockerfile.
# We also need to include library dependency versions as we trigger a build of all Scala/Java-based source code 
#  at the end in order to pre-bake the dependencies into the Docker image.  This saves time and network bandwidth later.
#
ENV \ 
 CASSANDRA_VERSION=2.2.5 \
 CONFLUENT_VERSION=1.0.1 \
 ELASTICSEARCH_VERSION=2.3.0 \
 LOGSTASH_VERSION=2.3.0 \
 KIBANA_VERSION=4.5.0 \
 REDIS_VERSION=3.0.5 \
 SBT_VERSION=0.13.9 \
 HADOOP_VERSION=2.6.0 \
 HIVE_VERSION=1.2.1 \
 ZEPPELIN_VERSION=0.6.0 \
 GENSORT_VERSION=1.5 \
 SCALA_VERSION=2.10.4 \
 SPARK_VERSION=1.6.1 \
 STANFORD_CORENLP_VERSION=3.6.0 \
 STREAMING_MATRIX_FACTORIZATION_VERSION=0.1.0 \
 NIFI_VERSION=0.4.1 \
 PRESTO_VERSION=0.137 \
 TITAN_VERSION=1.0.0-hadoop1 \
 AKKA_VERSION=2.3.11 \
 SPARK_CASSANDRA_CONNECTOR_VERSION=1.4.0 \
 SPARK_ELASTICSEARCH_CONNECTOR_VERSION=2.1.2 \
 KAFKA_CLIENT_VERSION=0.8.2.2 \
 SCALATEST_VERSION=2.2.4 \
 JEDIS_VERSION=2.7.3 \
 SPARK_CSV_CONNECTOR_VERSION=1.4.0 \
 SPARK_AVRO_CONNECTOR_VERSION=2.0.1 \
 ALGEBIRD_VERSION=0.11.0 \
 STREAMING_MATRIX_FACTORIZATION_VERSION=0.1.0 \
 SBT_ASSEMBLY_PLUGIN_VERSION=0.14.0 \
 SBT_SPARK_PACKAGES_PLUGIN_VERSION=0.2.3 \
 SPARK_NIFI_CONNECTOR_VERSION=0.4.1 \
 SPARK_XML_VERSION=0.3.1 \
 JBLAS_VERSION=1.2.4 \
 GRAPHFRAMES_VERSION=0.1.0-spark1.6 \
 FLINK_VERSION=1.0.0 \
 TENSORFLOW_VERSION=0.7.1-cp27-none

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
 && apt-get install -y git \
 && apt-get install -y openssh-server \
 && apt-get install -y apache2 \

# iPython/Jupyter
 && apt-get install -y python-dev \
 && apt-get install -y python-pip \
 && pip install jupyter \
 && pip install ipyparallel \

# TensorFlow (CPU-only)
 && pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-${TENSORFLOW_VERSION}-linux_x86_64.whl \

# TensorFlow GPU-enabled
# && pip install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${TENSORFLOW_VERSION}-linux_x86_64.whl \

# Required by Webdis Redis REST Server
 && apt-get install -y libevent-dev \

# Python Data Science Libraries
# && pip install --upgrade gensim \
 && apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran \
 && apt-get install -y python-pandas-lib \
 && apt-get install -y python-numpy \
 && apt-get install -y python-scipy \
 && apt-get install -y python-pandas \
 && apt-get install -y libgfortran3 \
 && apt-get install -y python-matplotlib \
 && apt-get install -y python-nltk \
 && apt-get install -y python-sklearn \
 && pip install --upgrade skflow \
 && pip install ggplot \
 && pip install networkx \
 && apt-get install -y pkg-config \
 && apt-get install -y libgraphviz-dev \
# && pip install --upgrade -r requirements.txt \

# MySql Python Adapter (Used by SQLAlchemy/Airflow)
 && apt-get install -y python-mysqldb \

# Maven for custom builds (ie. Livy)
 && apt-get install -y maven \

# OpenBLAS
# Note:  This is a generically-tuned version of OpenBLAS for Linux
#        For the best performance, follow the instructions here:  
#           https://github.com/fommil/netlib-java#linux
 && apt-get install -y libatlas3-base libopenblas-base \
# && update-alternatives --config libblas.so \
# && update-alternatives --config libblas.so.3 \
# && update-alternatives --config liblapack.so \
# && update-alternatives --config liblapack.so.3 \

# R
 && echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list \
 && gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 \
 && gpg -a --export E084DAB9 | sudo apt-key add - \
 && apt-get update \
 && apt-get install -y r-base \
 && apt-get install -y r-base-dev \

# libcurl (required to install.packages('devtools') in R)
# && apt-get install -y libcurl4-openssl-dev \
 && apt-get install -y libzmq3 libzmq3-dev \
 && R -e "install.packages(c('rzmq','repr','IRkernel','IRdisplay'), type = 'source', repos = c('http://cran.us.r-project.org', 'http://irkernel.github.io/'))" \
 && R -e "IRkernel::installspec(user = FALSE)" \

# Ganglia
 && DEBIAN_FRONTEND=noninteractive apt-get install -y ganglia-monitor rrdtool gmetad ganglia-webfrontend \

# MySql (Required by Hive Metastore)
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server \
 && apt-get install -y mysql-client \
 && apt-get install -y libmysql-java 

RUN \
# Get Latest Pipeline Code
 cd ~ \
 && git clone https://github.com/fluxcapacitor/pipeline.git

RUN \
# Source the pipeline-specific env variables
# This is needed to re-attach to a Docker container after exiting
 cd ~ \
 && echo "" >> ~/.bashrc \
 && echo "# Pipeline-specific" >> ~/.bashrc \
 && echo "if [ -f ~/pipeline/config/bash/pipeline.bashrc ]; then" >> ~/.bashrc \
 && echo "   . ~/pipeline/config/bash/pipeline.bashrc" >> ~/.bashrc \
 && echo "fi" >> ~/.bashrc 

RUN \
# Sbt
 cd ~ \
 && wget https://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.tgz \
 && tar xvzf sbt-${SBT_VERSION}.tgz \
 && rm sbt-${SBT_VERSION}.tgz \
 && ln -s /root/sbt/bin/sbt /usr/local/bin \
# Sbt Clean - This seems weird, but it triggers the full Sbt install which involves a lot of external downloads
 && sbt clean clean-files \

# ElasticSearch
 && cd ~ \
 && wget http://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
 && tar xvzf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
 && rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \

# Elastic Graph
 && cd ~ \
 && elasticsearch-${ELASTICSEARCH_VERSION}/bin/plugin install license \
 && elasticsearch-${ELASTICSEARCH_VERSION}/bin/plugin install graph \

# Logstash
 && cd ~ \
 && wget https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz \
 && tar xvzf logstash-${LOGSTASH_VERSION}.tar.gz \
 && rm logstash-${LOGSTASH_VERSION}.tar.gz \

# Kibana
 && cd ~ \
 && wget http://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz \
 && tar xvzf kibana-${KIBANA_VERSION}-linux-x64.tar.gz \
 && rm kibana-${KIBANA_VERSION}-linux-x64.tar.gz \

# Kibana Plugins
 && cd ~ \
 && kibana-${KIBANA_VERSION}-linux-x64/bin/kibana plugin --install elasticsearch/graph/latest \
 && kibana-${KIBANA_VERSION}-linux-x64/bin/kibana plugin --install elastic/sense \
 && kibana-${KIBANA_VERSION}-linux-x64/bin/kibana plugin --install kibana/timelion \
 && kibana-${KIBANA_VERSION}-linux-x64/bin/kibana plugin --install tagcloud -u https://github.com/stormpython/tagcloud/archive/master.zip \
 && kibana-${KIBANA_VERSION}-linux-x64/bin/kibana plugin --install heatmap -u https://github.com/stormpython/heatmap/archive/master.zip \
 && kibana-${KIBANA_VERSION}-linux-x64/bin/kibana plugin --install vectormap -u https://github.com/stormpython/vectormap/archive/master.zip \

# Apache Cassandra
 && cd ~ \
 && wget http://www.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
 && tar xvzf apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
 && rm apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \

# Apache Kafka (Confluent Distribution)
 && cd ~ \
 && wget http://packages.confluent.io/archive/1.0/confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \
 && tar xvzf confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \
 && rm confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \

# Apache Spark
 && cd ~ \
 && wget https://s3.amazonaws.com/fluxcapacitor.com/packages/spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \
 && tar xvzf spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \
 && rm spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \

# Livy Spark REST Server
 && cd ~ \
 && git clone https://github.com/cloudera/livy.git \ 
 && cd livy \
 && mvn -DskipTests -Dspark.version=${SPARK_VERSION} clean package \

# Apache Zeppelin
 && cd ~ \
 && wget https://s3.amazonaws.com/fluxcapacitor.com/packages/zeppelin-${ZEPPELIN_VERSION}-fluxcapacitor.tar.gz \
 && tar xvzf zeppelin-${ZEPPELIN_VERSION}-fluxcapacitor.tar.gz \
 && rm zeppelin-${ZEPPELIN_VERSION}-fluxcapacitor.tar.gz \

# Redis
 && cd ~ \
 && wget http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz \
 && tar -xzvf redis-${REDIS_VERSION}.tar.gz \
 && rm redis-${REDIS_VERSION}.tar.gz \
 && cd redis-${REDIS_VERSION} \
 && make install \
 && cd ~ \

# Webdis Redis REST Server
 && cd ~ \
 && git clone https://github.com/nicolasff/webdis.git \
 && cd webdis \
 && make \

# Apache Hadoop
 && cd ~ \
 && wget http://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \ 
 && tar xvzf hadoop-${HADOOP_VERSION}.tar.gz \
 && rm hadoop-${HADOOP_VERSION}.tar.gz \

# Apache Hive
 && cd ~ \
 && wget http://www.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
 && tar xvzf apache-hive-${HIVE_VERSION}-bin.tar.gz \
 && rm apache-hive-${HIVE_VERSION}-bin.tar.gz \

# Apache NiFi
 && cd ~ \
 && wget https://archive.apache.org/dist/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.tar.gz \
 && tar xvzf nifi-${NIFI_VERSION}-bin.tar.gz \
 && rm nifi-${NIFI_VERSION}-bin.tar.gz \

# Flink
 && wget http://archive.apache.org/dist/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-hadoop26-scala_2.10.tgz \
 && tar xvzf flink-${FLINK_VERSION}-bin-hadoop26-scala_2.10.tgz \
 && rm flink-${FLINK_VERSION}-bin-hadoop26-scala_2.10.tgz \

# Airflow
 && cd ~ \
 && pip install --upgrade airflow \

# Presto
 && cd ~ \
 && wget https://repo1.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz \
 && tar xvzf presto-server-${PRESTO_VERSION}.tar.gz \
 && rm presto-server-${PRESTO_VERSION}.tar.gz \ 
 && cd presto-server-${PRESTO_VERSION}/bin \
 && wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar \
 && mv presto-cli-${PRESTO_VERSION}-executable.jar presto \
 && chmod a+x presto \

# Titan DB
 && cd ~ \
 && wget http://s3.thinkaurelius.com/downloads/titan/titan-${TITAN_VERSION}.zip \
 && unzip titan-${TITAN_VERSION}.zip \
 && rm titan-${TITAN_VERSION}.zip 
 
RUN \
# Get Latest Pipeline Code 
 cd ~/pipeline \
 && git pull 

RUN \
# Sbt Feeder
 cd ~/pipeline/myapps/akka/feeder && sbt assembly 

RUN \
# Sbt ML 
# This is temporary while we figure out how to specify the following dependency as a --package into Spark (note `models` classifier)
#   edu.stanford.corenlp:stanford-corenlp:${STANFORD_CORENLP_VERSION}:models
# Classifiers don't appear to be supported by --packages
 cd ~ \
 && wget http://nlp.stanford.edu/software/stanford-corenlp-full-2015-12-09.zip \
 && unzip stanford-corenlp-full-2015-12-09.zip \
 && rm stanford-corenlp-full-2015-12-09.zip \
 && cd ~/pipeline/myapps/spark/ml \
 && cp ~/stanford-corenlp-full-2015-12-09/stanford-corenlp-${STANFORD_CORENLP_VERSION}-models.jar lib/ \
 && sbt package \

# Sbt Streaming
 && cd ~/pipeline/myapps/spark/streaming && sbt package \

# Sbt SQL 
 && cd ~/pipeline/myapps/spark/sql && sbt package \

# Sbt core
 && cd ~/pipeline/myapps/spark/core && sbt package \

# Sbt Flink CEP Streaming  
 && cd ~/pipeline/myapps/flink/streaming && sbt assembly 

# Ports to expose 
EXPOSE 80 6042 9160 9042 9200 7077 38080 38081 6060 6061 6062 6063 6064 6065 8090 10000 50070 50090 9092 6066 9000 19999 6081 7474 8787 5601 8989 7979 4040 4041 4042 4043 4044 4045 4046 4047 4048 4049 4050 4051 4052 4053 4054 4055 4056 4057 4058 4059 4060 6379 8888 54321 8099 8754 7379 6969 6970 6971 6972 6973 6974 6975 6976 6977 6978 6979 6980 5050 5060 7060 8182 9081 8998

WORKDIR /root
