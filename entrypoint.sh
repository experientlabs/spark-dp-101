#!/bin/bash

# Function to start Jupyter Notebook
start_jupyter() {
    echo "Starting Spark History Server..."
    echo "Starting Jupyter Notebook..."
    $SPARK_HOME/sbin/start-history-server.sh && jupyter notebook --ip=0.0.0.0 --port=4041 --no-browser --NotebookApp.token='' --NotebookApp.password=''
}

# Function to start Spark Shell
start_spark_shell() {
    echo "Starting Spark Shell with Delta Lake and Unity Catalog..."
    $SPARK_HOME/sbin/start-history-server.sh && \
    SPARK_SUBMIT_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5555 \
    $SPARK_HOME/bin/spark-shell --verbose
}

# Function to start PySpark Shell
start_pyspark_shell() {
    echo "Starting PySpark Shell..."
    unset PYSPARK_DRIVER_PYTHON
    unset PYSPARK_DRIVER_PYTHON_OPTS
    $SPARK_HOME/sbin/start-history-server.sh && pyspark
}

# Function to start a bash shell
start_bash() {
    echo "Launching a bash shell..."
    /bin/bash
}

# Main logic to decide which service to start
case "$1" in
    jupyter)
        start_jupyter
        ;;
    spark-shell)
        start_spark_shell
        ;;
    pyspark)
        start_pyspark_shell
        ;;
    bashed)
        start_bash
        ;;
    *)
        echo "Usage: $0 {jupyter|spark-shell|pyspark|bashed}"
        exit 1
        ;;
esac
