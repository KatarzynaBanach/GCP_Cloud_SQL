INSTANCE_NAME=names-inst-new
PASSWORD=passw
CONNECTION_ID=$(gcloud sql instances describe $INSTANCE_NAME  --format="value(connectionName)")
PROJECT_ID=$(gcloud info --format='value(config.project)')
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CONNECTION_SERVICE_ACCOUNT=service-$PROJECT_NUMBER@gcp-sa-bigqueryconnection.iam.gserviceaccount.com

# Enable BigQuery API.
gcloud services enable bigquery.googleapis.com

# Create External Connetion to the Database.
bq mk --connection --display_name='Cloud SQL connection - Names' --connection_type='CLOUD_SQL' \
  --properties="{\"instanceId\":\"$CONNECTION_ID\",\"database\":\"bts\",\"type\":\"MYSQL\"}" \
  --connection_credential="{\"username\":\"root\", \"password\":\"$PASSWORD\"}" \
  --project_id=$PROJECT_ID --location=eu names_connection_id

# Add the Cloud SQL Client role to a service account relevant to External Connection.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$CONNECTION_SERVICE_ACCOUNT \
    --role=roles/cloudsql.client
