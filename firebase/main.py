from firebase_admin import initialize_app, credentials

def init(): 
	print ("Initializing...")
	initialize_app (credentials.Certificate("admin.json"))
