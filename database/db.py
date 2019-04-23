from firebase_admin import (
	credentials, 
	firestore,
	initialize_app as init
)

def get_db(): 
	creds = credentials.Certificate("admin.json")
	init (creds)
	return firestore.client()
