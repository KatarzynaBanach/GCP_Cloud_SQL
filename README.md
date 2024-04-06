_IN PROGRESS_ 

# GCP_Cloud_SQL

While learning about different GCP storage possibilities I really wanted to know them in practical way, how to use them, how to load, query and extract data, how to transfer data into different storage options. That repo allows to play with Cloud SQL and show some its basics features. I encountered challanges such as location limits (important to consider during transferring data), adding suitable roles to relevant service accounts, trying to do as much as possible using bash scripting and command-line Cloud Shell instead of clicking in Cloud Console - so that in the future those steps could be automated (as we all know automation is crucial while buidling data pipelines).

Stack: GCP, bash, Cloud SQL (MySQL), BigQuery, Cloud Storage 

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
sh federated_queries.sh
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
  EXTERNAL_QUERY("digital-bonfire-419015.eu.netflix_connection_id", "SELECT * FROM netflix.netflix_shows;");
```
If you want to create a dataset and persistent table with the netflix data the following query can be useful:
```
DROP SCHEMA IF EXISTS netflix;
CREATE SCHEMA netflix
OPTIONS (
  location = "EU"
);
CREATE OR REPLACE TABLE netflix.netflix AS 
SELECT
*
FROM
EXTERNAL_QUERY("digital-bonfire-419015.eu.netflix_connection_id", "SELECT * FROM netflix.netflix_shows;");
```
*Specifying location the same as location of external connection is important.

## LOAD TO CLOUD STORAGE & TO BIG QUERY:
1. Check file to_cloudstorage_to_bq.sh whether some variables need to changed & execute it (bucket name needs to be changed for sure, since it needs to be unique globally)
```
sh to_cloudstorage_to_bq.sh
```
2. Now you have data in Cloud Storage as well as you can query data that was loaded into Big Query.
Examplary query displaying appeared_in_top top watched 10 genres, the average rating and rank based on that rating (transforming 'genre' column into ARRAY may be useful).
```
WITH shows AS (
SELECT
  REPLACE(genre, ' ', '') AS top_genre,
  COUNT(*) AS appeared_in_top,
  ROUND(AVG(rating), 2) AS avg_rating
FROM `digital-bonfire-419015.netflix_from_CS.netflix_shows`
JOIN UNNEST(SPLIT(genre, ',')) genre
GROUP BY top_genre
ORDER BY appeared_in_top DESC
LIMIT 10
)
SELECT
  top_genre, appeared_in_top, avg_rating,
  RANK() OVER (ORDER BY avg_rating DESC) AS rank_by_avg_rating
FROM shows
ORDER BY appeared_in_top DESC
```
![obraz](https://github.com/KatarzynaBanach/GCP_Cloud_SQL/assets/102869680/068b6d87-c9cd-4237-8e34-3a1516fd0442)


TO BE DONE:
* allow passing variables into command line
* new user to SQL instance and quering from cs
* schema what is happening
