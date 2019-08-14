from main import init
init()

from firebase_admin import messaging 

token = "fYh2TKdxTvE:APA91bEfMClJXMhpdJP2_OSeiQD7P6Q-BNFKKSGz5qEPnm6QmWJWkgfwPyZcZQgw-cEDVAFBOnzHD3em78Yhj9CXyoe1uuunH_o2RgebJLkD1ieXr79-NpF9txkMJ7opTM0DTHDHGev6"

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