@echo off
set version=1.4
title Quality Muncher Multiqueue v%version%
set mypath=%~dp0
set total=0
for %%x in (%*) do Set /A total+=1
set progress=1
choice /n /c 1234CR /m "Your options for quality are decent [1], bad [2], terrible [3], unbearable [4], custom [C], and random [R]."
set customizationquestion=%errorlevel%
setlocal enableextensions enabledelayedexpansion
if %customizationquestion% == 5 set customizationquestion=c
if %customizationquestion% == c goto custom
for %%a in (%*) do (
     title [!progress!/%total%] Quality Muncher Multiqueue v%version%
	 set /a progress=!progress!+1
     call "%mypath%Quality Muncher.bat" %%a %customizationquestion%
)
title [%total%/%total%] Quality Muncher Multiqueue v%version%
ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
exit

:custom
echo\
set /p framerate=What fps do you want it to be rendered at: 
set /p videobr=On a scale from 1 to 10, how bad should the video bitrate be? 1 bad, 10 very very bad: 
set /p audiobr=On a scale from 1 to 10, how bad should the audio bitrate be? 1 bad, 10 very very bad: 
set /p scaleq=On a scale from 1 to 10, how much should the video be shrunk by? 1 none, 10 a lot: 
choice /m "Do you want a detailed file name for the output?"
for %%a in (%*) do (
     title [!progress!/%total%] Quality Muncher Multiqueue v%version%
	 set /a progress=!progress!+1
     call "%mypath%Quality Muncher.bat" %%a %customizationquestion% %framerate% %videobr% %audiobr% %scaleq% %errorlevel%
)
title [%total%/%total%] Quality Muncher Multiqueue v%version%
ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
exit