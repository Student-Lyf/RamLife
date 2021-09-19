import yaml
from utils import dir

def get_day_names():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["dayNames"]
  
def get_corrupt_students():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["corruptStudents"]

def get_testers():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["testers"]