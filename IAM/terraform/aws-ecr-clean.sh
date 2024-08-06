#!/bin/bash

REPO_NAME=platform-mvp-ecr

# List all images and save the image IDs to a file
aws ecr list-images --repository-name $REPO_NAME --query 'imageIds[*]' --output json > image_ids.json

# Delete all images using the saved image IDs
aws ecr batch-delete-image --repository-name $REPO_NAME --image-ids file://image_ids.json

# Clean up the temporary file
rm image_ids.json


