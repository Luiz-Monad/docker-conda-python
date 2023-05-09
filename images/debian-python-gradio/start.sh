#!/bin/bash
### every exit != 0 fails the script

# Check if the environment variable is set to "google"
if ! [ -z "$APP_BUCKET_CLOUD" ]; then
    echo "Mounting app bucket..."

    python /scripts/bootstrap.py $APP_BUCKET_CLOUD

fi

# main
if [ -z "$1" ]; then
    app='web:app'
else
    app=$@
fi
echo "Starting app '$app' ..."
python -m uvicorn "$app" --port $PORT --host 0.0.0.0
