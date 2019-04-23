from db import get_db

db = get_db()
doc = db.collection("students").document("leschesl").get()
data = doc.to_dict()
# print(data["first"], data["last"])
print (data)