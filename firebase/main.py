from firebase_admin import initialize_app, credentials

from pathlib import Path

cd = Path.cwd()
if cd.name != "firebase":   # must be in root directory
	cd /= "firebase"

path = str (cd / "admin.json")

def init(): 
	print ("Initializing...")
	initialize_app (credentials.Certificate(path))
	return cd
