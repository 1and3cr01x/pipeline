cd $PIPELINE_HOME/myapps
echo '...Building and Packaging Streaming App...'
sbt streaming/package

echo '...Starting Spark Ratings Streaming App...'
nohup spark-submit --packages $PACKAGES --class com.fluxcapacitor.pipeline.spark.streaming.StreamingRatings $PIPELINE_HOME/myapps/streaming/target/scala-2.10/streaming_2.10-1.0.jar 2>&1 1>$PIPELINE_HOME/logs/streaming/streaming-ratings-out.log &
echo '...logs available with tail -f $PIPELINE_HOME/logs/streaming/streaming-ratings-out.log...'
cd $PIPELINE_HOME
