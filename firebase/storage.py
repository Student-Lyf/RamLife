from main import init
init()

from firebase_admin import storage

bucket = storage.bucket("ramaz-go.appspot.com")

blob = bucket.blob("Rampage/")
# for blob in bucket.list_blobs(): 
# 	print (blob)
# blob.metadata = {"hello": "there"}
# with open ("temp.pdf", "w") as file: 

# blob.download_to_filename("temp.pdf")
if False: 
	blob.metadata = {
		"description": "A description",
		"imagePath": "images/logos/ramaz/ram_square_words.png",
		"recents": "Rampage/2019_05_22.pdf",
		"allIssues": "Rampage/2019_05_22.pdf, Rampage/2019_05_21.pdf",
	}
	blob.update()
else: blob.reload()
print (blob.metadata)