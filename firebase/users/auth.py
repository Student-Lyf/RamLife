from firebase_admin import (
	credentials, 
	initialize_app as init,
	auth
)

def get_auth(): 
	creds = credentials.Certificate (
		r"C:\users\levi\coding\flutter\ramaz\firebase\admin.json"
	)
	init (creds)
	return auth