import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp()

export const calendarUpdated = functions
	.firestore
	.document("/calendar/{month}")
	.onUpdate(
		async (snapshot, context) => {
			const payload = {
				data: {command: "updateCalendar"}
			}

			console.log("Calendar updated")

			await admin
				.messaging()
				.sendToTopic(
					"calendar", 
					payload
				)
		}
	)
