from lib.data.schedule import Section
from lib import utils, services

print("Would you like to add a section (a) change a section (c) update schedule with PDF (p)?\n")

choice = input("a or c or p: ").lower()

if choice == "a":
    section_id = input("Section id: ")
    name = input("Section name: ")
    teacher = input("Section teacher: ")
    section = Section(name, id, teacher, zoom_link="")

    # upload_sections usually expects many sections, but we only want to upload one
    utils.logger.log_progress(
      "section upload", lambda: services.upload_sections([section])
    )

elif choice == "c":
    section_id = input("Section id: ")

elif choice == "p":
  from lib.utils import txtschedule_reader as reader
  files = reader.get_files()
  schedules = []
  students = []
  for file in files:
    lines = reader.read_pdf(file)
    schedule = reader.build_schedule(lines)
    
    print(f"Verify?\n{schedule}")
    print(f"Enter email for {reader.get_name(lines)}")
    user = input(": ").lower()
    students.append(user)
    schedules.append(schedule)

  if utils.args.should_upload:
    utils.logger.log_progress(
      "data update", lambda: services.update_user_beta(students, schedules)
    )
  else:
    for i in range(len(students)):
      print(students[i])
      print(schedules[i])
    print("-----------")

  quit()

else:
    print("Please enter a proper answer, a or c")
    quit()

meetings = []    
for day in utils.constants.day_names:
    print(f"Enter periods for {day} in - p1 room1, p2 room2, p3 room3... - format")
    print( "If there are no periods that day, press enter")
    periodsstr = input(": ")
    if periodsstr == "": continue
    periods = periodsstr.split(", ")
    for period in periods:
        p, room = period.split(" ")
        meetings.append([day, p, room]) 

students = []
temp_input = "none"
while temp_input != "":
    temp_input = input("Enter an email of a student or teacher taking this section: ")
    if temp_input == "":
        break
    students.append(temp_input)

assert len(students) > 0, "Section must have a student to edit"

utils.logger.log_progress(
    "data update", lambda: services.update_user(students, section_id, meetings)
)

