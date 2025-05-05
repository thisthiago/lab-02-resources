Donwloado do jar, e subir no s3
https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.3.0/delta-core_2.12-2.3.0.jar

Após importar o notebook em ETL Jobs → Notebooks  

Vá até o Console do Glue → Jobs → seu job → "Script parameters / Job parameters" e adicione:

1. --datalake-formats delta
2. --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension
3. --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog

: TODO
Notebbok delta lake
Nootebbok spark streaming