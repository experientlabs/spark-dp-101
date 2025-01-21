from airflow import DAG
from airflow.providers.ssh.operators.ssh import SSHOperator
from airflow.utils.dates import days_ago

# Define default args
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
}


# Create the DAG
with DAG(
    dag_id="spark_job_via_ssh_python",
    default_args=default_args,
    description="Run a PySpark job via SSHOperator using python command",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
) as dag:


    spark_submit_template = """
    export SPARK_HOME=/home/spark;
    export PATH=$SPARK_HOME/bin:$PATH;
    echo "executing below script";
    echo "+++++++++++++++++++++++++++++++++++++++"
    echo "spark-submit /home/sparkuser/app/word_count_job.py";
    echo "+++++++++++++++++++++++++++++++++++++++";
    spark-submit /home/sparkuser/app/word_count_job.py
    """

    def generate_spark_submit_dag(**kwargs) -> str:
        return spark_submit_template.format(**kwargs)

    # SSH Operator to execute the Spark job using python
    run_spark_job = SSHOperator(
        task_id="run_spark_job",
        ssh_conn_id="ssh-spark-connection",  # Predefined SSH connection in Airflow
        command=generate_spark_submit_dag,  # Use python to execute
        cmd_timeout=3600,  # Set timeout to 1 hour or an appropriate value

    )

    run_spark_job
