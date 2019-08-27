from main import init
init()

from firebase_admin import messaging 

token = "dS5eOsrIeoc:APA91bGXNEpMqESxMD8mGVOmXg74N065fWMSI23In2bQfU0GK7qIjQRrs7ZgCvENIXPICwsX4vMlUZnbikzRX5qX3b4zqHuhjk7bywz-lHBvCkcjaAaoQ3qQ1JmEx-zxRawLe5mOKfJh"

message = messaging.Message(
	data = {
		"command": "refresh",
		"click_action": "FLUTTER_NOTIFICATION_CLICK",
		"collapseKey": "refresh",
	},
	token = token
)

response = messaging.send(message)

print("Message sent: " + response)