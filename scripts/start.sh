#!/bin/bash
### every exit != 0 fails the script

/scripts/mount-app-gcs.sh

# main
if [ -z "$1" ]; then
    app='web:app'
else
    app=$@
fi
echo "Starting app '$app' ..."
python -m uvicorn "$app" --port $PORT
