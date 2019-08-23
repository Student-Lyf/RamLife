from main import init
init()

from firebase_admin import messaging 

token = "cEdcFTaKsiQ:APA91bECBKXtnEDIXFcwucd8n7VtutQNNXf2dm135oubWlk6ddC847P2R1ojXNI3Hq89waqds1xRPzOUHQA4Chys79LDjWPp70Aqve2FxjhFldapOSHoNwVwwEU8QeyuortPkiu9k9m1"

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