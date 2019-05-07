from firebase_admin import auth

def create_user (student): return auth.create_user (
	email = student.username + "@ramaz.org",
	password = student.password,
	display_name = student.first + student.last,
	email_verified = False,
	phone_number = None,
	photo_url = None,
	disabled = False
)

def get_user(email): return auth.get_user_by_email(email)