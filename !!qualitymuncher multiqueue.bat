@echo off
set version=1.1
title Quality Muncher Multiqueue Edition Version %version%
SET mypath=%~dp0
choice /n /c 1234c /m "Your options for quality are decent (1), bad (2), terrible (3), unbearable (4), and custom (c)."
set customizationquestion=%errorlevel%
if %customizationquestion% == 5 set customizationquestion=c
if %customizationquestion% == c goto custom
for %%a in (%*) do (
     call "%mypath%Quality Muncher.bat" %%a %customizationquestion%
)
exit

:custom
echo\
set /p framerate=What fps do you want it to be rendered at: 
set /p videobr=On a scale from 1 to 10, how bad should the video bitrate be? 1 bad, 10 very very bad: 
set /p audiobr=On a scale from 1 to 10, how bad should the audio bitrate be? 1 bad, 10 very very bad: 
set /p scaleq=On a scale from 1 to 10, how much should the video be shrunk by? 1 none, 10 a lot: 
choice /m "Do you want a detailed file name for the output?"
for %%a in (%*) do (
     call "%mypath%Quality Muncher.bat" %%a %customizationquestion% %framerate% %videobr% %audiobr% %scaleq% %errorlevel%
)