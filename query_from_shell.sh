INSTANCE_NAME=netflix-sql
USER_NAME_2=user2
PASSWORD_2=passw

gcloud sql users create $USER_NAME_2 --instance=$INSTANCE_NAME
gcloud sql users set-password $USER_NAME_2 --instance $INSTANCE_NAME --password $PASSWORD_2

ADDRESS=$(wget -qO - http://ipecho.net/plain)/32 
gcloud sql instances patch $INSTANCE_NAME --authorized-networks $ADDRESS

MYSQLIP=$(gcloud sql instances describe $INSTANCE_NAME --format='value(ipAddresses.ipAddress)')
mysql --host=$MYSQLIP --user=root --password
