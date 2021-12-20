from .firebase import app
from firebase_admin import auth
from firebase_admin.exceptions import NotFoundError

def create_user(email): 
	auth.create_user(email=email)

def get_user(email): 
	try: return auth.get_user_by_email(email)
	except NotFoundError: return create_user(email)

def get_claims(email): 
	return get_user(email).custom_claims

def set_scopes(email, scopes): auth.set_custom_user_claims(
	get_user(email).uid,
	{"isAdmin": bool(scopes), "scopes": scopes},
)

