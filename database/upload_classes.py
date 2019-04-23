from db import get_db
from data.classes import Class

db = get_db().collection("classes")

def upload_class(class_: Class): 
	doc = db.document(class_.id)
	doc.set(class_.output())

upload_class(Class.random())