
Após importar o notebook em ETL Jobs → Notebooks  

Vá até o Console do Glue → Jobs → seu job → "Script parameters / Job parameters" e adicione:

1. --datalake-formats delta
2. --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension
3. --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog