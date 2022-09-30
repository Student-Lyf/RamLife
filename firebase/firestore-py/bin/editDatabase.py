from lib.data.schedule import Section
from lib import utils, services

print("Would you like to add a section (a) or change a section (c)?\n")

add_or_change = input("a or c : ").lower()
if add_or_change == "a":
    section_id = input("Section id: ")
    name = input("Section name: ")
    teacher = input("Section teacher: ")
    section = Section(name, id, teacher, zoom_link="")

    # upload_sections usually expects many sections, but we only want to upload one
    utils.logger.log_progress(
      "section upload", lambda: services.upload_sections([section])
    )

elif add_or_change == "c":
    section_id = input("Section id: ")

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
