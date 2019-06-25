from students import CSVReader

ELECTIVE_IDS = [
	"IADV", 
	"IADV", 
	"IADV", 
	"IADV", 

	"IADV11", 
	"IADV11", 
	"IADV11", 
	"IADV11", 

	"CADV", 
	"CADV", 
	"CADV", 
	"CADV11", 
	"CADV11", 
	"CADV11", 

	"UADV09", 
	"UADV09", 
	"UADV09",
	"UADV09", 
	"UADV09",
	"UADV09", 
	"UADV09", 

	"UADV10", 
	"UADV10", 
	"UADV10", 
	"UADV10", 
	"UADV10", 
	"UADV10", 
	"UADV10", 
	"UADV10", 

	"UADV11", 
	"UADV11", 
	"UADV11", 
	"UADV11", 
	"UADV11", 
	"UADV11", 
	"UADV11", 

	# "CHOIR", 
]
COURSE_IDS = [
	'120070',
	'120070',
	'120080',
	'120080',
	'120101',
	'120201',
	'120348',
	'120379',
	'120383',
	'120406',
	'120422', 
	'120503', 
	'120504', 
	'120506', 
	'120510', 
	'120819', 
	'120820', 
	'120822', 
	'120823', 
	'121003', 
	'121347', 
	'121348', 
	'121349', 
	'121350', 
	'121351', 
	'121501', 
	'121517', 
	'121520', 
	'121547', 
	'121568', 
	'121580', 
	'121581', 
	'122010', 
	'122012', 
	'122501', 
	'122581', 
	'122584', 
	'122589', 
	'122590', 
	'122591', 
	'123001', 
	'123002', 
	'123501', 
	'123502', 
	'124002', 
	'124003', 
	'124015', 
	'124501', 
	'124502', 
	'124511', 
	'124521', 
	'124549', 
	'124554', 
	'124559', 
	'124562', 
	'124563', 
	'125001', 
	'125002', 
	'125003', 
	'125005', 
	'125022', 
	'125027', 
	'125502', 
	'125518', 
	'125520', 
	'125601', 
	'125603', 
	'125611', 
	'125613', 
	'125621', 
	'125622', 
	'125624', 
	'126011', 
	'126903', 
	'126926', 
	'126930', 
	'126956', 
	'127011', 
	'127020', 
	'127502', 
	'127503', 
	'127524', 
	'128037', 
	'128503', 
	'128523', 
	'128532', 
	'128567', 
	'128582', 
	'128598', 
	'128600', 
	'128602', 
	'128605', 
	'128614', 
	'128616', 
	'128617', 
	'129024', 
	'129514', 
	'129530', 
	'129531', 
]

KNOWN_VALID = [
	"100370", 
	"101000", 
	"101001", 
	"102000", 
	"103031", 
	"103034", 
	"103041", 
	"103042", 
	"103043", 
	"103044", 
	"104010", 
	"104011", 
	"104012", 
	"104013", 
	"104018", 
	"105001", 
	"105002", 
	"105003", 
	"105011", 
	"105400", 
	"106001", 
	"106002", 
	"106003", 
	"106411", 
	"106413", 
	"106513", 
	"107001", 
	"107002", 
	"107013", 
	"108013", 
	"109001", 
	"109002", 
	"109003", 
	"109013", 
	"109014", 
	"110070", 
	"110080", 
	"110170", 
	"110270", 
	"110370", 
	"111000", 
	"111001", 
	"112010", 
	"113031", 
	"113034", 
	"113041", 
	"113042", 
	"113043", 
	"113044", 
	"114010", 
	"114012", 
	"114014", 
	"114020", 
	"114021", 
	"115001", 
	"115002", 
	"115003", 
	"115004", 
	"115400", 
	"116001", 
	"116002", 
]

electives = []
courses = []
valid_entries = []
for entry in CSVReader ("courses"):
	# course_id = entry ["ID"]
	course_id = entry ["ID"]
	if course_id in ELECTIVE_IDS: electives.append (entry)
	elif course_id in COURSE_IDS: courses.append (entry)
	elif course_id in KNOWN_VALID: valid_entries.append (entry)
fields = entry.keys()


def cross_check(fields, entries, topic): 
	commons = {}
	for field in fields: 
		value = None
		for entry in entries: 
			if value is not None and entry [field] != value: 
				break
			elif value is None: value = entry [field]
		else: commons [field] = value

	for field, value in commons.items(): 
		if all (
			entry [field] != value
			for entry in valid_entries
		): 
			print (f"{field} has a common value for {topic}: {value}")


cross_check (fields, electives, "electives")
cross_check (fields, courses, "courses")
