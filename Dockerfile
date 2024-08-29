FROM python:3.11-buster

# Set environment variables
ENV SPARK_VERSION=3.5.2
ENV HADOOP_VERSION=3
ENV JAVA_VERSION=11
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV SPARK_HOME=/home/spark
ENV PATH=$PATH:$SPARK_HOME

RUN apt-get update && apt-get install -y \
    "openjdk-${JAVA_VERSION}-jre-headless" \
    vim \
    wget \
    sudo \
    ca-certificates-java \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#RUN SPARK_DOWNLOAD_URL="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
#    && wget --verbose -O apache-spark.tgz "${SPARK_DOWNLOAD_URL}" \
#    && mkdir -p /home/spark \
#    && tar -xf apache-spark.tgz -C /home/spark --strip-components=1 \
#    && rm apache-spark.tgz

# Use local downloaded jar/tarball into the image if you don't want to download from the internet
COPY downloads/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz /tmp/apache-spark.tgz

# Create the directory, extract the tarball, and remove the tarball
RUN mkdir -p ${SPARK_HOME} \
    && tar -xf /tmp/apache-spark.tgz -C ${SPARK_HOME} --strip-components=1 \
    && rm /tmp/apache-spark.tgz

ENV PIPENV_VENV_IN_PROJECT=1
ENV PYSPARK_PYTHON=/usr/local/bin/python3
ENV PYSPARK_DRIVER_PYTHON='jupyter'
ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook --no-browser --port=4041'

# Set up a non root user
ARG USERNAME=sparkuser
ARG USER_ID=1000
ARG USER_GROUP_ID=1000

RUN groupadd --gid $USER_GROUP_ID $USERNAME \
    && useradd --uid $USER_ID --gid $USER_GROUP_ID -m -s /bin/bash $USERNAME \
    && chown $USER_ID:$USER_GROUP_ID /home/$USERNAME \
    && echo "$USERNAME ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN chown -R $USER_ID:$USER_GROUP_ID ${SPARK_HOME}

RUN mkdir -p ${SPARK_HOME}/logs \
    && mkdir -p ${SPARK_HOME}/event_logs \
    && chown -R $USER_ID:$USER_GROUP_ID ${SPARK_HOME}/event_logs \
    && chown -R $USER_ID:$USER_GROUP_ID ${SPARK_HOME}/logs


# Set up Spark configuration for logging and history server
RUN echo "spark.eventLog.enabled true" >> $SPARK_HOME/conf/spark-defaults.conf \
    && echo "spark.eventLog.dir file://${SPARK_HOME}/event_logs" >> $SPARK_HOME/conf/spark-defaults.conf \
    && echo "spark.history.fs.logDirectory file://${SPARK_HOME}/event_logs" >> $SPARK_HOME/conf/spark-defaults.conf

RUN pip install --no-cache-dir jupyter findspark

COPY entrypoint.sh /home/spark/entrypoint.sh
RUN chmod +x /home/spark/entrypoint.sh

USER $USERNAME

RUN mkdir -p /home/$USERNAME/app
WORKDIR /home/$USERNAME/app

EXPOSE 4040 4041 18080 8888


ENTRYPOINT ["/home/spark/entrypoint.sh"]
