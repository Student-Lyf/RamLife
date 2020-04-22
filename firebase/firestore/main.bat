@echo off

if [%1]==[] goto helpMessage
if "%1"=="/?" goto helpMessage
if "%1"=="-h" goto helpMessage

set run=0
if "%1"=="-r" set run=1
if "%1"=="--run" set run=1

if "%run%"=="1" shift /1  rem Remove the -r 

set filename=%1.dart.js
set args=%2 %3 %4 %5 %6 %7 %8 %9
set runCommand=node build\%filename% %args%

if "%run%"=="0" (
	webdev build --no-build-web-compilers --output "node:build"
	echo.
	%runCommand%
	title Command Prompt
) else (
	%runCommand%
)

exit /b

:helpMessage
echo.
echo A helper script to compile dart files to Node.js
echo Usage: main [--run ^| -r] filename [args]
echo.
echo run: Run the .js script instead of using dart2js to rebuild the dart files (defaults to build)
echo filename: The name of the dart file to run. The file should be node/{filename}.dart
echo args: The arguments to pass to the built .js file
