from auth import get_auth as init
from add_user import create_user

init()

create_user (
	email = "leschesl@ramaz.org",
	password = "redcow182",
	display_name = "Levi Lesches",
	uid = "123"
)