CONNECTION_SERVICE_ACCOUNT=$(gcloud sql instances describe names-inst-new --format="value(serviceAccountEmailAddress)")
PROJECT_ID=$(gcloud info --format='value(config.project)')
BUCKET_NAME='myuniquebucketname'
FILE_NAME='names.csv'
DATASET_ID='names_dataset'
TABLE_NAME='names'

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$CONNECTION_SERVICE_ACCOUNT \
    --role roles/storage.objectAdmin

gcloud storage buckets create gs://$BUCKET_NAME --location=europe-central2

gcloud sql export csv names-inst-new gs://$BUCKET_NAME/$FILE_NAME \
--database=bts \
--offload \
--query='SELECT * FROM names' \
--fields-terminated-by="2C" \
--lines-terminated-by="0A"

bq --location='EU' mk \
    --dataset \
    --description="Data from Cloud SQL" \
    --label=category:prod \
    $PROJECT_ID:$DATASET_ID

bq mk \
--table \
$PROJECT_ID:$DATASET_ID.$TABLE_NAME \
names_schema.json

bq load \
--source_format=CSV \
$DATASET_ID.$TABLE_NAME \
gs://$BUCKET_NAME/$FILE_NAME \
names_schema.json
