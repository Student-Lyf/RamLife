from firebase_admin import firestore
from data.feedback import Feedback

db = firestore.client().collection("feedback")

def get_feedback(): 
	result = []
	docs = db.get()
	for doc in docs: 
		data = doc.to_dict()
		feedback = Feedback(
			timestamp = data["timestamp"],
			user = data ["name"],
			message = data["message"]
		)
		result.append (feedback)
	return result
