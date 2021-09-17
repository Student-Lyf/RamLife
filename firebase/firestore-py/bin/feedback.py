from firebase_admin import delete_app

import lib.utils as utils
import lib.services as firebase

if __name__ == '__main__':
	utils.logger.info("Getting feedback...")
	feedback = firebase.get_feedback()
	feedback.sort()
	for message in feedback:
		utils.logger.debug("Feedback", str(message))

	delete_app(firebase.app)
	utils.logger.info("Got feedback")