echo '...Starting TensorFlow Serving for Inception Image Classification...'

nohup $TENSORFLOW_SERVING_HOME/bazel-bin/tensorflow_serving/example/inception_inference --port=9091 $DATASETS_HOME/tensorflow/serving/inception_model > $LOGS_HOME/tensorflow/serving/nohup-inception.out &

echo '...tail -f $LOGS_HOME/tensorflow/serving/nohup-inception.out...'
