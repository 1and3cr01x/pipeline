#!/bin/bash

java -Djava.security.egd=file:/dev/./urandom -Dserver.port=9040 -jar $LIB_HOME/sbt-launch.jar "run-main com.advancedspark.serving.prediction.pmml.PredictionServiceMain"
