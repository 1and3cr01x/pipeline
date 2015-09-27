#!/bin/bash

echo '...Stopping Kafka...'
kafka-server-stop 

echo '...Stopping Schema Registry...'
schema-registry-stop 

echo '...Stopping Kafka REST Proxy...'
kafka-rest-stop 

echo '...Stopping Zeppelin...'
$ZEPPELIN_HOME/bin/zeppelin-daemon.sh stop 

echo '...Stopping Spark Master...'
$SPARK_HOME/sbin/stop-master.sh --webui-port 6060 

echo '...Stopping Spark Worker...'
$SPARK_HOME/sbin/stop-slave.sh --webui-port 6061

echo '...Stopping Long-Running Spark JDBC ODBC Hive ThriftServer...'
$SPARK_HOME/sbin/stop-thriftserver.sh  

echo '...Stopping Redis...'
redis-cli shutdown

echo '...Stopping Tachyon...'
$TACHYON_HOME/bin/tachyon-stop.sh 

echo '...Stopping ZooKeeper...'
zookeeper-server-stop 

echo '...Stopping Spark-Notebook...'
screen -X -S "snb" quit && rm -rf $DEV_INSTALL_HOME/spark-notebook-0.6.0-scala-2.10.4-spark-1.4.1-hadoop-2.6.0-with-hive-with-parquet/RUNNING_PID

echo '...Stopping Cassandra...'
pkill -f CassandraDaemon

echo '...Stopping Apache2 Httpd...'
service apache2 stop

echo '...Stopping Ganglia...'
service gmetad stop
service ganglia-monitor stop

echo '...Stopping MySQL...'
service mysql stop

echo '...Stopping Kibana...'
jps | grep "Main" | cut -d " " -f "1" | xargs kill -KILL
ps -aef | grep "kibana" | tr -s ' ' | cut -d ' ' -f2 | xargs kill -KILL

echo '...Stopping Logstash...'
ps -aef | grep "logstash" | tr -s ' ' | cut -d ' ' -f2 | xargs kill -KILL

echo '...Stopping ElasticSearch...'
jps | grep "Elasticsearch" | cut -d " " -f "1" | xargs kill -KILL

echo '...Stopping Long-Running Ratings Spark Streaming Job...'
./flux-stop-sparksubmitted-job.sh

echo '...Stopping Long-Running Partitioned Ratings Spark Streaming Job...'
./flux-stop-sparksubmitted-job.sh

echo '...Stopping Long-Running Likes Spark Streaming Job...'
./flux-stop-sparksubmitted-job.sh

echo '...Stopping Long-Running Spark Job Server Job...'
./flux-stop-sparksubmitted-job.sh

echo '...Stopping Kafka Ratings Feeder...'
jps | grep "sbt-launch.jar" | cut -d " " -f "1" | xargs kill -KILL

#echo '...Stopping H2O...'
#jps | grep "h2o" | cut -d " " -f "1" | xargs kill -KILL

#echo '...TODO Stopping Jupyter Notebook...'

echo '...Stopping SSH...'
service ssh stop

echo '...IGNORE ANY ERRORS ON SHUTDOWN ABOVE AS THESE ARE OK...'
