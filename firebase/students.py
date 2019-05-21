from main import init
from data.student import Student, Period
init()
from database.students import upload_students, add_credentials
from auth.crud import create_user, get_user, update_user
from auth.provider import add_provider, get_record

def main(students): 
	upload_students(students)
	records = []
	for student in students: 
		try: 
			user = create_user(student)
		except: 
			uid = get_user(student.username + "@ramaz.org").uid
			user = update_user (uid, student)
		records.append (get_record(user))
		student.uid = user.uid
	# Disable provider for now so users can still log in with password
	# add_provider(records) 
	add_credentials(students)

if __name__ == '__main__':
	first = "Levi"
	last = "Lesches"
	username = "leschesl"
	password = "helloMyDudes"
	A = [
		Period (room = "Beit Knesset", id = 12).output(),
		Period (room = "503", id = 1).output(),
		Period (room = "304", id = 2).output(),
		Period (room = "303", id = 3).output(),
		Period (room = "GYM", id = 4).output(),
		Period (room = "604", id = 5).output(),
		Period (room = "AUD", id = 6).output(),
		Period (room = "506", id = 3).output(),
		Period (room = "506", id = 7).output(),
		Period (room = "601", id = 8).output(),
		Period (room = "304", id = 9).output()
	]
	B = [
		Period (room = "Beit Knesset", id = 12).output(),
		Period (room = "503", id = 1).output(),
		Period (room = "507", id = 2).output(),
		None,
		Period (room = "304", id = 8).output(),
		Period (room = "303", id = 11).output(),
		Period (room = "GYM", id = 4).output(),
		Period (room = "AUD", id = 6).output(),
		Period (room = "304", id = 9).output(),
		None,
		Period (room = "501", id = 3).output(),
	]
	C = [
		Period (room = "Beit Knesset", id = 12).output(),
		Period (room = "303", id = 11).output(),
		Period (room = "604", id = 5).output(),
		Period (room = "506", id = 3).output(),
		Period (room = "304", id = 2).output(),
		Period (room = "704", id = 13).output(),
		Period (room = "AUD", id = 6).output(),
		Period (room = "503", id = 1).output(),
		Period (room = "301", id = 8).output(),
		Period (room = "506", id = 3).output(),
		Period (room = "501", id = 14).output(),
	]
	M = [
		Period (room = "Beit Knesset", id = 12).output(),
		Period (room = "GYM", id = 4).output(),
		Period (room = "506", id = 3).output(),
		Period (room = "503", id = 1).output(),
		Period (room = "604", id = 5).output(),
		Period (room = "703", id = 10).output(),
		Period (room = "AUD", id = 6).output(),
		Period (room = "401", id = 8).output(),
		Period (room = "301", id = 7).output(),
		Period (room = "506", id = 2).output(),
		Period (room = "301", id = 11).output()
	]
	R = [
		Period (room = "Beit Knesset", id = 12).output(),
		Period (room = "704", id = 13).output(),
		Period (room = "305", id = 2).output(),
		Period (room = "306", id = 7).output(),
		Period (room = "506", id = 3).output(),
		Period (room = "406", id = 8).output(),
		Period (room = "304", id = 11).output(),
		Period (room = "AUD", id = 6).output(),
		Period (room = "304", id = 9).output(),
		Period (room = "604", id = 5).output(),
		Period (room = "503", id = 1).output(),
	]
	E = [
		Period (room = "Beit Knesset", id = 12).output(),
		Period (room = "506", id = 3).output(),
		Period (room = "704", id = 13).output(),
		Period (room = "201", id = 7).output(),
		Period (room = "604", id = 5).output(),
		Period (room = "302", id = 2).output(),
		Period (room = "503", id = 1).output(),
	]
	F = [
		Period (room = "Beit Knesset", id = 12).output(),
		Period (room = "201", id = 11).output(),
		Period (room = "301", id = 3).output(),
		Period (room = "507", id = 8).output(),
		Period (room = "304", id = 9).output(),
		Period (room = "703", id = 10).output(),
		Period (room = "604", id = 5).output(),
	]

	mincha_rooms = {
		"A": "503",
		"B": "304",
		"C": "303",
		"M": "303",
		"R": "304",
	}
	homeroom = "507"
	levi = Student (
		mincha_rooms = mincha_rooms,
		password = password,
		username = username,
		homeroom = homeroom,
		first = first,
		last = last,
		A = A, 
		B = B, 
		C = C,
		M = M, 
		R = R,
		E = E, 
		F = F
	)
	main([levi])
