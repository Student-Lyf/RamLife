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

class SportsGame():
    def __init__(self, opponent,location,date, livestream_url, scores, team,start):

        self.opponent = opponent
        self.is_home = location == "Home"
        self.date = date
        self.livestream_url = livestream_url
        self.scores = scores

        if team in KEYWORDS:
            self.team = KEYWORDS[team]
            self.sport = team.split(" ")[-1].lower()
        else:
            self.team = team
            self.sport = "basketball"

        try:
            start_hour = int(start[:start.index(":")]) + 12
            start_min = int(start[start.index(":")+1:])

            # Assume games take 1.5 hours
            end_min = start_min + 30
            end_hour = start_hour + 1

            if end_min > 60:
                end_hour += end_min // 60
                end_min = end_min % 60


        except:
            start_hour, start_min, end_hour, end_min = 0, 0, 0, 0
    
        self.times = {
            "end": {"hour": end_hour, "minutes": end_min},
            "start": {"hour": start_hour, "minutes": start_min}
        }
    
    def to_json(self): return {
        "date" : self.date, 
        "isHome" : self.is_home, 
        "livestreamUrl":  self.livestream_url,
        "opponent" : self.opponent,
        "scores" : self.scores,
        "sport" : self.sport,
        "team" : self.team,
        "times": self.team
        }
