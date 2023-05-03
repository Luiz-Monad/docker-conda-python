#!/bin/bash
### every exit != 0 fails the script
set -e

# Check if the environment variable is set to "google"
if [ "$APP_BUCKET_CLOUD" = "google" ]; then
    echo "Mounting app bucket for google..."

    # Mount the bucket using gcsfuse
    gcsfuse --implicit-dirs $APP_BUCKET_ID /mnt/my-blob

fi