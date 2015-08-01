#!/bin/bash

. ./flux-setenv.sh

echo Starting ElasticSearch
nohup elasticsearch -p $ELASTICSEARCH_HOME/RUNNING_PID &

echo Starting Logstash
nohup logstash agent -f $PIPELINE_HOME/config/logstash/logstash.conf &

echo Starting SSH
service ssh start

echo Ganglia
service ganglia-monitor start 
service gmetad start

echo Starting Apache2 Httpd
service apache2 start

echo Starting MySQL
service mysql start

echo Starting Cassandra
nohup cassandra

echo Starting ZooKeeper
nohup zookeeper-server-start $PIPELINE_HOME/config/kafka/zookeeper.properties &

echo Starting Kafka
nohup kafka-server-start $PIPELINE_HOME/config/kafka/server.properties &

echo Starting Apache Zeppelin
nohup $ZEPPELIN_HOME/bin/zeppelin-daemon.sh start

echo Starting Apache Spark Master
nohup $SPARK_HOME/sbin/start-master.sh --webui-port 6060 -i 127.0.0.1 -h 127.0.0.1 

echo Starting Apache Spark Worker
nohup $SPARK_HOME/sbin/start-slave.sh --webui-port 6061 spark://127.0.0.1:7077 

# Spark ThriftServer
## MySql must be started - and the password set - before ThriftServer will startup
## Starting the ThriftServer will create a dummy derby.log and metastore_db per https://github.com/apache/spark/pull/6314
## The actual Hive metastore defined in conf/hive-site.xml is still used, however.
echo Starting Apache Spark JDBC/ODBC Hive ThriftServer
nohup $SPARK_HOME/sbin/start-thriftserver.sh --master spark://127.0.0.1:7077

echo Starting Tachyon
nohup tachyon format
nohup $TACHYON_HOME/bin/tachyon-start.sh local   

echo Starting Spark-Notebook
nohup spark-notebook -Dconfig.file=$PIPELINE_HOME/config/spark-notebook/application-pipeline.conf &

echo Starting Kibana
nohup kibana &

# Starting this at the end due to race conditions with other kafka components
echo Starting Kafka Schema Registry
nohup schema-registry-start $PIPELINE_HOME/config/schema-registry/schema-registry.properties &

echo Starting Kafka REST Proxy
nohup kafka-rest-start $PIPELINE_HOME/config/kafka-rest/kafka-rest.properties &
