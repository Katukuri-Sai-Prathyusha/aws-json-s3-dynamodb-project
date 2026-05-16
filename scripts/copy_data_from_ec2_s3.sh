#!/bin/bash

SOURCE_FOLDER="/home/ec2-user/project/generated_files"
S3_BUCKET_NAME="prathyusha-json-dynamodb-project"
S3_BUCKET_PATH="json"

if [ ! -d "$SOURCE_FOLDER" ]; then
    echo "Error: The folder $SOURCE_FOLDER does not exist!"
    exit 1
fi

if ! aws sts get-caller-identity &>/dev/null; then
    echo "Error: AWS CLI is not configured properly or IAM permissions are missing!"
    exit 1
fi

FILES=$(find "$SOURCE_FOLDER" -maxdepth 1 -type f -name "*.json")

if [ -z "$FILES" ]; then
    echo "No JSON files found in the folder $SOURCE_FOLDER!"
    exit 0
fi

for FILE in $FILES; do
    echo "Uploading $FILE to S3..."
    aws s3 cp "$FILE" "s3://$S3_BUCKET_NAME/$S3_BUCKET_PATH/$(basename "$FILE")"

    if [ $? -eq 0 ]; then
        echo "File $FILE successfully copied to S3!"
    else
        echo "Error: File $FILE copy to S3 failed."
    fi
done

echo "All file uploads attempted."
