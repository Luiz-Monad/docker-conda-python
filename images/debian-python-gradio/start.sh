#!/bin/bash
### every exit != 0 fails the script

python /scripts/bootstrap.py

# main
if [ -z "$1" ]; then
    app='web:app'
else
    app=$@
fi
echo "Starting app '$app' ..."
python -m uvicorn "$app" --port $PORT --host 0.0.0.0
