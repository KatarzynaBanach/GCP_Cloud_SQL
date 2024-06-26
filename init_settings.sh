gcloud services enable sqladmin.googleapis.com
PROJECT_ID=$(gcloud info --format='value(config.project)')  # Project ID for active project.
INSTANCE_NAME=netflix-sql
PASSWORD=passw

# Create Instance of MySQL.
# The activation policy determines whether the instance remains active or is deactivated when there are no connections to it. 
# Setting it to ALWAYS means the instance remains active even if there are no connections.
#  % is a wildcard that means any host, indicating that the password can be used from any host.
gcloud sql instances create $INSTANCE_NAME --tier=db-n1-standard-1  --activation-policy=ALWAYS --region=europe-central2 --database-version=MYSQL_8_0  
gcloud sql users set-password root --host % --instance $INSTANCE_NAME --password $PASSWORD


# Get Current IP Adress of Cloud Shell & add it to the list of authorized networks that are allowed to connect to the Cloud SQL instance.
ADDRESS=$(wget -qO - http://ipecho.net/plain)/32  
gcloud sql instances patch $INSTANCE_NAME --authorized-networks $ADDRESS

# Get Adress IF of SQL and connect to it using local-infile which enables the LOAD DATA LOCAL INFILE statement.
# LOAD DATA LOCAL INFILE is used when the file is located on the client's filesystem and can be accessed locally by the MySQL client.
# The version with LOAD DATA INFILE won't work it the case since it is used when the file is located on the server's filesystem 
# or accessible via a network file path. However, MySQL does not directly support loading files from remote URLs or Cloud Storage locations.
MYSQLIP=$(gcloud sql instances describe $INSTANCE_NAME --format='value(ipAddresses.ipAddress)')
mysql --host=$MYSQLIP --user=root --password --local-infile -e "CREATE DATABASE IF NOT EXISTS netflix;
USE netflix;
DROP TABLE IF EXISTS netflix_shows;
CREATE TABLE netflix_shows (
viewer_index INT,
title VARCHAR(50),
age_limit INT,
runtime INT,
genre VARCHAR(100),
rating FLOAT,
votes INT);
LOAD DATA LOCAL INFILE 'netflix_shows.csv' INTO TABLE netflix_shows
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(viewer_index, title, age_limit, runtime, genre, rating, votes);"


