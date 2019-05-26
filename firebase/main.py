from firebase_admin import initialize_app, credentials

def init(): initialize_app (
	credentials.Certificate("admin.json")
)
