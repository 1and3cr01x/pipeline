#!/bin/bash

echo '**** MAKE SURE YOU HAVE SOURCED ~/.profile OR ELSE YOU WILL SEE MANY ERRORS RELATED TO EXECUTABLES NOT FOUND ****'
cd $PIPELINE_HOME

echo '...Starting ElasticSearch...'
nohup elasticsearch -p $ELASTICSEARCH_HOME/RUNNING_PID &

echo '...Starting Logstash...'
nohup logstash -f $LOGSTASH_HOME/logstash.conf &

echo '...Starting SSH...'
service ssh start

echo '...Starting Ganglia...'
service ganglia-monitor start
service gmetad start

echo '...Starting Apache2 Httpd...'
service apache2 start

echo '...Starting MySQL...'
service mysql start

echo '...Starting Cassandra...'
nohup cassandra

echo '...Starting ZooKeeper...'
nohup zookeeper-server-start $CONFIG_HOME/kafka/zookeeper.properties &

echo '...Starting Redis...'
nohup redis-server &

echo '...Starting Webdis...'
nohup webdis $WEBDIS_HOME/webdis.json &

echo '...Starting Kafka...'
nohup kafka-server-start $CONFIG_HOME/kafka/server.properties &

echo '...Starting Zeppelin...'
nohup $ZEPPELIN_HOME/bin/zeppelin-daemon.sh start

echo '...Starting Spark Master...'
nohup $SPARK_HOME/sbin/start-master.sh --webui-port 6060 -h 127.0.0.1

echo '...Starting Spark Worker...'
nohup $SPARK_HOME/sbin/start-slave.sh --cores 8 --memory 8g --webui-port 6061 -h 127.0.0.1 spark://127.0.0.1:7077

#echo '...Starting Spark External Shuffle Service...'
#nohup $SPARK_HOME/sbin/start-shuffle-service.sh

echo '...Starting Spark History Server...'
$SPARK_HOME/sbin/start-history-server.sh

echo '...Starting Kibana...'
nohup kibana &

echo '...Starting Jupyter Notebook Server (via pipeline-pyspark.sh)...'
nohup pipeline-pyspark.sh & 

echo '...Starting Nifi...'
nohup nifi.sh start &

echo '...Starting Airflow...'
nohup airflow webserver &

echo '...Starting Presto...'
nohup launcher start

echo '...Starting Kafka Schema Registry...'
# Starting this at the end due to race conditions with other kafka components
nohup schema-registry-start $CONFIG_HOME/schema-registry/schema-registry.properties &

echo '...Starting Kafka REST Proxy...'
nohup kafka-rest-start $CONFIG_HOME/kafka-rest/kafka-rest.properties &
