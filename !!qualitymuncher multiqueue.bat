@echo off
echo Options:
echo Decent (1)
echo Bad (2)
echo Terrible (3)
echo Unbearable (4)
echo Custom (c)
set /p customizationquestion=Please enter an option: 
SET mypath=%~dp0
for %%a in (%*) do (
     call "%mypath%Quality Muncher.bat" %%a %customizationquestion%
)