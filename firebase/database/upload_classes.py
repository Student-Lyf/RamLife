from db import get_db
from data.subjects import Subject

db = get_db().collection("classes")

def upload_class(subject: Subject): 
	doc = db.document(subject.id)
	doc.set(subject.output())

# upload_class(Class.random())