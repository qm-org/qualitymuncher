@echo off
:: most recent version of this script can always be found at https://github.com/Thqrn/qualitymuncher/blob/main/!!qualitymuncher%20multiqueue.bat
:: made by Frost#5872 for version 1.4.0 of Quality Muncher
:: https://qualitymuncher.lgbt/
set version=1.5
title Quality Muncher Multiqueue v%version%
set mypath=%~dp0
set total=0
for %%x in (%*) do Set /A total+=1
set progress=1
if "%~x1" == ".png" goto imagemunch
if "%~x1" == ".jpg" goto imagemunch
if "%~x1" == ".jpeg" goto imagemunch
if "%~x1" == ".jfif" goto imagemunch
if "%~x1" == ".pjpeg" goto imagemunch
if "%~x1" == ".pjp" goto imagemunch
if "%~x1" == ".gif" goto imagemunch
ffprobe -i %1 -show_streams -select_streams v -loglevel error > %temp%\vstream.txt
set /p vstream=<%temp%\vstream.txt
if exist "%temp%\vstream.txt" (del "%temp%\vstream.txt")
if 1%vstream% == 1 goto novideostream
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

:novideostream
echo [91mSorry, audio files aren't supported with multiqueue yet.[0m
pause
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

:imagemunch
set /p imageq=[93mOn a scale from 1 to 10[0m, how bad should the quality be? 
set /p imagesc=[93mOn a scale from 1 to 10[0m, how much should the image be shrunk by? 
choice /m "Deep fry the image?"
if %errorlevel% == 1 goto fried
setlocal enableextensions enabledelayedexpansion
for %%a in (%*) do (
     title [!progress!/%total%] Quality Muncher Multiqueue v%version%
	 set /a progress=!progress!+1
     call "%mypath%Quality Muncher.bat" %%a N %imageq% %imagesc%
)
title [%total%/%total%] Quality Muncher Multiqueue v%version%
ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
exit

:fried
set /p level=How fried do you want the images/gifs, [93mfrom 1-10[0m: 
setlocal enableextensions enabledelayedexpansion
for %%a in (%*) do (
     title [!progress!/%total%] Quality Muncher Multiqueue v%version%
	 set /a progress=!progress!+1
     call "%mypath%Quality Muncher.bat" %%a Y %imageq% %imagesc% %level%
)
title [%total%/%total%] Quality Muncher Multiqueue v%version%
ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
exit