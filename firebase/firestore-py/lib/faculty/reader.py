import csv
from ..utils import dir
from ..data import student

'''
A collection of functions to read faculty data.
No function in this class actually performs logic on said data, just returns
it. This helps keep the program modular, by separating the data sources from
the data indexing.
'''
def get_faculty():
  with open(dir.faculty) as file:
    return {row["USER_ID"]: student.User(
            id = row["USER_ID"],
            email = row["EMAIL"].lower(),
            first = row["FIRST_NAME"],
            last = row ["LAST_NAME"])
            for row in csv.csv.DictReader(file)}
      