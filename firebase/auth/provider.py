from firebase_admin import auth
from data.student import Student

def get_record(record): return auth.ImportUserRecord (
	uid = record.uid,
	email = record.email,
	display_name = record.display_name,
	provider_data = [
		auth.UserProvider (
			provider_id = "google.com",
			email = record.email,
			uid = record.uid
		),
		auth.UserProvider (
			provider_id = "password",
			email = record.email,
			uid = record.uid
		)
	]
)

def add_provider(users): auth.import_users (users)

def get_users(): return auth.list_users().iterate_all()