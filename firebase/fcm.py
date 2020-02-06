from main import init
init()

from firebase_admin import messaging 

message = messaging.Message(
	data = {
		"command": "updateCalendar",
		"click_action": "FLUTTER_NOTIFICATION_CLICK",
		"collapseKey": "calendar",
	},
	topic = "calendar"
)

response = messaging.send(message)

print(f"Message sent: {response}")
