from pyspark.sql import SparkSession
from pyspark.sql import functions as f
import findspark
findspark.init()

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("WordCountExample") \
    .getOrCreate()

# Read text file
df_text_file = spark.read.text("/home/sparkuser/app/textfile.txt")  # Ensure textfile.txt is accessible
df_text_file.show()
df_text_file.show(truncate=False)

# Calculate total words in each line
df_total_words = df_text_file.withColumn('wordCount', f.size(f.split(f.col('value'), ' ')))
df_total_words.show()

# Word count example
df_word_count = df_text_file.withColumn('word', f.explode(f.split(f.col('value'), ' '))) \
    .groupBy('word').count().sort('count', ascending=False)
df_word_count.show()

# Stop SparkSession
spark.stop()
