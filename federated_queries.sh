INSTANCE_NAME=netflix-sql
PASSWORD=passw
CONNECTION_ID=$(gcloud sql instances describe $INSTANCE_NAME  --format="value(connectionName)")
PROJECT_ID=$(gcloud info --format='value(config.project)')
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CONNECTION_SERVICE_ACCOUNT=service-$PROJECT_NUMBER@gcp-sa-bigqueryconnection.iam.gserviceaccount.com
CONNECTION_NAME=netflix_connection_id

# Enable BigQuery API.
gcloud services enable bigquery.googleapis.com

# Create External Connetion to the Database.
bq mk --connection --display_name='Cloud SQL - Netflix' --connection_type='CLOUD_SQL' \
  --properties="{\"instanceId\":\"$CONNECTION_ID\",\"database\":\"netflix\",\"type\":\"MYSQL\"}" \
  --connection_credential="{\"username\":\"root\", \"password\":\"$PASSWORD\"}" \
  --project_id=$PROJECT_ID --location=eu $CONNECTION_NAME

# Add the Cloud SQL Client role to a service account relevant to External Connection.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$CONNECTION_SERVICE_ACCOUNT \
    --role=roles/cloudsql.client
