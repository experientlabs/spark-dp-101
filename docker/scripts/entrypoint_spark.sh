#!/bin/bash

# Start SSH service in the background
echo "Starting SSH service..."
service ssh start &

# Function to start Jupyter Notebook
start_jupyter() {
    echo "Starting Spark History Server..."
    $SPARK_HOME/sbin/start-history-server.sh &
    echo "Starting Jupyter Notebook..."
    jupyter notebook --ip=0.0.0.0 --port=4041 --no-browser --NotebookApp.token='' --NotebookApp.password='' --allow-root
}

# Function to start Spark Shell
start_spark_shell() {
    echo "Starting Spark Shell..."
    $SPARK_HOME/sbin/start-history-server.sh &
    spark-shell
}

# Function to start PySpark Shell
start_pyspark_shell() {
    echo "Starting PySpark Shell..."
    unset PYSPARK_DRIVER_PYTHON
    unset PYSPARK_DRIVER_PYTHON_OPTS
    $SPARK_HOME/sbin/start-history-server.sh &
    pyspark
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
    *)
        echo "Usage: $0 {jupyter|spark-shell|pyspark}"
        exit 1
        ;;
esac
# Keep the container running
tail -f /dev/null