INSTANCE_NAME=netflix-sql
CONNECTION_SERVICE_ACCOUNT=$(gcloud sql instances describe $INSTANCE_NAME --format="value(serviceAccountEmailAddress)")
PROJECT_ID=$(gcloud info --format='value(config.project)')
BUCKET_NAME="netflix-$PROJECT_ID"  # Bucket name need to be globally unique. Using Project_ID assures meeting that requirement.
# using "" instead of '' allows you to use a variable inside. 
FILE_NAME='netflix_shows.csv'
DATASET_ID='netflix_from_CS'
TABLE_NAME='netflix_shows'

# Add the Storage Object Admin role to a service account relevant to Cloud SQL Instance.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$CONNECTION_SERVICE_ACCOUNT \
    --role roles/storage.objectAdmin

# Create bucket.
gcloud storage buckets create gs://$BUCKET_NAME --location=europe-central2


# Export data into bucket.
gcloud sql export csv $INSTANCE_NAME gs://$BUCKET_NAME/$FILE_NAME \
--database=netflix \
--offload \
--query='SELECT * FROM netflix_shows' \
--fields-terminated-by="2C" \
--lines-terminated-by="0A"

# Create Dataset.
bq --location='EU' mk \
    --dataset \
    --description="Netflix Data from Cloud SQL" \
    --label=category:prod \
    $PROJECT_ID:$DATASET_ID

# Create Table. Schema from json file.
bq mk \
--table \
$PROJECT_ID:$DATASET_ID.$TABLE_NAME \
netflix_shows_schema.json

# Load data into table.
bq load \
--source_format=CSV \
$DATASET_ID.$TABLE_NAME \
gs://$BUCKET_NAME/$FILE_NAME \
netflix_shows_schema.json
