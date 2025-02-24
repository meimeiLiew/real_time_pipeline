from pyspark.sql import SparkSession

# Create Spark session with more explicit configurations
spark = SparkSession.builder \
    .appName("test") \
    .master("spark://spark-master:7077") \
    .config("spark.driver.host", "spark-master") \
    .config("spark.driver.bindAddress", "0.0.0.0") \
    .config("spark.executor.memory", "512m") \
    .config("spark.driver.memory", "512m") \
    .config("spark.python.worker.memory", "512m") \
    .config("spark.executor.cores", "1") \
    .getOrCreate()

try:
    # Create test DataFrame
    test_data = [("test1", 1), ("test2", 2)]
    df = spark.createDataFrame(test_data, ["name", "value"])
    print("DataFrame created successfully!")
    print("Schema:")
    df.printSchema()
    print("\nData:")
    df.show(truncate=False)
except Exception as e:
    print(f"Error occurred: {str(e)}")
finally:
    spark.stop() 