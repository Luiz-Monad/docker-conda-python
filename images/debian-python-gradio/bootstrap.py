import os
import tempfile
import zipfile
from google.cloud import storage
from google.oauth2.service_account import Credentials

# Set up authentication and create client object
client = storage.Client()

# Get bucket reference
bucket_id = os.environ['APP_BUCKET_ID']
bucket = client.bucket(bucket_id)

# Get blob reference and download to temp file
blob_name = os.environ['APP_BUCKET_BLOB']
blob = bucket.blob(blob_name)
_, temp_file = tempfile.mkstemp()
blob.download_to_filename(temp_file)

# Unzip file
with zipfile.ZipFile(temp_file, 'r') as zip_ref:
    zip_ref.extractall('.')

# Remove temporary file
os.remove(temp_file)

print('File downloaded and unzipped successfully!')
