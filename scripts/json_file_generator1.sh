#!/bin/bash

output_dir="generated_files"
mkdir -p "$output_dir"

read -r -d '' TEMPLATE << EOM
{
    "Item": {
        "PK": {
            "S": "{{UNIQUE_PK}}"
        },
        "SK": {
            "S": "ver1"
        },
        "record_type": {
            "S": "product"
        },
        "product_id": {
            "N": "1002"
        },
        "version": {
            "N": "1"
        },
        "product_name": {
            "S": "car"
        },
        "list_price": {
            "N": "36000.00"
        },
        "image_bucket": {
            "S": "dynamodb-images"
        },
        "image_object": {
            "S": "img/car1.jpg"
        }
    }
}
EOM

for i in $(seq 1 100); do
    unique_pk="prd$((1000 + i))"
    output_file="$output_dir/item_${unique_pk}.json"
    echo "$TEMPLATE" | sed "s/{{UNIQUE_PK}}/$unique_pk/" > "$output_file"
    echo "Generated: $output_file"
done

echo "All files are generated in the directory: $output_dir"
