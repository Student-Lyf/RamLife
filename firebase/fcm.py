from main import init
init()

from firebase_admin import messaging as FCM

def get_command(command, topic): return FCM.Message(
	data = {
		"command": command,
		"collapseKey": topic,
		"click_action": "FLUTTER_NOTIFICATION_CLICK", 
	},
	topic = topic
)
