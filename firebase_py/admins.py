from main import init
init()
from firebase_admin import auth as Firebase

CALENDAR = "calendar"
PUBLICATIONS = "publications"
SPORTS = "sports"

ADMINS = {
	"leschesl@ramaz.org": [CALENDAR, PUBLICATIONS, SPORTS],
}

for email, scopes in ADMINS.items():
	user = Firebase.get_user_by_email(email)
	Firebase.set_custom_user_claims(
		user.uid, 
		{"isAdmin": True, 'scopes': scopes, "club": "Rampage"}
	)