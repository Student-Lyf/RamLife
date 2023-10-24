from firebase_admin import _DEFAULT_APP_NAME, firestore
from .. import data
from datetime import date

_firestore = firestore.client()

students = _firestore.collection("students")
calendar = _firestore.collection("calendar")
courses = _firestore.collection("classes")
feedback = _firestore.collection("feedback")
dataRefresh = _firestore.collection("dataRefresh")
sports = _firestore.collection("sports2")

def upload_users(users): 
  batch = _firestore.batch()
  for user in users:
    batch.set(students.document(user.email), user.to_json())
  batch.commit()

def upload_month(month, data): 
  calendar.document(str(month)).update({
    "month": month,
    "calendar": [(day.to_json() if day is not None else None) for day in data]
  })

def upload_sections(sections):
  if len(sections) > 500:
    upload_sections(sections[:500])
    upload_sections(sections[500:])
    return
  batch = _firestore.batch()
  for section in sections:
    batch.set(courses.document(section.id), section.to_json())
  batch.commit()

def get_month(month): 
  return calendar.document(str(month)).get().to_dict()

def get_feedback(): return [
  data.Feedback.from_json(document.to_dict())
  for document in feedback.get()
]

def upload_userdate(date):
  dataRefresh.document("dataRefresh").update({
    "user": date
  }) 

def upload_caldate(date):
  dataRefresh.document("dataRefresh").update({
    "calendar": date
  })

# Note: users is a list of emails (str) not User objects
def update_user(users, section_id, meetings):
  if len(users) > 10: 
    update_user(users[10:], section_id, meetings)
    users = users[:10]
  query = students.where("email", "in", users).stream()
  batch = _firestore.batch()
  for user in query:
    user_dict = user.to_dict()
    for day, period, room in meetings:
      user_dict[day][int(period)-1] = {
        "id": section_id,
        "name": period,
        "room": room,
        "dayName": day
      }
    batch.set(students.document(user_dict["email"]), user_dict)
  
  batch.commit()

def upload_sports(sports_games):
  from datetime import date
  year = date.today().strftime("%Y")
  month = int(date.today().strftime("%m"))

  # In the academic year 22' - 23', use 2022 not 2023
  if month < 7:
    year = str(int(year) - 1)

  sports.document(year).set({"games": sports_games})

def update_user_beta(users, schedules):
  """
  Updates users in firestore by reading the whole schedule from a pdf (this part is just the updating part)
  Precondition: users is a list of emails
                schedules is a list of dictioniaries that map weekdays to a list of Period objects.
                Each index of users corresponds to a schedule in schedules.
  
  Note: Reads the user's data first because not all of their data can be obtained from the PDF
        Ex: Homeroom info
  """
  if len(users) > 10: 
    update_user_beta(users[10:], schedules[10:])
    users = users[:10]
    schedules = schedules[:10]

  user_to_sched = {users[i]:schedules[i] for i in range(len(users))}

  query = students.where("email", "in", users).stream()
  batch = _firestore.batch()

  for user in query:
    user_dict = user.to_dict()
    email = user_dict['email']
    schedule = user_to_sched[email]
 
    for day, sched in schedule.items():
      for p_num,period in enumerate(sched):
        if period is not None:
          user_dict[day][p_num] = {
            'room': period.room,
            'dayName': day,
            'id': period.id,
            'name': period.period
          }
        else:
          user_dict[day][p_num] = None
    batch.set(students.document(user_dict['email']), user_dict)
  batch.commit()
