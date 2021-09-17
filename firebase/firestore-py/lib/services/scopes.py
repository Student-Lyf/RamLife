# The scope name for calendar admins.
_calendar = "calendar";

# The scope name for publication admins.
_publications = "publications";

# The scope name for sports admins.
_sports = "sports";

# A list of all acceptable scopes. 
# 
# These scopes are the only ones recognized by the app. Since the data is 
# pulled from a file, this safeguards against typos.
SCOPES = {_calendar, _publications, _sports};
