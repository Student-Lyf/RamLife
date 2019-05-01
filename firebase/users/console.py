from auth import get_auth as init
from add_user import create_user

init()

create_user (
	email = "leschesl@ramaz.org",
	password = "redcow182",
	display_name = "Levi Lesches",
	uid = "123"
)

# from firebase_admin import auth

# user = auth.get_user("123")
# # print (user.provider_data [0].provider_id)

# print (
# 	any (
# 		provider.provider_id == "google.com"
# 		for provider in user.provider_data
# 	)
# )