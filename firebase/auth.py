from firebase_admin import auth as Firebase
from data.student import Student

def create_user (student): return Firebase.create_user (
	email = student.username + "@ramaz.org",
	# password = student.password,
	password = "ThisShouldNotBeUsed",
	display_name = student.first + student.last,
	email_verified = False,
	phone_number = None,
	photo_url = None,
	disabled = False
)

def get_record(record): return Firebase.ImportUserRecord (
	uid = record.uid,
	email = record.email,
	display_name = record.display_name,
	provider_data = [
		Firebase.UserProvider (
			provider_id = "google.com",
			email = record.email,
			uid = record.uid
		),
		Firebase.UserProvider (
			provider_id = "password",
			email = record.email,
			uid = record.uid
		)
	]
)

def add_provider(users): Firebase.import_users (users)

def get_users(): return Firebase.list_users().iterate_all()