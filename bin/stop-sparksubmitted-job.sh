echo '...Stopping Spark-Submitted Job...'
jps | grep "SparkSubmit" | cut -d " " -f "1" | xargs kill -KILL
