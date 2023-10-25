from firebase_admin import delete_app
import csv

import lib.utils as utils
import lib.services as firebase

def get_admins(): 
	with open(utils.dir.admins) as file: return {
		row[0]: [i for i in row[1:] if i]
		for row in csv.reader(file)
	}

def set_claims(admins): 
	for email, scopes in admins.items(): 
		if not all(scope in firebase.SCOPES.union({""}) for scope in scopes): 
			raise ValueError(f"Unrecognized scopes for {email}: {scopes}")
		utils.logger.verbose(f"Setting claims for {email}")
		if not scopes: 
			utils.logger.warning(f"Removing admin priveleges for {email}")
		if utils.args.debug:
			utils.logger.debug(f"  Claims for {email}", firebase.get_claims(email))
		if utils.args.should_upload: firebase.set_scopes(email, scopes)
	if not utils.args.should_upload: 
		utils.logger.warning("Did not upload admin claims. Use the --upload flag.")

if __name__ == '__main__':
	utils.logger.info("Setting up admins...")
	admins = utils.logger.log_value("admins", get_admins)
	set_claims(admins)

	delete_app(firebase.app)
	utils.logger.info("Finished setting up admins")

