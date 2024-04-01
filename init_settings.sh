gcloud services enable sqladmin.googleapis.com
PROJECT_ID=$(gcloud info --format='value(config.project)')
INSTANCE_NAME=names-inst-new
PASSWORD=passw

QUERY="create database if not exists bts;
use bts;
drop table if exists names;
create table names (
name VARCHAR(10),
surname VARCHAR(15),
age INT);
LOAD DATA LOCAL INFILE 'names_data.csv' INTO TABLE names
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(name,surname,age);"

gcloud sql instances create $INSTANCE_NAME --tier=db-n1-standard-1 --activation-policy=ALWAYS --region=us-central1
gcloud sql users set-password root --host % --instance $INSTANCE_NAME --password $PASSWORD

ADDRESS=$(wget -qO - http://ipecho.net/plain)/32
gcloud sql instances patch $INSTANCE_NAME --authorized-networks $ADDRESS

MYSQLIP=$(gcloud sql instances describe $INSTANCE_NAME --format="value(ipAddresses.ipAddress)")
mysql --host=$MYSQLIP --user=root --password --local-infile -e $QUERY
