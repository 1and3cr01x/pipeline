#!/bin/bash

# Args
#   $1: tensorflow
#   $2: mnist
#   $3: tag

pipeline model-predict --model-type=http/POST/localhost/6969/$1 --model-name=$2 --model-tag=$3 --model-server_url=http://predict-$1-$2-$3-gcp.community.pipeline.ai --model-test-request-path=./models/$1/$2/data/test_request.json --model-test-request-concurrency=1000
