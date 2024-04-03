# GCP_Cloud_SQL
## SETUP:

1. Download that github repo as a .zip & activate Cloud Shell & upload it into Cloud Shell persistant disk.
2. Unzip it & choose that directory:
```
unzip GCP_Cloud_SQL-main.zip
cd GCP_Cloud_SQL-main/
```
4. Check file init_setting.sh, change an examplary password and other variables if needed.
5. Execute file :
```
sh init_setting.sh
```
You will be asked: 'Do you want to continue?' -> press 'y'
If asked for the password type it in.


## FEDERATED QUERIES:
1. Check file federated_queries.sh whether some variables need to changed & execute it
```
sh federal_queries.sh
```
2. Now you can query data from Cloud SQL using queries like:
```
SELECT
  *
FROM
  EXTERNAL_QUERY("{PROJECT_ID}.{LOCATION}.{CONNECTION_ID}",
    "SELECT * FROM {TABLE} ;");
```
example:
```
SELECT
  *
FROM
  EXTERNAL_QUERY("my_proj.eu.names_connection_id",
    "SELECT * FROM names ;");
```


## LOAD TO CLOUD STORAGE & TO BIG QUERY:
1. Check file to_cloudstorage_to_bq.sh whether some variables need to changed & execute it (bucket name needs to be changed for sure, since it needs to be unique globally)
```
sh to_cloudstorage_to_bq.sh
```
2. Now you have data in Cloud Storage as well as you can query data that was loaded into Big Query.




TODO:
-files with data into one folder
-allow passing variables into command line
-more complex dataset
