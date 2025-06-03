import os
from appwrite.client import Client
from appwrite.services.storage import Storage
from appwrite.input_file import InputFile
from appwrite.id import ID

# Initialize Appwrite client
client = Client()
client.set_endpoint('https://fra.cloud.appwrite.io/v1')
client.set_project('68311c8b000a47b14944')
client.set_key('standard_4f9c86e15c8e71e307213dbcf8932d32e51a97f632306b008203e436b0f48af1fa172f957b1d97bf8f4ef35a62e29d908eca1c96ce8874c931de22f3f0b07f139c0d825c0a7fde0469a02eeb78f2c5a12d80e28c20581a4044f7ed501c3bdbf3e2f076ccbc7ae2368e4ef7bc2ff711be143f8f34048a96242c2dd2c7aa43cdf6')
storage = Storage(client)
bucket_id = '68311d94003c6f0af2e6'
folder_path = 'C:/Users/tommy/Documents/GitHub/FrontEnd/content/final_slides'

# List of prefixes to skip
skip_prefixes = [f"01_{i:02d}" for i in range(1, 6)]

for filename in os.listdir(folder_path):
    if any(filename.startswith(prefix) for prefix in skip_prefixes):
        print(f"Skipping {filename} (matches skip prefix)")
        continue  # Skip this file

    file_path = os.path.join(folder_path, filename)
    if os.path.isfile(file_path):
        print("pushing", file_path)
        input_file = InputFile.from_path(file_path)
        storage.create_file(bucket_id, ID.unique(), input_file)
