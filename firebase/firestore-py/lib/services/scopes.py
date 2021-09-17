# Holds the names for the admin scopes.
class Scopes:
	# The scope name for calendar admins.
	calendar = "calendar";

	# The scope name for publication admins.
	publications = "publications";

	# The scope name for sports admins.
	sports = "sports";

	# A list of all acceptable scopes. 
	# 
	# These scopes are the only ones recognized by the app. Since the data is 
	# pulled from a file, this safeguards against typos.
	scopes = {calendar, publications, sports};
