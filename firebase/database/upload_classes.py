from db import get_db
from data.subjects import Subject

db = get_db()
classes = db.collection("classes")

def upload_class(subject: Subject): 
	doc = classes.document(subject.id)
	doc.set(subject.output())

def batch_upload(subjects: [Subject]):
	batch = db.batch()
	for subject in subjects: 
		doc = classes.document(subject.id)
		batch.set(doc, subject.output())
	batch.commit()

if __name__ == "__main__":
	SUBJECTS = [  # ID: Subject
		Subject (id = "1", name = "Chemistry", teacher = "Dr. Rotenberg"),
		Subject (id = "2", name = "Math", teacher = "Ms. Shine"),
		Subject (id = "3", name = "Talmud", teacher = "Rabbi Albo"),
		Subject (id = "4", name = "Gym", teacher = "Coach D."),
		Subject (id = "5", name = "History", teacher = "Ms. Newman"),
		Subject (id = "6", name = "Lunch", teacher = "Ms. Dashiff"),
		Subject (id = "7", name = "Spanish", teacher = "Mr. Kabot"),
		Subject (id = "8", name = "English", teacher = "Ms. Cohen"),
		Subject (id = "9", name = "Hebrew", teacher = "Ms. Sole-Zier"),
		Subject (id = "10", name = "Tech", teacher = "Ms. Joshi"),
		Subject (id = "11", name = "Chumash", teacher = "Ms. Benus"), 
		Subject (id = "12", name = "Tefillah", teacher = "Rabbi Weiser"),
		Subject (id = "13", name = "Art", teacher = "Ms. Rabhan"),
		Subject (id = "14", name = "Health", teacher = "Ms. Axel")
	]
	batch_upload(SUBJECTS)

# upload_class(Class.random())