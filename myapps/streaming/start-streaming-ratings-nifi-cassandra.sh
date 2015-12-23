echo '...Building and Packaging Streaming App...'
sbt package

echo '...Starting Spark Streaming App:  Store Raw Ratings from Nifi into Cassandra...'
nohup spark-submit --jars $SPARK_SUBMIT_JARS --packages $SPARK_SUBMIT_PACKAGES --class com.advancedspark.streaming.rating.store.NifiCassandra $PIPELINE_HOME/myapps/streaming/target/scala-2.10/streaming_2.10-1.0.jar 2>&1 1>$PIPELINE_HOME/logs/streaming/ratings-nifi-cassandra.log &
echo '...logs available with "tail -f $PIPELINE_HOME/logs/streaming/ratings-nifi-cassandra.log"'
