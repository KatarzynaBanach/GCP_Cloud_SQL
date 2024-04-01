# GCP_Cloud_SQL
SETUP:

1. Exemple password and other variables given - do not hesitate to change in needed.
2. Open Cloud Shell & create new directory (eg. cloud_sql_test: (mkdir cloud_sql_test / cd cloud_sql_test)) & upload files  # TODO zip directory instead od files
3. If files saved into user directory you should copy them:
```
cp /home/banachkatarzyna10/names_data.csv ./names_data.csv
cp /home/banachkatarzyna10/init_settings.sh ./init_settings.sh
```
5. Execute file :
```
sh init_setting.sh
```
You will be asked: 'Do you want to continue?' press 'y'
If asked for the password type it.


FEDERATED QUERIES:
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
