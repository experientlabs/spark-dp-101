from pyspark.sql import SparkSession
import random

def main():
    # Initialize Spark session
    spark = SparkSession.builder \
        .appName("SimpleSparkJob") \
        .getOrCreate()

    # Generate some random data
    data1 = [(i, f"name_{i}") for i in range(1, 6)]
    data2 = [(i, random.randint(100, 200)) for i in range(3, 8)]

    # Create DataFrames
    df1 = spark.createDataFrame(data1, schema=["id", "name"])
    df2 = spark.createDataFrame(data2, schema=["id", "value"])

    # Perform a join
    joined_df = df1.join(df2, on="id", how="inner")

    # Show results
    joined_df.show()

    # Stop Spark session
    spark.stop()

if __name__ == "__main__":
    main()
