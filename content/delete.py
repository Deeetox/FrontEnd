from appwrite.client import Client
from appwrite.services.storage import Storage
from appwrite.query import Query

client = Client()
client.set_endpoint('https://fra.cloud.appwrite.io/v1')
client.set_project('68311c8b000a47b14944')
client.set_key('standard_4f9c86e15c8e71e307213dbcf8932d32e51a97f632306b008203e436b0f48af1fa172f957b1d97bf8f4ef35a62e29d908eca1c96ce8874c931de22f3f0b07f139c0d825c0a7fde0469a02eeb78f2c5a12d80e28c20581a4044f7ed501c3bdbf3e2f076ccbc7ae2368e4ef7bc2ff711be143f8f34048a96242c2dd2c7aa43cdf6')
storage = Storage(client)
bucket_id = '68311d94003c6f0af2e6'

# Query for files whose names start with "02"
queries = [Query.starts_with("name", "02")]

# Handle pagination if you have a lot of files
while True:
    response = storage.list_files(bucket_id=bucket_id, queries=queries)
    files = response['files']
    if not files:
        break
    for file in files:
        print(f"Deleting {file['name']} (id: {file['$id']})")
        storage.delete_file(bucket_id, file['$id'])

