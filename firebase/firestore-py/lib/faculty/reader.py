import csv
from .. import utils
from ..data import student

'''
A collection of functions to read faculty data.
No function in this class actually performs logic on said data, just returns
it. This helps keep the program modular, by separating the data sources from
the data indexing.
'''
def get_faculty():
  with open(utils.dir.faculty) as file:
    return {row["USER_ID"]: student.User(
            first = row["FIRST_NAME"],
            last = row ["LAST_NAME"],
            email = row["EMAIL"].lower(),
            id = row["USER_ID"])
            for row in csv.DictReader(file)
            if row ["USER_ID"] not in utils.constants.corrupted_students}

