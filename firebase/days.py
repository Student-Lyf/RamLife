from main import init
init()

from database.calendar import parse_calendar, upload_calendar

upload_calendar(
	parse_calendar(
		r"C:\users\levi\coding\flutter\ramaz\data\calendar\calendar.csv"
	)
)
