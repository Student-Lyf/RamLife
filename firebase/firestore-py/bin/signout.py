from firebase_admin import delete_app
import lib.services as firebase
import lib.utils as utils

if __name__ == "__main__":
	utils.logger.info("Signing out all users...")
	for user in firebase.list_users():
		firebase.auth.revoke_token(user)

	delete_app(firebase.app)
	utils.logger.info("All users have been signed out")
