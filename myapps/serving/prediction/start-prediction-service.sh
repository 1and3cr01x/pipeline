echo '...Starting Prediction Service...'
echo ''
echo '...This will take a minute or two...'
echo ''
echo '...***************************...'
echo '...*** IGNORE ALL ERRORS!! ***...'
echo '...***************************...'
java -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE -Djava.security.egd=file:/dev/./urandom -jar ~/sbt/bin/sbt-launch.jar "run-main com.advancedspark.serving.prediction.PredictionServiceMain"
