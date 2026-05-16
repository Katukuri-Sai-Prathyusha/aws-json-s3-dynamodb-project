#!/bin/bash

AWS_REGION="eu-north-1"
S3_BUCKET_NAME="prathyusha-json-dynamodb-project"
S3_BUCKET_PATH="json"
LOCAL_DOWNLOAD_DIR="/tmp/s3-json-files"
DYNAMODB_TABLE_NAME="learnmore"

mkdir -p "$LOCAL_DOWNLOAD_DIR"

if ! aws sts get-caller-identity &>/dev/null; then
    echo "Error: AWS CLI is not configured or IAM permissions are missing!"
    exit 1
fi

FILES=$(aws s3api list-objects-v2 \
    --bucket "$S3_BUCKET_NAME" \
    --prefix "$S3_BUCKET_PATH/" \
    --query 'Contents[?ends_with(Key, `.json`)].Key' \
    --output text)

if [ -z "$FILES" ]; then
    echo "No JSON files found in S3 bucket $S3_BUCKET_NAME."
    exit 0
fi

for FILE_KEY in $FILES; do
    FILE_NAME=$(basename "$FILE_KEY")
    LOCAL_FILE_PATH="$LOCAL_DOWNLOAD_DIR/$FILE_NAME"
    ITEM_FILE_PATH="$LOCAL_DOWNLOAD_DIR/item_$FILE_NAME"

    echo "Downloading $FILE_KEY..."
    aws s3 cp "s3://$S3_BUCKET_NAME/$FILE_KEY" "$LOCAL_FILE_PATH"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to download $FILE_KEY. Skipping..."
        continue
    fi

    jq '.Item' "$LOCAL_FILE_PATH" > "$ITEM_FILE_PATH"

    echo "Loading $FILE_NAME into DynamoDB..."

    aws dynamodb put-item \
        --table-name "$DYNAMODB_TABLE_NAME" \
        --region "$AWS_REGION" \
        --item file://"$ITEM_FILE_PATH"

    if [ $? -eq 0 ]; then
        echo "Successfully loaded $FILE_NAME into DynamoDB"
    else
        echo "Error: Failed to load $FILE_NAME into DynamoDB"
    fi

    rm -f "$LOCAL_FILE_PATH" "$ITEM_FILE_PATH"
done

echo "All operations completed."
