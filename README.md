# spark-dp-101
One node spark setup in a docker container.


Docker build command:

```commandline
docker build -t spark-dp-101 .
```


Docker run command:

```commandline
hostfolder="$(pwd)"
dockerfolder="/home/sparkuser/app"
spark_home="/home/spark"
docker run -d --name spark-container-101 -p 4040:4040 -p 4041:4041 -p 18080:18080 -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/event_logs:${spark_home}/event_logs spark-dp-101:latest
```


1. Give 777 to the app/ directory so that docker container can write into it - Not best practice
2. chown 1000:1000 "${hostfolder}/app"


docker run -d --name spark-container-101 -p 4040:4040 -p 4041:4041 -p 18080:18080 -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/event_logs:${spark_home}/event_logs spark-dp-101:latest jupyter

docker run --rm -it --name spark-container-101 -p 4040:4040 -p 4041:4041 -p 18080:18080 -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/event_logs:${spark_home}/event_logs spark-dp-101:latest spark-shell