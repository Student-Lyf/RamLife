from main import init
init()

from database.feedback import get_feedback
print ("\n".join (map (str, get_feedback())))