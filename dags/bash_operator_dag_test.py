from airflow import DAG
from airflow.providers.ssh.operators.ssh import SSHOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 1, 1),
    'retries': 1,
}

with DAG(
    dag_id='ssh_operator_dag_test',
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
) as dag:

    # Task 1: Run a remote command via SSH
    print_python_version = SSHOperator(
        task_id='print_python_version',
        ssh_conn_id='ssh_spark_node',  # Reference the SSH connection
        command='python --version'
    )

    # Task 2: Get system info on the remote server
    get_system_info = SSHOperator(
        task_id='get_system_info',
        ssh_conn_id='ssh_spark_node',
        command='uname -a'
    )

    print_python_version >> get_system_info
