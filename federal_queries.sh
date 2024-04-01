INSTANCE_NAME=names-inst-new
PASSWORD=passw
CONNECTION_ID=$(gcloud sql instances describe $INSTANCE_NAME  --format="value(connectionName)")
PROJECT_ID=$(gcloud info --format='value(config.project)')


bq mk --connection --display_name='Cloud SQL connection - Names' --connection_type='CLOUD_SQL' \
  --properties="{\"instanceId\":\"$CONNECTION_ID\",\"database\":\"bts\",\"type\":\"MYSQL\"}" \
  --connection_credential="{\"username\":\"root\", \"password\":\"$PASSWORD\"}" \
  --project_id=$PROJECT_ID --location=eu names_connection_id
