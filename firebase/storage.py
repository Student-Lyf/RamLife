from main import init
init()

from firebase_admin import storage

bucket = storage.bucket("ramaz-go.appspot.com")

blob = bucket.blob("Rampage/issues.txt")
# for blob in bucket.list_blobs(): 
# 	print (blob)
# blob.metadata = {"hello": "there"}
# with open ("temp.pdf", "w") as file: 

# blob.download_to_filename("temp.pdf")
if True: 
	blob.metadata = {
		"description": "A description",
		"issues": "Rampage/2019_05_22.pdf",
	}
	blob.update()
else: blob.reload()
print (blob.metadata)