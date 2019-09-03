from main import init
init()
from firebase_admin import auth as Firebase

CALENDAR = "calendar"

ADMINS = {
	"leschesl@ramaz.org": [CALENDAR],
}

for email, scopes in ADMINS.items():
	user = Firebase.get_user_by_email(email)
	Firebase.set_custom_user_claims(user.uid, {'scopes': scopes})