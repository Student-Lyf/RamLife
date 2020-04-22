from firebase_admin import initialize_app, credentials, messaging as FCM

print ("Initializing...")
initialize_app (credentials.Certificate(path))

def get_message(command, topic): return FCM.Message(
	data = {
		"command": command,
		"collapseKey": topic,
		"click_action": "FLUTTER_NOTIFICATION_CLICK", 
	},
	topic = topic
)

def send_message(message): 
	return FCM.send(message)
