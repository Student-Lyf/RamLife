import yaml
from utils import dir

def getDayNames():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["dayNames"]
  
def getCorruptStudents():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["corruptStudents"]

def getTesters():
  with open(dir.constants) as file:
    constants = yaml.full_load(file)
    return constants["testers"]