"""
Run this script whenever new data is available.
Splits it from a .xlsx Workbook to .csv files

"""

from openpyxl import load_workbook
from pathlib import Path
from csv import writer

FILENAMES = {
	"RG_Course": "courses",
	"RG_Section": "section",
	"RG_Sect_Sched": "section_schedule",
	"Student": "students",
	"Faculty": "faculty",
}

data_dir = Path.cwd().parent / "data"

def convert_to_csv(sheet, filename): 
	with open(filename, "w", newline = "") as file: 
		csv = writer(file)
		for row in sheet.rows: 
			csv.writerow([cell.value for cell in row])

if __name__ == "__main__": 
	workbook = load_workbook(data_dir / "data.xlsx")
	for sheet_name, filename in FILENAMES.items():
		convert_to_csv(
			workbook [sheet_name], 
			data_dir / f"{filename}.csv"
		)
