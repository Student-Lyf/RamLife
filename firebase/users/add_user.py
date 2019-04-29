from firebase_admin import auth

def create_user (
	email,
	password,
	display_name,
	uid
):
	return auth.create_user (
		email = email,
		uid = uid,
		password = password,
		display_name = display_name,
		# ---------------------------
		email_verified = False,
		phone_number = None,
		photo_url = None,
		disabled = False
	)

