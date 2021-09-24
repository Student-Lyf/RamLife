import yaml
from . import dir
from datetime import date

is_semester1 = date.today().month > 7

def get_day_names():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["dayNames"]
  
def get_corrupted_students():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["corruptStudents"]

def get_testers():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["testers"]