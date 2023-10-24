import lib.utils as utils
import csv
from datetime import date
year = date.today().strftime("%Y")

"""
This handles reading sports.csv and its logic all in one (faster!)
"""

KEYWORDS = {
    "BVH": "Boys Varsity Hockey",
    "BJVH": "Boys JV Hockey",

    "GVBB": "Girls Varsity Basketball",
    "GJVBB": "Girls JV Basketball",

    "BVBB": "Boys Varsity Basketball",
    "BJVBB": "Boys JV Basketball",

    "GVVB": "Girls Varsity Volleyball",
    "GJVVB": "Girls JV Volleyball"
}

def read_sports():
    with open(utils.dir.sports_schedule) as f:
        return_list = []
        for row in csv.DictReader(f):
            opponent = row["Opponent"]
            if opponent == "": continue

            isHome = row["Location"] == "Home"
            livestreamUrl = None

            date = get_date(year, row["Date"])

            scores = None

            try:
                team = KEYWORDS[row["Team"]]
                sport = team.split(" ")[-1].lower()

            # When the [team] cell has the tournament name instead
            except KeyError: 
                team = row["Team"]
                # NOTE: This assumes that for all tournaments, the sport is basketball
                # sports.csv makes no indication what sport it is, but its most likely basketball
                sport = "basketball"

            start = row["Time"].split(" ")[0] # The split(" ")[0] gets rid of " PM" if it's in the time
            try:
                start_hour = int(start[:start.index(":")]) + 12
                start_min = int(start[start.index(":")+1:])

                # Assume games take 1 hour
                end_min = start_min
                end_hour = start_hour + 1

            except:
                start_hour, start_min, end_hour, end_min = 0, 0, 0, 0

            times = {
                "end": {"hour": end_hour, "minutes": end_min},
                "start": {"hour": start_hour, "minutes": start_min}
            }

            return_list.append({"date":date, 
                                "isHome":isHome, 
                                "livestreamUrl":livestreamUrl,
                                 "opponent": opponent,
                                 "scores": scores,
                                 "sport": sport,
                                 "team": team,
                                 "times": times})
        
        return return_list

def get_date(year, date):
    ...
    #2022-02-08 00:00:00.000
    date = date.split("-")[0] # If the date is 11/6 - 11/8, just use 11/6

    month = date[:date.index("/")]
    if len(month) == 1: # If the month has only 1 digit
        month = "0" + month # Make it 2 digits
    if int(month) <= 7:
        year = str(int(year) + 1)
    day = date[date.index("/") +1:]
    if len(day) == 1:
        day = "0" + day
    return year + "-" + month + "-" + day + " 00:00:00.000"
