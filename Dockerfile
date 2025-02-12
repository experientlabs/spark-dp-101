# Use the official Python image as a base
FROM python:3.11-buster

# Set environment variables for Spark and Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
ENV SPARK_VERSION=3.5.4
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/home/spark
ENV PATH=$SPARK_HOME/bin:$PATH
ENV JAVA_VERSION=11

# Install necessary packages and dependencies
RUN apt-get update && apt-get install -y \
    "openjdk-${JAVA_VERSION}-jre-headless" \
    scala \
    curl \
    wget \
    vim \
    sudo \
    whois \
    ca-certificates-java \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN SPARK_DOWNLOAD_URL="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
    && wget --verbose -O apache-spark.tgz "${SPARK_DOWNLOAD_URL}" \
    && mkdir -p /home/spark \
    && tar -xf apache-spark.tgz -C /home/spark --strip-components=1 \
    && rm apache-spark.tgz

## Use local downloaded jar/tarball into the image if you don't want to download from the internet
#COPY downloads/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz /tmp/apache-spark.tgz
#
## Create the directory, extract the tarball, and remove the tarball
#RUN mkdir -p ${SPARK_HOME} \
#    && tar -xf /tmp/apache-spark.tgz -C ${SPARK_HOME} --strip-components=1 \
#    && rm /tmp/apache-spark.tgz

# Set up a non-root user
ARG USERNAME=sparkuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set ownership for Spark directories
RUN chown -R $USER_UID:$USER_GID ${SPARK_HOME}

# Create directories for logs and event logs
RUN mkdir -p ${SPARK_HOME}/logs \
    && mkdir -p ${SPARK_HOME}/event_logs \
    && chown -R $USER_UID:$USER_GID ${SPARK_HOME}/event_logs \
    && chown -R $USER_UID:$USER_GID ${SPARK_HOME}/logs

# Set up Spark configuration for logging and history server
RUN echo "spark.eventLog.enabled true" >> $SPARK_HOME/conf/spark-defaults.conf \
    && echo "spark.eventLog.dir file://${SPARK_HOME}/event_logs" >> $SPARK_HOME/conf/spark-defaults.conf \
    && echo "spark.history.fs.logDirectory file://${SPARK_HOME}/event_logs" >> $SPARK_HOME/conf/spark-defaults.conf

# create hive directory
RUN mkdir -p /user/hive/warehouse
RUN chmod 777 /user/hive/warehouse # TODO: limit permissions

# Copy the config files and jar files across
# TODO: jars should be downloaded
COPY hive-site.xml /home/spark/conf/
COPY spark-defaults.conf /home/spark/conf/
COPY postgresql-42.7.5.jar /home/spark/jars
RUN psql -h host.docker.internal -U postgres --no-password -c "create database hive_metastore owner postgres"

# Install Python packages for Jupyter and PySpark and scala
RUN pip install --upgrade pip
RUN pip install --no-cache-dir jupyter findspark
RUN pip install spylon-kernel
RUN python -m spylon_kernel install
RUN jupyter kernelspec list

# install delta lakes
RUN pip install delta-spark==3.2.0

# Add the entrypoint script
COPY entrypoint.sh /home/spark/entrypoint.sh
RUN chmod +x /home/spark/entrypoint.sh


#
# Switch to non-root user
#
USER $USERNAME

# Set workdir and create application directories
RUN mkdir -p /home/$USERNAME/app

WORKDIR /home/$USERNAME/app

# Expose necessary ports for Jupyter and Spark UI
EXPOSE 4040 4041 18080 8888

ENTRYPOINT ["/home/spark/entrypoint.sh"]
