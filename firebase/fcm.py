from main import init
init()

from firebase_admin import messaging 

# token = "fYh2TKdxTvE:APA91bEfMClJXMhpdJP2_OSeiQD7P6Q-BNFKKSGz5qEPnm6QmWJWkgfwPyZcZQgw-cEDVAFBOnzHD3em78Yhj9CXyoe1uuunH_o2RgebJLkD1ieXr79-NpF9txkMJ7opTM0DTHDHGev6",
# token = "267381428578"
token = "fYh2TKdxTvE:APA91bEfMClJXMhpdJP2_OSeiQD7P6Q-BNFKKSGz5qEPnm6QmWJWkgfwPyZcZQgw-cEDVAFBOnzHD3em78Yhj9CXyoe1uuunH_o2RgebJLkD1ieXr79-NpF9txkMJ7opTM0DTHDHGev6"

message = messaging.Message(
	notification=messaging.Notification(
		title = "hello",
		body = "testing",
	),
	data = {
		"body": "hey there",
		"click_action": "FLUTTER_NOTIFICATION_CLICK",
	},
	token = token
)

response = messaging.send(message)

print("Message sent: " + response)