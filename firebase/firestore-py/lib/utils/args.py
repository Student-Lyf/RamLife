import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--color", action=argparse.BooleanOptionalAction, default=True, dest="use_color", help="Whether to use color in console output. Disable color if outputting to a file")
parser.add_argument("-u", "--upload", action="store_true", dest="should_upload", help="Whether to actually upload the results. Omitting implies a dry run.")
parser.add_argument("-v", "--verbose", action="store_true", help="Whether to output verbose messages (messages indicating individual steps).")
parser.add_argument("-d", "--debug", action="store_true", help="Whether to output debug messages (values of all function calls).")
args = parser.parse_args()
if args.debug: 
	with open("debug.log", "w") as file: file.write("")