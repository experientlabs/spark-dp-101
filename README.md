# Special Thanks

## Getting Started
These instructions have only been tested on modern Mac MX processors.

1. Install Brew: https://docs.brew.sh/Installation
2. Install docker desktop for apple silicon: https://docs.docker.com/desktop/setup/install/mac-install/
3. Run the following in Terminal.app
```
docker pull postgres:latest
docker stop hive_metastore
docker rm hive_metastore
docker run --name hive_metastore -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust -d postgres

docker stop spark-container
docker rm spark-container
docker build -t spark-dp-101 .; 
hostfolder="$(pwd)";
dockerfolder="/home/sparkuser/app";
docker run --rm -d --name spark-container -p 4040:4040 -p 4041:4041 -p 18080:18080 -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/event_logs:/home/spark/event_logs spark-dp-101:latest jupyter
```
4. Spark Shell, Pyspark Shell, Jupyter Notebook http://localhost:4041, Spark UI http://localhost:4040, Spark History Server http://localhost:18080
5. Open Jupyter Notebook
6. 

### Architecture

> ![hl_architecture.png](resources/hl_architecture.png)

### How to use it:
#### 1. Clone the repository in your machine using git clone command  
   ```commandline
   git clone git@github.com:experientlabs/spark-dp-101.git
   ```
#### 2. Next build the image by running below `docker build` command.  

   ```commandline
   docker build -t spark-dp-101 .
   ```
   - Here -t is to tag image with a name:`spark-dp-101`.
   - Here '.' is to run the build command in current directory. So dockerfile should be located in current directory.   

#### 3. Once image is built you need to run following command to run the container in jupyter notebook mode. 

   ```commandline
   hostfolder="$(pwd)"
   dockerfolder="/home/sparkuser/app"
   
   docker run --rm -d --name spark-container \
   -p 4040:4040 -p 4041:4041 -p 18080:18080 \
   -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/event_logs:/home/spark/event_logs \
   spark-dp-101:latest jupyter
   ```

####  In order to run it in saprk-shell mode use below command (here last parameter is replaced with `spark-shell`). 

   ```commandline
   hostfolder="$(pwd)"
   dockerfolder="/home/sparkuser/app"
   
   docker run --rm -it --name spark-container \
   -p 4040:4040 -p 4041:4041 -p 18080:18080 \
   -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/event_logs:/home/spark/event_logs \
   spark-dp-101:latest spark-shell
   ```

####  Similarly to run pyspark shell  use below command (here last parameter is replaced with `pyspark`). 

   ```commandline
   hostfolder="$(pwd)"
   dockerfolder="/home/sparkuser/app"
   
   docker run --rm -it --name spark-container \
   -p 4040:4040 -p 4041:4041 -p 18080:18080 \
   -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/event_logs:/home/spark/event_logs \
   spark-dp-101:latest pyspark
   ```

#### Once your container is running you can use below urls to access various web UI's
1. Jupyter Notebook: http://localhost:4041
2. Spark UI: http://localhost:4040
3. Spark History Server: http://localhost:18080


Terminal window after running docker run command:

> ![terminal.png](resources/terminal.png)
> ![terminal_op.png](resources/terminal_op.png)

### Jupyter Notebook
http://127.0.0.1:4041/notebooks/first_notebook.ipynb
Running below code in jupyter notebook, in order to ascertain that spark is working fine in the container. 
```python
import findspark
findspark.init()
import pyspark
from pyspark.sql import SparkSession
import pyspark.sql.functions as f

# create spark session
spark = SparkSession.builder.appName("SparkSample").getOrCreate()

# read text file
df_text_file = spark.read.text("textfile.txt")
df_text_file.show()

df_total_words = df_text_file.withColumn('wordCount', f.size(f.split(f.col('value'), ' ')))
df_total_words.show()

# Word count example
df_word_count = df_text_file.withColumn('word', f.explode(f.split(f.col('value'), ' '))).groupBy('word').count().sort('count', ascending=False)
df_word_count.show()
```

> ![jupyter.png](resources/jupyter.png)

### Output of word count example: 

> ![jupyter_op.png](resources/jupyter_op.png)


### Spark UI:
http://localhost:4040/jobs/
> ![spark_ui.png](resources/saprk_ui.png)


### Spark History Server: 
http://localhost:18080/
> ![spark_history_server.png](resources/spark_history_server.png)


Above features can also be accessed using docker-compose commands
- docker-compose up jupyter
- docker-compose up spark-shell
- docker-compose up pyspark


This repository is brough to you by ExperientLabs, if you want to contribute, please feel free to raise a PR or if you 
come across an issue, don't hesitate to raise it. 


docker cp /home/sanjeet/Downloads/unitycatalog-0.1.0.tar.gz be3a8857e400:/home/spark/unitycatalog-0.1.0.tar.gz
tar -xf unitycatalog-0.1.0.tar.gz
