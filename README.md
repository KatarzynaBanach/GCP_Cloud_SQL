# GCP Cloud SQL

**Stack: GCP, bash, Cloud SQL (MySQL), BigQuery, Cloud Storage**

While learning about different GCP storage possibilities I really wanted to know them in practical way, how to use them, how to load, query and extract data, how to transfer data into different storage options. That repo allows to play with Cloud SQL and show some its basics features. 
I encountered challanges such as: 
* **location contraints** (important to consider during transferring data),
* finding out that each time **a new session in Cloud Shell is started, there is a new IP Adress**, so I have to grab it each time and add it to authorised adresses,
* adding **suitable roles** to relevant service accounts,
* trying to do as much as possible using **bash scripting and command-line Cloud Shell** instead of clicking in Cloud Console - so that in the future those **steps could be automated** (as we all know automation is crucial while buidling data pipelines).

The flow of data using that repo:
![obraz](https://github.com/KatarzynaBanach/GCP_Cloud_SQL/assets/102869680/2a74ee92-9306-4e0d-b222-cd5bba631446)

*Used Data comes from Imdb stating the most watched Netflix original shows globally.
Source of Data: [https://www.kaggle.com/code/adarsh0063/most-watched-netflix-data-analysis
](https://www.kaggle.com/datasets/jatinthakur706/most-watched-netflix-original-shows-tv-time)

## SETUP:

1. Open Cloud Shell, copy repo and choose that directory:
```
git -C ~ clone https://github.com/KatarzynaBanach/GCP_Cloud_SQL
cd GCP_Cloud_SQL/
```
4. Check file init_setting.sh, change an examplary password and other variables if needed.
5. Execute file :
```
sh init_setting.sh
```
You will be asked: 'Do you want to continue?' -> press 'y'. If asked for the password type it in.

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

## QUERING FROM CLOUD SHELL
1. Check file query_from_shell.sh whether some variable need to be changed (such as password for new user - it is best practice to use user other then root on daily basis).
Execute it.
```
sh query_from_shell.sh
```
You will be asked: 'Do you want to continue?' -> press 'y'. If asked for the password type it in.
When connected to MySql instance command-line you can use SQL queries (remember about ';', otherwise query won't be executed and pressing enter just will move you to new line).
![obraz](https://github.com/KatarzynaBanach/GCP_Cloud_SQL/assets/102869680/77ad48dd-4991-4733-83ba-8af9d44061e7)


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
