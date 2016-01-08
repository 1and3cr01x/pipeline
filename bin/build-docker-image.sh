# This is a convenience script to build the Docker image 

# cd to where the Dockerfile lives
# We're assuming this is ~/pipeline, but this might not be the case
cd ~/pipeline

echo "... *** MAKE SURE YOU ARE IN THE SAME DIRECTORY AS THE Dockerfile OR ELSE YOU WILL SEE AN ERROR *** ..."

docker build  -t fluxcapacitor/pipeline . 

# These build args only work in Docker 1.9+.
# We're still on Docker 1.7 for stability and debuggability purposes.
# (1.7 is a known entity at this point.)
#  --build-arg SCALA_VERSION=2.10.4 \
#  --build-arg SPARK_VERSION=1.6.0 \
#  --build.arg CASSANDRA_VERSION=2.2.4 \
#  --build-arg CONFLUENT_VERSION=1.0.1 \
#  --build-arg ELASTICSEARCH_VERSION=1.7.3 \
#  --build-arg LOGSTASH_VERSION=2.0.0 \
#  --build-arg KIBANA_VERSION=4.1.2 \
#  --build-arg NEO4J_VERSION=2.2.3 \
#  --build-arg REDIS_VERSION=3.0.5 \
#  --build-arg SBT_VERSION=0.13.9 \
#  --build-arg SPARK_NOTEBOOK_VERSION=0.6.1 \
#  --build-arg TACHYON_VERSION=0.7.1 \
#  --build-arg GENSORT_VERSION=1.5 \
#  --build-arg HADOOP_VERSION=2.6.0 \
