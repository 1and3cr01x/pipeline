cd $PIPELINE_HOME
echo ...Building and Packaging Streaming App...
sbt streaming/package

nohup ...Starting Spark Ratings Streaming App...
spark-submit --packages org.apache.spark:spark-streaming-kafka-assembly_2.10:1.4.1,com.datastax.spark:spark-cassandra-connector-java_2.10:1.4.0-M2 --class com.bythebay.pipeline.spark.streaming.StreamingRatings $PIPELINE_HOME/streaming/target/scala-2.10/streaming_2.10-1.0.jar 2>&1 1>streaming-ratings-out.log &
echo    logs available with 'tail -f streaming-ratings-out.log'
