# PipelineAI APIs
## Command Line Interface (CLI)
### Installation
```
pip install --upgrade --ignore-installed pio-cli
```

You can view the commands supported by the CLI using just `pio`.
```
pio
```

## Deploy ML/AI Models
### Supported Model Types
* Scikit-Learn
* R
* Spark ML
* TensorFlow
* XGBoost
* Python3
* Java
* PMML
* Ensembles

### Initialize Model 
```
pio init-model --model-server-url <model_server_url> \
               --model-type <model_type> \
               --model-namespace <model_namespace> \
               --model_name <model_name> \
               --model-version <model_version> \
               --model-path /path/to/model \
               --model-test-input-path /path/to/test/inputs
```

### Deploy Model 
```
pio deploy
```

### Predict Model
```
pio predict
```

### Examples
```
git clone https://github.com/fluxcapacitor/source.ml
```

**TensorFlow**

model_type: `tensorflow`

Start Model Server
```
pio start prediction-tensorflow
```

Initialize Model
```
pio init-model --model-server-url http://your.model.server.com \
               --model-type tensorflow \
               --model-namespace default \
               --model-name tensorflow_linear \
               --model-version 0 \
               --model-path ./source.ml/prediction.ml/model_store/tensorflow/default/tensorflow_linear/0 \
               --model-test-input-path ./source.ml/prediction.ml/model_store/tensorflow/default/tensorflow_linear/0/test_inputs.txt
```

Deploy Model
```
pio deploy
```
Predict Model
```
pio predict
```

**Scikit-Learn**

model_type: `scikit`

Start Model Server
```
pio start prediction-scikit
```

Initialize Model
```
pio init-model --model-server-url http://your.model.server.com \
               --model-type scikit \
               --model-namespace default \
               --model-name scikit_linear \
               --model-version v0 \
               --model-path ./source.ml/prediction.ml/model_store/scikit/default/scikit_linear/v0 \
               --model-test-input-path ./source.ml/prediction.ml/model_store/scikit/default/scikit_linear/v0/test_inputs.txt
```

Deploy Model
```
pio deploy
```

Predict Model
```
pio predict
```

**Spark ML**

model_type: `spark`


Start Model Server
```
pio start prediction-spark
```

Initialize Model
```
pio init-model --model-server-url http://your.model.server.com \
               --model-type spark \
               --model-namespace default \
               --model-name spark_airbnb 
               --model-version v0 \
               --model-path ./source.ml/prediction.ml/model_store/spark/default/spark_airbnb/v0 \
               --model-test-input-path ./source.ml/prediction.ml/model_store/spark/default/spark_airbnb/v0/test_inputs.txt
```

Deploy Model
```
pio deploy
```

Predict Model
```
pio predict
```


**Python3**

model_type: `python3`


Start Model Server
```
pio start prediction-python3
```

Initialize Model
```
pio init-model --model-server-url http://your.model.server.com \
               --model-type python3 \
               --model-namespace default \
               --model-name python3_zscore \
               --model-version v0 \
               --model-path ./source.ml/prediction.ml/model_store/python3/default/python3_zscore/v0 \
               --model-test-input-path ./source.ml/prediction.ml/model_store/python3/default/python3_zscore/v0/test_inputs.txt
```

Deploy Model
```
pio deploy
```

Predict Model
```
pio predict
```

**PMML**

model_type: `pmml`


Start Model Server
```
pio start prediction-pmml
```

Initialize Model
```
pio init-model --model-server-url http://your.model.server.com \
               --model-type pmml \
               --model-namespace default \
               --model-name pmml_airbnb \
               --model-version v0 \
               --model-path ./source.ml/prediction.ml/model_store/pmml/default/pmml_airbnb/v0 \
               --model-test-input-path ./source.ml/prediction.ml/model_store/pmml/default/pmml_airbnb/v0/test_inputs.txt
```

Deploy Model
```
pio deploy
```

Predict Model
```
pio predict
```

## REST API

### Deploy AI/ML Models
**Deploy**
```
import requests

deploy_url = 'http://<pipelineio-model-server>/api/v1/model/deploy/spark/default/airbnb/v0'

files = {'file': open('airbnb.model', 'rb')}

response = requests.post(deploy_url, files=files)

print("Success!\n\n%s" % response.text)
```

**Predict**
```
import json

data = {"bathrooms":2.0, 
        "bedrooms":2.0, 
        "security_deposit":175.00, 
        "cleaning_fee":25.0, 
        "extra_people":1.0, 
        "number_of_reviews": 2.0, 
        "square_feet": 250.0, 
        "review_scores_rating": 2.0, 
        "room_type": "Entire home/apt", 
        "host_is_super_host": "0.0", 
        "cancellation_policy": "flexible", 
        "instant_bookable": "1.0", 
        "state": "CA" }

json_data = json.dumps(data)

with open('test_inputs.json', 'wt') as fh:
    fh.write(json_data)
```
```
predict_url = 'http://<pipelineio-model-server>/api/v1/model/predict/spark/default/airbnb/v0'

headers = {'content-type': 'application/json'}

response = requests.post(predict_url, 
                         data=json_data, 
                         headers=headers)

print("Response:\n\n%s" % response.text)
```

{!contributing.md!}
