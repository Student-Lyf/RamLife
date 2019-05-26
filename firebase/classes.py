from data.subjects import Subject
from main import init
init()
from database.classes import batch_upload

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
