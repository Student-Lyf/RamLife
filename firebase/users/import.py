from firebase_admin.auth import ImportUserRecord as Record, import_users, UserProvider 

def create_users(users): 
	import_users (users)

from auth import get_auth
get_auth()

auth1 = Record (
	uid = "123",
	display_name = "Levi Lesches",
	email = "leschesl@ramaz.org",
	provider_data = [
		UserProvider (
			email = "leschesl@ramaz.org",
			provider_id = "google.com",
			uid = "123"
		)
	]
)

create_users([auth1])