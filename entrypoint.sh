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
    $SPARK_HOME/bin/spark-shell \
    --jars /home/spark/jars/unitycatalog-spark.jar \
    --packages io.delta:delta-spark_2.13:3.2.0,io.unitycatalog:unitycatalog-spark \
    --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension \
    --conf spark.sql.catalog.spark_catalog=io.unitycatalog.connectors.spark.UCSingleCatalog \
    --conf spark.sql.catalog.spark_catalog.uri=http://localhost:8080 \
    --conf spark.sql.catalog.unity=io.unitycatalog.connectors.spark.UCSingleCatalog \
    --conf spark.sql.catalog.unity.uri=http://localhost:8080
}

# Function to start PySpark Shell
start_pyspark_shell() {
    echo "Starting PySpark Shell..."
    unset PYSPARK_DRIVER_PYTHON
    unset PYSPARK_DRIVER_PYTHON_OPTS
    $SPARK_HOME/sbin/start-history-server.sh && pyspark
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
