from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.now(),
    'email': ['chris@fregly.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=5),
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2016, 4, 24),
}

dag = DAG('update_prediction_pmml_canary', default_args=default_args)
#, schedule_interval=timedelta(0))

# TODO:  dockerFileTag and dockerFilePath should be passed in from webhook
build_image = BashOperator(
    task_id='build_prediction-pmml_docker_image',
    bash_command='sudo docker build -t fluxcapacitor/prediction-pmml:canary /root/pipeline/prediction.ml/pmml/',
    dag=dag)

push_image = BashOperator(
    task_id='push_prediction-pmml_docker_image',
    bash_command='sudo docker push fluxcapacitor/prediction-pmml:canary',
    dag=dag)

deploy_container = BashOperator(
    task_id='deploy_prediction-pmml_docker_container_canary',
    bash_command='sudo kubectl create -f /root/pipeline/prediction.ml/pmml-canary-rc.yaml',
    dag=dag)

# Setup Airflow DAG
push_image.set_upstream(build_image)
deploy_container.set_upstream(push_image)
