@echo off

if [%1]==[] goto helpMessage
if "%1"=="/?" goto helpMessage
if "%1"=="-h" goto helpMessage

set build=0
if "%1"=="-b" set build=1
if "%1"=="--build" set build=1

if "%build%"=="1" shift /1

set filename=%1.dart.js
set args=%2 %3 %4 %5 %6 %7 %8 %9
set runCommand=node build\%filename% %args%


if "%build%"=="1" (
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
echo Usage: main [--build ^| -b] filename [args]
echo.
echo build: Use dart2js to rebuild the dart files
echo filename: The name of the dart file to run. The file should be node/{filename}.dart
echo args: The arguments to pass to the built .js file
