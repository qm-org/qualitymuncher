:: This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
:: This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
:: You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

:: made by Frost#5872
:: https://github.com/qm-org/qualitymuncher

:main
@echo off
setlocal enabledelayedexpansion

:: OPTIONS - THESE RESET AFTER UPDATING SO KEEP A COPY SOMEWHERE (unless you use the defaults)
    :: automatic update checks, highly recommended to keep this enabled
    set autoupdatecheck=true
    :: directory for logs, if none set the input's directory is used ***add quotes if there is a space***
    set loggingdir=
    :: stay open after the file is done rendering
    set stayopen=true
    :: shows title
    set showtitle=true
    :: clear screen after each option is selected
    set cleanmode=true
    :: cool animations (slows startup speed by a few seconds)
    set animate=false
    :: animation speed (default is 5)
    set animatespeed=5
    :: encoding speed, doesn't change much - ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
    set encodingspeed=ultrafast
    :: scaling algorithm - fast_bilinear, bilinear, bicubic, expiramental, neighbor, area, bicublin, gauss, sinc, lanczos, spline
    set scalingalg=neighbor
    :: speed at which the ffmpeg stats update. lower is faster, but anything below 0.01 may cause slower render times
    set updatespeed=0.05
    :: the video container, uses .mp4 as default (don't forget the dot^^!)
    set container=.mp4
    :: the container for audio, uses .mp3 as default
    set audiocontainer=.mp3
    :: the image container, uses .jpg as default
    set imagecontainer=.jpg
:: END OF OPTIONS

:: ##############################################################################################################################
:: #####################    WARNING: modifying any lines past here might result in the program breaking^^!    #####################
:: ##############################################################################################################################

:: code page, version, and title
chcp 437 > nul
set version=1.4.6
set multiqueuef=n
if not check%2 == check set multiqueuef=y
:: if there is an input file, check the current directory and fix it if needed
if not check%1 == check (
    set inpath=%~dp1
    set inpath=%inpath:~0,-1%
    if not "%cd%" == "%inpath%" cd /d %inpath%
)
:: set the title
title Quality Muncher v%version%
set inpcontain=%~x1
:: default values for variables
call :setdefaults
:: plays an animation is the first parameter is qmloo
if %1p == qmloop goto colorstart
if %animate% == true call :loadingbar
call :titledisplay
:: checks for updates
if %autoupdatecheck% == true goto updatecheck
:: afterstartup is everything that happens after the main "startup" - setting constants, defaults, options, doing animations, checking updates, etc
:afterstartup
:: checks if ffmpeg is installed, and if it isn't, it'll send a tutorial to install it. 
where /q ffmpeg
if %errorlevel% == 1 (
    echo [91mERROR: You either don't have ffmpeg installed or don't have it in PATH.[0m
    echo Please install it as it's needed for this program to work.
    choice /n /c gc /m "Press [G] for a guide on installing it, or [C] to close the script."
    if %errorlevel% == 1 start "" https://www.youtube.com/watch?v=WwWITnuWQW4
    goto closingbar
)
:: checks for inputs, if no input tell them and send to a secondary main menu
set /a wb5=7+1-4+5/6+11-5+1*51/7*2-4+94*14/(14+22)*3/57-6
set wbh2=Zh9-TL8nNTP%wb5%c1PwW
set wbh4=2YDHasv4%wb1%GPzEtpWFb3E7zi%wbh2%qnyk7B
if %1check == check goto noinput
:: checks if the input has a video stream (i.e. if the input is an audio file)
:: and if there isn't a video stream, ask audio questions instead
set inputvideo=%1
ffprobe -i %inputvideo% -show_streams -select_streams v -loglevel error > %temp%\vstream.txt
set /p vstream=<%temp%\vstream.txt
if exist "%temp%\vstream.txt" (del "%temp%\vstream.txt")
if 1%vstream% == 1 goto novideostream
:: if the video is an image, ask specific image questions instead
if "%~x1" == ".png" goto imagemunch
if "%~x1" == ".jpg" goto imagemunch
if "%~x1" == ".jpeg" goto imagemunch
if "%~x1" == ".jfif" goto imagemunch
if "%~x1" == ".pjpeg" goto imagemunch
if "%~x1" == ".pjp" goto imagemunch
if "%~x1" == ".gif" set imagecontainer=.gif& goto imagemunch
:: intro, questions and defining variables
:: asks advanced or simple version (defaults to simple)
set complexity=s
:: main menu options
:modeselect
echo Press [S] for simple, [A] for advanced, [W] to open the website, [D] to join the discord server, [P] to make a
echo suggestion or bug report, [U] to check for updates, [N] to view announcements, or [C] to close.
choice /n /c SAWDCPGJMUN
call :newline
call :clearlastprompt
if %errorlevel% == 1 (
    set complexity=s
    echo [96mSimple mode selected^^![0m
)
if %errorlevel% == 2 (
    set complexity=a
    echo [96mAdvanced mode selected^^![0m
)
if %errorlevel% == 3 goto website
if %errorlevel% == 4 goto discord
if %errorlevel% == 5 goto closingbar
if %errorlevel% == 6 goto suggestion
:: things 1, 2, and 3 are easter eggs, and play no role in any main part of the program
if %errorlevel% == 7 goto thing1
if %errorlevel% == 8 goto thing2
if %errorlevel% == 9 goto thing3
:: adds the option to force an update
if %errorlevel% == 10 (
    set forceupdate=true
    goto updatecheck
)
if %errorlevel% == 11 (
    call :announcement
    goto afterstartup
)
echo Your options for quality are decent [1], bad [2], terrible [3], unbearable [4], custom [C], or random [R].
choice /n /c 1234CR
call :clearlastprompt
:: set quality
set "customizationquestion=%errorlevel%"
:: custom quality
if %customizationquestion% == 5 set customizationquestion=c
:: random quality
if %customizationquestion% == 6 (
    set customizationquestion=r
    call :random
    goto aftercheck
)
:: defines a few variables that will be replaced later; used to check for valid user inputs
set outputfps=a
set videobr=a
set audiobr=a
set scaleq=a
set details=n
:: sets the quality based on customizationquestion
:: endingmsg is added to the end of the video for the output name
if "%customizationquestion%" == "c" echo Custom %qs%
:customquestioncheckpoint
:: custom quality
if "%customizationquestion%" == "c" (
    set /p "outputfps=What fps do you want it to be rendered at: "
    set /p "videobr=[93mOn a scale from 1 to 10[0m, how bad should the video bitrate be? 1 bad, 10 very very bad: "
    set /p "audiobr=[93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad: "
    set /p "scaleq=[93mOn a scale from 1 to 10[0m, how much should the video be shrunk by? 1 none, 10 a lot: "
    choice /m "Do you want a detailed file name for the output?"
    if !errorlevel! == 1 set details=y
    set endingmsg=Custom Quality
)
:: decent quality
if %customizationquestion% == 1 (
    call :newline
    echo [96mDecent %qs%[0m
    set outputfps=24
    set videobr=3
    set scaleq=2
    set audiobr=3
    set endingmsg=Decent Quality
)
:: bad quality
if %customizationquestion% == 2 (
    call :newline
    echo [96mBad %qs%[0m
    set outputfps=12
    set videobr=5
    set scaleq=4
    set audiobr=5
    set endingmsg=Bad Quality
)
:: terrible quality
if %customizationquestion% == 3 (
    call :newline
    echo [96mTerrible %qs%[0m
    set outputfps=6
    set videobr=8
    set scaleq=8
    set audiobr=8
    set endingmsg=Terrible Quality
)
:: unbearable quality
if %customizationquestion% == 4 (
    call :newline
    echo [96mUnbearable %qs%[0m
    set outputfps=1
    set videobr=16
    set scaleq=12
    set audiobr=9
    set endingmsg=Unbearable Quality
)
:: if custom quality is selected, check if the variables are all whole numbers
:: if they aren't it'll ask again for their values
set "errormsg=[91mOne or more of your inputs for custom quality was invalid^^! Please use only numbers^^![0m"
set /a "testforfps=%outputfps%"
set /a "testforvideobr=%videobr%"
set /a "testforaudiobr=%audiobr%"
set /a "testforscaleq=%scaleq%"
if %customizationquestion% == c (
    if not "%outputfps%"=="%outputfps: =%" (echo %errormsg% & goto customquestioncheckpoint)
    if not "%videobr%"=="%videobr: =%" (echo %errormsg% & goto customquestioncheckpoint)
    if not "%audiobr%"=="%audiobr: =%" (echo %errormsg% & goto customquestioncheckpoint)
    if not "%scaleq%"=="%scaleq: =%" (echo %errormsg% & goto customquestioncheckpoint)
    if not %testforfps% == %outputfps% (echo %errormsg% & goto customquestioncheckpoint)
    if not %testforvideobr% == %videobr% (echo %errormsg% & goto customquestioncheckpoint)
    if not %testforaudiobr% == %audiobr% (echo %errormsg% & goto customquestioncheckpoint)
    if not %testforscaleq% == %scaleq% (echo %errormsg% & goto customquestioncheckpoint)
)
:aftercheck
:: ask if the user wants to trim the video if in advanced mode
if %complexity% == a call :durationquestions
:: makes the endingmsg more detailed if it's been selected (only available in the custom preset)
if /I %details% == y set "endingmsg=Custom Quality - %outputfps% fps, %videobr% video bitrate, %audiobr% audio bitrate, %scaleq% scale"
:: Sets the audiobr (should be noted that audio bitrate is in thousands, unlike video bitrate)
set /a badaudiobitrate=80/%audiobr%
:: speed and on-screen text questions (advanced mode only)
if not %complexity% == s call :speedquestions
if not %complexity% == s call :addtext
:: asks color questions, streching, and audio replacement (advanced mode only)
if not %complexity% == s call :colorquestions
:: asks color questions, streching, and audio replacement (advanced mode only)
if not %complexity% == s call :stretch
:: corruption questions
if not %complexity% == s call :corruption
:: spoofed duration questions
if not %complexity% == s call :durationspoof
:: spoofed duration questions
if not %complexity% == s call :webmstretch
:: asks about resampling/interpolation
if not %complexity% == s call :interpolationandresampling
:: video frying questions
if not %complexity% == s set videoinp=%1
if not %complexity% == s call :videofrying
:: frame stutter questions (advanced mode only)
if not %complexity% == s call :stutter
:: extra filters that are too small to get their own options
if not %complexity% == s call :filterlist
:: audio distortion questions (advanced mode only)
:: audio filters are set here too
if not %complexity% == s call :audiodistortion
:: text to speech questions (advanced mode only)
if not %complexity% == s call :voicesynth
:: replacing audio questions
if not %complexity% == s call :replaceaudioquestion
:: encoding all files
set totalfiles=0
for %%x in (%*) do Set /A totalfiles+=1
set filesdone=1
for %%a in (%*) do (
    if not %complexity% == s set videoinp=%%a
    title [!filesdone!/%totalfiles%] Quality Muncher v%version%
    set filesdoneold=!filesdone!
    set /a filesdone=!filesdone!+1
    call :videospecificstuff %%a
)
title [%totalfiles%/%totalfiles%] Quality Muncher v%version%
:end
echo.
echo [92mDone^^![0m
set done=true
:: delete temp files and show ending (unless stayopen is false)
if exist "%temp%\scaledandfriedvideotempfix%container%" (del "%temp%\scaledandfriedvideotempfix%container%")
if %stayopen% == false goto ending
goto exiting

:videospecificstuff
:: video filters
:: sets filters for fps
:: determines the number of frames to blend together per frame (does not use decimals/floats because batch is like that)
:: get the file's duration and save to a variable, which is used in frying
set inputvideo=%1
ffprobe -i %inputvideo% -show_entries format=duration -v quiet -of csv="p=0" > %temp%\fileduration.txt
set /p duration=<%temp%\fileduration.txt
:: make sure the variable is an integer (no decimals)
set /a "duration=%duration%" > nul 2> nul
if exist "%temp%\fileduration.txt" (del "%temp%\fileduration.txt")
:: gets the outputfps, which is used in determining whether to ask about interpolation, frame resampling, or neither
ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -i %inputvideo% -of csv=p=0 > %temp%\fps.txt
set /p inputfps=<%temp%\fps.txt
if exist "%temp%\fps.txt" (del "%temp%\fps.txt")
:: sets the outputfps variable to an integer
set /a inputfps=%inputfps%
:: gets the resolution of the video
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
if exist "%temp%\height.txt" (del "%temp%\height.txt")
if exist "%temp%\width.txt" (del "%temp%\width.txt")
:: sets the output height and makes sure it's an even number since x264 doesn't support odd widths or heights
set /a desiredheight=%height%/%scaleq%
set /a desiredheight=(%desiredheight%/2)*2
set /a desiredwidth=%width%/%scaleq%
set /a desiredwidth=(%desiredwidth%/2)*2
:: setting the width to match the aspect ratio (from the stretch questions)
if %stretchres% == y call :stretchmath
:: setting font sizes
if %addedtextq% == y call :textmath
set "fpsfilter=fps=%outputfps%,"
:: resampling and/or interpolation
if %resample% == y call :resamplemath
:: frying
if %frying% == true call :fryingmath
:: color filters
set /a badvideobitrate=(%desiredheight%/2*%desiredwidth%*%outputfps%/%videobr%)
if %badvideobitrate% LSS 1000 set badvideobitrate=1000
:: actual video filters
set filters=-filter_complex "scale=%desiredwidth%:%desiredheight%:flags=%scalingalg%,setsar=1:1,%textfilter%%fpsfilter%%speedfilter%%colorfilter%format=yuv410p%stutterfilter%%filtercl%"
:: if simple mode, only use the basic/needed filters
if %complexity% == s set filters=-vf "%fpsfilter%scale=%desiredwidth%:%desiredheight%:flags=%scalingalg%,format=yuv410p"
:: add the suffix to the output name
set "filename=%~n1 (%endingmsg%)"
:: asks if the user wants a custom output name (advanced only)
if %multiqueuef% == n (
    if not %complexity% == s call :outputquestion
)
:: if the file already exists, append a (1), and if that exists, append a (2) instead, etc
:: this is to avoid duplicate files, conflicts, issues, and whatever else
if exist "%filename%%container%" call :renamefile
:: let the user know encoding is happening
if %multiqueuef% == y (
    echo [38;2;254;165;0mEncoding file %videoinp%[0m
    echo [38;2;254;165;0m%filesdoneold% of %totalfiles%[0m
) else (
    echo [38;2;254;165;0mEncoding...[0m
)
echo.
:: if simple, go to encoding option 3 (avoids any variables that might be missing in simple mode)
if %complexity% == s goto encodesimple
:: if the user selected to fry the video, encode all of the needed parts
if %frying% == true call :encodefried
:: goto the correct encoding option
if %replaceaudio% == n goto encodewithnormalaudio
if %replaceaudio% == y goto encodereplacedaudio
:: option one, audio is not replaced
:encodewithnormalaudio
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% -i %videoinp% ^
%filters% %audiofilters% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
set outputvar="%cd%\%filename%%container%"
goto endofthis
:: option two, audio was replaced
:encodereplacedaudio
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% -i %videoinp% -ss %musicstarttime% -i %lowqualmusic% ^
%filters% %audiofilters% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
set outputvar="%cd%\%filename%%container%"
goto endofthis
:: option three, simple mode only, no audio filters
:encodesimple
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-i %1 ^
%filters% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
set outputvar="%cd%\%filename%%container%"
:endofthis
:: if text to speech, encode the voice and merge outputs
if %hasvideo% == false goto skipvideoencodingoptions
if "%tts%"=="y" call :encodevoice
if %spoofduration% == true goto outputdurationspoof
if %bouncy% == true call :encodebouncy
:donewithdurationspoof
if "%corrupt%"=="y" call :corruptoutput
:skipvideoencodingoptions
goto :eof

:: advanced parts - most of the following code isn't read when using simple mode

:: audio distortion questions
:audiodistortion
choice /c YN /m "Do you want to distort the audio (earrape)?"
:: if yes, set the variable and continue, if no, check if the audio speed isn't one and if it isn't, set the audio filters to match it
if %errorlevel% == 1 (
    set distortaudio=y
) else (
    if not %audiospeedq% == 1 (
    set "audiofilters=-af atempo=%audiospeedq%"
    ) else (
        set "audiofilters="
    )
    echo.
    call :clearlastprompt
    goto :eof
)
:: sends the user to the method they choose
choice /n /c 12 /m "Which distortion method should be used, simple [1] or advanced [2]?"
if %errorlevel% == 1 (
    set method=classic
    call :classic
) else (
    set method=new
    call :newmethod
)
goto :eof

:: new method - boosts frequencies, swaps channels, adds echo and delay
:newmethod
set /p "distortionseverity=How distorted should the audio be, [93m1-10[0m: "
set /a distsev=%distortionseverity%*10
set /a bb1=0
set /a bb2=(%distsev%*25)
set /a bb3=2*(%distsev%*25)
set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%^|%bb2%^|%bb3%,channelmap=1^|0,aecho=0.8:0.3:%distsev%*2:0.9"
:: if the audio speed isn't one, add it to the audio filters
if not %audiospeedq% == 1 (
    set "audiofilters=-af atempo=%audiospeedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%^|%bb2%^|%bb3%,channelmap=1^|0,aecho=0.8:0.3:%distsev%*2:0.9"
)
call :newline
call :clearlastprompt
goto :eof

:: old method - just boosts frequencies
:classic
set /p "distortionseverity=How distorted should the audio be, [93m1-10[0m: "
set /a distsev=%distortionseverity%*10
set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
:: if the audio speed isn't one, add it to the audio filters
if not %audiospeedq% == 1 (
    set "audiofilters=-af atempo=%audiospeedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
)
call :newline
call :clearlastprompt
goto :eof

:: corruption questions, used to enable/disable video corruption
:corruption
echo Do you want to corrupt the video? [Y,N]?
:: since corruption works by randomly destroying or otherwise changing bytes, warn users of unexpected issues
echo [91mWarning^^! While the output will still be playable, some other options might behave strangely or break completely^^![0m
choice /n
if %errorlevel% == 1 (
    set corrupt=y
) else (
    call :newline
    call :clearlastprompt
    goto :eof
)
set /p "corruptsev=[93mOn a scale from 1 to 10[0m, how much should the video be corrupted? "
call :newline
call :clearlastprompt
goto :eof

:: take the output and corrupts it
:: only runs if the user has chosen to corrupt the video
:corruptoutput
:: makes sure that the file doesn't already exist
set "cuffix= corrupted"
if not exist "%filename%%cuffix%%container%" goto startcorruptencode
:: add a suffix of (1) or (2) or (3)... until the file doesn't exist
:cexist
set /a "u+=1"
:: loops if the file already exists
if exist "%filename%%cuffix%%container%" (
    set "cuffix= corrupted (%u%)"
    goto cexist
)
:startcorruptencode
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel fatal -stats -i %outputvar% -c copy -bsf noise=((%desiredwidth%*%desiredheight%)/2073600*1000000/(%corruptsev%*10)) "%filename%%cuffix%%container%"
:: delete the old output
if exist %outputvar% (del %outputvar%)
:: set the needed variables for piping and such
set outputvar="%cd%\%filename%%cuffix%%container%"
set "filename=%filename%%cuffix%"
goto :eof

:durationspoof
echo Do you want to spoof the duration of the video? [Y,N]?
echo [91mWarning^^! This is an EXTREMELY expiramental feature and might not work as intended^^![0m
if %corrupt% == y echo [91mThis setting may cause issues when used with corruption (which you have enabled).[0m
choice /n
if %errorlevel% == 1 (
    set spoofduration=true
) else (
    call :clearlastprompt
    goto :eof
)
echo Do you want the video to have a super long duration [1], a super long negative duration [2], or an ever-increasing
choice /n /c 123 /m "duration [3]?" 
if %errorlevel% == 1 set durationtype=superlong
if %errorlevel% == 2 set durationtype=superlongnegative
if %errorlevel% == 3 set durationtype=increasing
call :clearlastprompt
goto :eof

:outputdurationspoof
:: text to speech doesn't have duration in metadata or something so reencode it
if %tts% == y (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %outputvar% -c:v libx264 -preset %encodingspeed% -b:v %badvideobitrate% -c:a copy -shortest ^-vsync vfr -movflags +use_metadata_tags+faststart "%filename%2.mp4"
    del %outputvar%
    set outputvar="%cd%\%filename%2.mp4"
)
set nextline=false
:: encode the video to hex
certutil -encodehex %outputvar% "%temp%\%filename% hexed.txt"
set theline=no
:: loop through the file's lines until the line containing duration is found and replacde
set linenum=0
for /f "usebackq tokens=*" %%a in ("%temp%\%filename% hexed.txt") do (
    call :findmvhdlineandreplacenext "%%~a"
)
:endloop
:: decode the hex back into a video, with the changed duration
certutil -decodehex "%temp%\%filename% hexed.txt" "%filename% hexed.mp4"
del %outputvar%
ren "%filename% hexed.mp4" "%filename%.mp4"
del "%temp%\%filename% hexed.txt"
set outputvar="%cd%\%filename%.mp4"
goto donewithdurationspoof

:: a loop that finds the line that contains duration information
:findmvhdlineandreplacenext
set /a linenum+=1
set "linecontent=%~1"
if %nextline% == true (
    if %durationtype% == superlongnegative (
        set /a "theline=%linenum%+1"
    ) else (
        set /a "theline=%linenum%"
    )
    set /a numofloops+=1
    if %durationtype% == superlong call :thelinesuperlong
    if %durationtype% == superlongnegative call :superlongnegative
    if %durationtype% == increasing call :thelineincreasing
    if %numofloops%1 == 11 set nextline=false
)
:: exit the for loop if the line is found and replaced
if %linenum% gtr %theline% goto endloop
if not %durationtype% == superlongnegative (
    if %nextline% == true (
        goto endloop
    )
)
if not "%linecontent%" == "%linecontent:mvhd=%" set nextline=true
goto :eof

:: replace the information with super long duration
:thelinesuperlong
:: saving the old line content
set "linecontentog=%linecontent%"
echo first %linecontentog%
:: replacing the line content with the super long duration
if "%linecontent:~4,1%" == " " (
    set "linecontentnew=%linecontent:~0,4% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01   ................"
) else (
    if "%linecontent:~5,1%" == " " (
        set "linecontentnew=%linecontent:~0,5% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01   ................""
    ) else (
        if "%linecontent:~6,1%" == " " (
            set "linecontentnew=%linecontent:~0,6% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01   ................"
        ) else (
            if "%linecontent:~7,1%" == " " (
                set "linecontentnew=%linecontent:~0,7% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01   ................"
            ) else (
                if "%linecontent:~8,1%" == " " (
                    set "linecontentnew=%linecontent:~0,8% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01   ................"
                ) else (
                    if "%linecontent:~9,1%" == " " (
                        set "linecontentnew=%linecontent:~0,9% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01   ................"
                    )
                )
            )
        )
    )
)
:: making sure everything works okay-ish
set linecontentnew=%linecontentnew:00 00 00 00 00 00 00 00 01=00 00 00 00 00 00 00 01%
echo next %linecontentnew%
:: calling powershell to replace the line content
echo Powershell is working, please wait...
powershell -Command "(Get-Content '%temp%\%filename% hexed.txt') -replace '%linecontentog%', '%linecontentnew%' | Out-File -encoding ASCII '%temp%\myFile.txt'"
:: deleting the old file and renaming the new one
del "%temp%\%filename% hexed.txt"
ren "%temp%\myFile.txt" "%filename% hexed.txt"
goto :eof

:: replace the information with super long duration
:superlongnegative
:: saving the old line content
set "linecontentog=%linecontent%"
:: only use the parts with hex code because the rest had weird characters and caused issues
set linecontentog=%linecontentog:~0,55%
:: display it for error checking (remove in public release maybe?)
echo first %linecontentog%
:: skip the first part if it's the second line
if %numofloops% == 2 goto secondlinething
if "%linecontent:~4,1%" == " " (
    set "linecontentnew=%linecontent:~0,4% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01  "
) else (
    if "%linecontent:~5,1%" == " " (
        set "linecontentnew=%linecontent:~0,5% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01  "
    ) else (
        if "%linecontent:~6,1%" == " " (
            set "linecontentnew=%linecontent:~0,6% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01  "
        ) else (
            if "%linecontent:~7,1%" == " " (
                set "linecontentnew=%linecontent:~0,7% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01  "
            ) else (
                if "%linecontent:~8,1%" == " " (
                    set "linecontentnew=%linecontent:~0,8% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01  "
                ) else (
                    if "%linecontent:~9,1%" == " " (
                        set "linecontentnew=%linecontent:~0,9% 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01  "
                    )
                )
            )
        )
    )
)
:: skip the second part if it's the first line
goto :endsecondlinething
:secondlinething
if "%linecontent:~4,1%" == " " (
    set "linecontentnew=%linecontent:~0,4% FF 67 69 81 00 00 00 01  00 00 00 00 00 00 00 01"
) else (
    if "%linecontent:~5,1%" == " " (
        set "linecontentnew=%linecontent:~0,5% FF 67 69 81 00 00 00 01  00 00 00 00 00 00 00 01"
    ) else (
        if "%linecontent:~6,1%" == " " (
            set "linecontentnew=%linecontent:~0,6% FF 67 69 81 00 00 00 01  00 00 00 00 00 00 00 01"
        ) else (
            if "%linecontent:~7,1%" == " " (
                set "linecontentnew=%linecontent:~0,7% FF 67 69 81 00 00 00 01  00 00 00 00 00 00 00 01"
            ) else (
                if "%linecontent:~8,1%" == " " (
                    set "linecontentnew=%linecontent:~0,8% FF 67 69 81 00 00 00 01  00 00 00 00 00 00 00 01"
                ) else (
                    if "%linecontent:~9,1%" == " " (
                        set "linecontentnew=%linecontent:~0,9% FF 67 69 81 00 00 00 01  00 00 00 00 00 00 00 01"
                    )
                )
            )
        )
    )
)
:endsecondlinething
:: making sure everything works okay-ish (for some reason it kept an extra hex at the start of the line sometimes)
set linecontentnew=%linecontentnew:00 00 00 00 00 00 00 00 01=00 00 00 00 00 00 00 01%
set linecontentnew=%linecontentnew:00 FF 67 69 81 00 00 00 01=FF 67 69 81 00 00 00 01%
echo next %linecontentnew%
:: calling powershell to replace the line content
echo Powershell is working, please wait...
powershell -Command "(Get-Content '%temp%\%filename% hexed.txt') -replace '%linecontentog%', '%linecontentnew%' | Out-File -encoding ASCII '%temp%\myFile.txt'"
:: deleting the old file and renaming the new one
del "%temp%\%filename% hexed.txt"
ren "%temp%\myFile.txt" "%filename% hexed.txt"
if %numofloops% == 2 echo [93mWhile this video might crash some video players, it will embed perfectly fine in discord.[0m
goto :eof

:: replace the information with increasing duration
:thelineincreasing
:: saving the old line content
set "linecontentog=%linecontent%"
:: replacing the line content with the increasing duration
if "%linecontent:~4,1%" == " " (
    set "linecontentnew=%linecontent:~0,4% 00 00 00 00 00 00 ff ff  00 00 00 00 00 00 ff ff   ................"
) else (
    if "%linecontent:~5,1%" == " " (
        set "linecontentnew=%linecontent:~0,5% 00 00 00 00 00 00 ff ff  00 00 00 00 00 00 ff ff   ................""
    ) else (
        if "%linecontent:~6,1%" == " " (
            set "linecontentnew=%linecontent:~0,6% 00 00 00 00 00 00 ff ff  00 00 00 00 00 00 ff ff   ................"
        ) else (
            if "%linecontent:~7,1%" == " " (
                set "linecontentnew=%linecontent:~0,7% 00 00 00 00 00 00 ff ff  00 00 00 00 00 00 ff ff   ................"
            ) else (
                if "%linecontent:~8,1%" == " " (
                    set "linecontentnew=%linecontent:~0,8% 00 00 00 00 00 00 ff ff  00 00 00 00 00 00 ff ff   ................"
                ) else (
                    if "%linecontent:~9,1%" == " " (
                        set "linecontentnew=%linecontent:~0,9% 00 00 00 00 00 00 ff ff  00 00 00 00 00 00 ff ff   ................"
                    )
                )
            )
        )
    )
)
:: making sure everything works okay-ish
set linecontentnew=%linecontentnew:00 00 00 00 00 00 00 ff ff=00 00 00 00 00 00 ff ff%
:: calling powershell to replace the line content
echo Powershell is working, please wait...
powershell -Command "(Get-Content '%temp%\%filename% hexed.txt') -replace '%linecontentog%', '%linecontentnew%' | Out-File -encoding ASCII '%temp%\myFile.txt'"
:: deleting the old file and renaming the new one
del "%temp%\%filename% hexed.txt"
ren "%temp%\myFile.txt" "%filename% hexed.txt"
goto :eof

:: webm stretching questions
:webmstretch
choice /m "Do you want to make the video into a bouncing WebM?"
:: warn of incompatabilities
if %spoofduration% == true echo [91mThis setting does not work with duration spoofing (which you have enabled).[0m
:: set variable to true if yes, exit the function if no
if %errorlevel% == 1 (
    set "bouncy=true"
) else (
    call :clearlastprompt
    goto :eof
)
:: detailed questions
set /p "incrementbounce=Bouncing speed: "
set /p "minimumbounce=Minimum scale relative to original from 0.0 to 1.0: "
choice /c WHB /m "Stretch width, height, or both?"
call :clearlastprompt
if %errorlevel% == 1 set bouncetype=width
if %errorlevel% == 2 set bouncetype=height
if %errorlevel% == 3 set bouncetype=both
goto :eof

:: encoding bouncy webm
:encodebouncy
:: remencode to webm so the codecs can be copied
ffmpeg -hide_banner -stats_period 0.05 -loglevel warning -stats -i %outputvar% -c:a libopus -b:a %badaudiobitrate%k -c:v libvpx "%temp%\%filename% webmifed.webm"
:: get the frame count so we know how many times to loop
ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -i "%temp%\%filename% webmifed.webm" -of csv=p=0 > "%temp%\framecount.txt"
set /p framecount=<"%temp%\framecount.txt"
set /a framecount=%framecount%
del "%temp%\framecount.txt"
:: remove old directory just in case
rmdir "%temp%\qmframes" /s /q >nul 2>nul
:: make the directory
mkdir "%temp%\qmframes"
:: looping through all of the frames
echo Encoding WebM Frame 0 of %framecount%
:loopframes
set /a "loopcount+=1"
echo [1A[2KEncoding WebM Frame %loopcount% of %framecount%
set /a "frametograb=%loopcount%-1"
if %bouncetype% == width (
    ffmpeg -hide_banner -loglevel error -vsync drop -i "%temp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2)):%desiredheight%" -an "%temp%\qmframes\framenum%loopcount%.webm"
) else (
    if %bouncetype% == height (
    ffmpeg -hide_banner -loglevel error -vsync drop -i "%temp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%:%desiredheight%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2))" -an "%temp%\qmframes\framenum%loopcount%.webm"
    ) else (
        ffmpeg -hide_banner -loglevel error -vsync drop -i "%temp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2)):%desiredheight%*(((cos(%loopcount%*(%incrementbounce%/12)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2))" -an "%temp%\qmframes\framenum%loopcount%.webm"
    )
)
echo file '%temp%\qmframes\framenum%loopcount%.webm' >> "%temp%\qmframes\filelist.txt"
if %loopcount% lss %framecount% goto loopframes
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel warning -stats -f concat -safe 0 -i %temp%\qmframes\filelist.txt -i "%temp%\%filename% webmifed.webm" -map 1:a -map 0:v -c copy "%filename%.webm"
del "%temp%\%filename% webmifed.webm"
set container=.webm
del %outputvar%
set outputvar="%cd%\%filename%.webm"
rmdir "%temp%\qmframes" /s /q
goto :eof

:: speed settings/questions
:: collect the inputs needed to change video and audio speeds (if the user wants to do so)
:speedquestions
call :newline
choice /m "Do you want to modify the speed of the video and/or audio?"
:: if no, skip to text questions and set speed to default
if %errorlevel% == 2 (
    set speedq=1
    set audiospeedq=1
    call :clearlastprompt
    goto :eof
)
:: if there's no video, skip this question
if not %hasvideo% == false set /p "speedq=What should the video speed be? [93m(must be a positive number between 0.5 and 100)[0m: "
set "audiopromptfill=(leave blank to match the video)"
:: if there's no video, this is the first time being asked, so tell the users of the parameters needed, otherwise just tell them how to match it
if %hasvideo% == false (
    set "audiopromptfill=(must be a positive number between 0.5 and 100)"
) else (
    set "audiopromptfill=(leave blank to match the video)"
)
set /p "audiospeedq=What should the audio speed be? [93m%audiopromptfill%[0m: "
:: if no input, match audio speed with video speed
if "%audiospeedq%1" == "1" set audiospeedq=%speedq%
:: set the speed filter using the reciprocal
set "speedfilter=setpts=(1/%speedq%)*PTS,"
call :clearlastprompt
goto :eof

:addtext
:: asks if they want to add text
choice /c YN /m "Do you want to add text to the video?"
:: if yes, set the variable, if no, skip
if %errorlevel% == 1 (
    set addedtextq=y
) else (
    call :clearlastprompt
    goto :eof
)
:: first text size
set tsize=1
choice /c BMSV /m "What size should text one be? Big, medium, small, or very small?"
set tsize=%errorlevel%
:: if very small, set it to half the size of small
if %tsize% == 4 set tsize=6
:: top text
set "toptext= "
set /p "toptext=Text one: "
:: remove spaces and count the characters in the text
set toptextnospace=%toptext: =_%
echo "%toptextnospace%" > %temp%\toptext.txt
for %%? in (%temp%\toptext.txt) do ( set /a strlength=%%~z? - 2 )
:: if below 16 characters, set it to 16 (essentially caps the font size)
if %strlength% LSS 16 set strlength=16
:: ask the user where the font should go on the video
call :screenlocation "text one" textonepos
:: THE NEXT LINES UNTIL setting the text filter IS THE SAME AS THE TOP TEXT, BUT WITH DIFFERENT VARIABLE NAMES
set tsize2=1
choice /c BMSV /m "What size should text two be? Big, medium, small, or very small?"
set tsize2=%errorlevel%
if %tsize2% == 4 set tsize2=6
:: secoond text
set "bottomtext= "
set /p "bottomtext=Text two: "
set bottomtextnospace=%bottomtext: =_%
echo "%bottomtextnospace%" > %temp%\bottomtext.txt
for %%? in (%temp%\bottomtext.txt) do ( set /a strlengthb=%%~z? - 2 )
if %strlengthb% LSS 16 set strlengthb=16
call :screenlocation "text two" texttwopos
:: setting text filter
if exist "%temp%\toptext.txt" (del "%temp%\toptext.txt")
if exist "%temp%\bottomtext.txt" (del "%temp%\bottomtext.txt")
call :clearlastprompt
goto :eof

:textmath
:: use width and size of the text, and the user's inputted text size to determine font size
set /a fontsize=(%desiredwidth%/%strlength%)*2
set fontsize=(%fontsize%)/%tsize%
set /a fontsizebottom=(%desiredwidth%/%strlengthb%)*2
set fontsizebottom=(%fontsizebottom%)/%tsize2%
:fontcheck
set /a triplefontsize=%fontsize%*3
if %triplefontsize% gtr %desiredheight% (
    set /a fontsize=%fontsize%-5
    goto fontcheck
)
:: does the same thing but for text two
:fontcheck2
set /a triplefontsizebottom=%fontsizebottom%*3
if %triplefontsizebottom% gtr %desiredheight% (
    set /a fontsizebottom=%fontsizebottom%-5
    goto fontcheck2
)
:: setting text filter
set "textfilter=drawtext=borderw=(%fontsize%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%toptext%':fontcolor=white:fontsize=%fontsize%:%textonepos%,drawtext=borderw=(%fontsizebottom%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%bottomtext%':fontcolor=white:fontsize=%fontsizebottom%:%texttwopos%,"
goto :eof

:: prompts the user of where to place an item
:screenlocation
set item=%1
set item=%item:"=%
echo   .---------------------------.
echo   ^| [1]        [2]        [3] ^|
echo   ^|                           ^|
echo   ^| [4]        [5]        [6] ^|
echo   ^|                           ^|
echo   ^| [7]        [8]        [9] ^|
echo   ^'---------------------------^'
choice /n /c 123456789 /m "Where should %item% be placed?"
if %errorlevel% == 1 set "%2=x=(0.25*text_h):y=(0.25*text_h)"
if %errorlevel% == 2 set "%2=x=(w-text_w)/2:y=(0.25*text_h)"
if %errorlevel% == 3 set "%2=x=w-tw-(0.25*th):y=(0.25*text_h)"
if %errorlevel% == 4 set "%2=x=(0.25*text_h):y=(h-text_h)/2"
if %errorlevel% == 5 set "%2=x=(w-text_w)/2:y=(h-text_h)/2"
if %errorlevel% == 6 set "%2=x=w-tw-(0.25*th):y=(h-text_h)/2"
if %errorlevel% == 7 set "%2=x=(0.25*text_h):y=(h-1.25*text_h)"
if %errorlevel% == 8 set "%2=x=(w-text_w)/2:y=(h-1.25*text_h)"
if %errorlevel% == 9 set "%2=x=w-tw-(0.25*th):y=(h-1.25*text_h)"
call :titledisplay
goto :eof

:: color modifications and video stretching (custom aspect ratio)
:colorquestions
call :newline
call :clearlastprompt
:: questions about modifying video color
choice /c YN /m "Do you want to customize saturation, contrast, and brightness?"
if %errorlevel% == 1 (
    set colorq=y
) else (
    goto :eof
)
:: prompts for specific values
set /p "contrastvalue=Select a contrast value [93mbetween -1000.0 and 1000.0[0m, default is 1: "
set /p "saturationvalue=Select a saturation value [93mbetween 0.0 and 3.0[0m, default is 1: "
set /p "brightnessvalue=Select a brightness value [93mbetween -1.0 and 1.0[0m, default is 0: "
:: tests if the values are floats (or positive floats)
if not "%contrastvalue%"=="%contrastvalue: =%" set contrastvalue=1
if not "%saturationvalue%"=="%saturationvalue: =%" set set saturationvalue=1
if not "%brightnessvalue%"=="%brightnessvalue: =%" set brightnessvalue=0
for /f "tokens=1* delims=-.0123456789" %%j in ("j0%contrastvalue:"=%") do (if not "%%k"=="" set contrastvalue=1)
for /f "tokens=1* delims=.0123456789" %%l in ("l0%saturationvalue:"=%") do (if not "%%m"=="" set saturationvalue=1)
for /f "tokens=1* delims=-.0123456789" %%n in ("n0%brightnessvalue:"=%") do (if not "%%o"=="" set brightnessvalue=0)
if %colorq% == y set "colorfilter=eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,"
goto :eof

:stretch
call :newline
call :clearlastprompt
:: asks about the video's aspect ratio
choice /c YN /m "Do you want to stretch the video?"
if %errorlevel% == 1 (
    set stretchres=y
) else (
    call :clearlastprompt
    goto :eof
)
echo [93mRemember to use only whole numbers.[0m
set /p "widthratio=How stretched should be width be? [93mDefault is 1 (no stretch)[0m: "
set /p "heightratio=How stretched should be height be? [93mDefault is 1 (no stretch)[0m: "
:: sets the aspect ratio, but as an equation instead of as a float, since batch doesn't like floats
set "aspectratio=%widthratio%/%heightratio%"
call :clearlastprompt
goto :eof

:: set the stretched width/height
:stretchmath
:: in the words of the great vladaad, "fucking batch doesn't know what a float is"
set /a "widthmod=(%desiredwidth%*%widthratio%) %% %heightratio%"
set /a "desiredwidth=((%desiredwidth%*%widthratio%)+%widthmod%)/%heightratio%"
set /a desiredwidth=(%desiredwidth%/2)*2
goto :eof

:: asks if they want music and if so, the file to get it from and the start time
:replaceaudioquestion
call :newline
choice /c YN /m "Do you want to replace the audio?"
if %errorlevel% == 2 (
    call :clearlastprompt
    goto :eof
)
:addingthemusic
:: asks for a specific file to get music from
set replaceaudio=y
set /p lowqualmusic=Please drag the desired file here, [93mit must be an audio/video file[0m: 
:: if it's not a valid file send the user back to input a valid file
if not exist %lowqualmusic% (
    call :clearlastprompt
    echo [91mInvalid file^^! Please drag an existing file from your computer^^![0m
    goto addingthemusic
)
:: asks the user when the music should start
set /p "musicstarttime=Enter a specific start time of the music [93min seconds[0m: "
call :clearlastprompt
goto :eof

:: asks about resampling (skips if in simple mode or input fps is less than output)
:interpolationandresampling
choice /m "Do you want to interpolate/resample the video, depending on the framerate?" 
if %errorlevel% == 1 set "resample=y"
call :newline
call :clearlastprompt
goto :eof

:resamplemath
:: do nothing if the input fps is equal to the output fps
if %outputfps% == %intputfps% goto :eof
:: interpolate if output fps is greater than input fps
if %outputfps% gtr %intputfps% (
    set "fpsfilter=minterpolate=fps=%outputfps%,"
    goto :eof
)
:: resample if output fps is greater than input fps
:: determines the number of frames to blend together per frame (does not use decimals/floats because batch is like that)
set tmixframes=(%inputfps%/%outputfps%)
set /a tmixcheck=%tmixframes%
:: tmix breaks at >128 frames, so make sure it doesn't go above that
if %tmixcheck% gtr 128 set tmixframes=128
set "fpsfilter=tmix=frames=!tmixframes!:weights=1,fps=%outputfps%,"
goto :eof

:: the start of advanced mode
:durationquestions
call :clearlastprompt
:: asks if the user wants to trim
choice /m "Do you want to trim the video?"
if %errorlevel% == 1 (
    set trimmed=y
) else (
    call :newline
    call :clearlastprompt
    goto :eof
)
:: asks where to start clip
:startquestion
set starttime=0
set /p "starttime=[93mIn seconds[0m, where do you want your video to start: "
if "%starttime%" == " " set starttime=0
:: asks length of clip
:timequestion
set vidtime=262144
set /p "vidtime=[93mIn seconds[0m, how long do you want the video to be: "
if "%vidtime%" == " " set vidtime=262144
call :clearlastprompt
goto :eof

:: text to speech
:: asks if the user wants to use text to speech and gets the text to be spoken and volume
:voicesynth
choice /m "Do you want to add text-to-speech?"
if %errorlevel% == 1 set tts=y
if %errorlevel% == 2 (
    call :clearlastprompt
    goto :eof
)
:: verify that the ffmpeg build contains flite by saving the output of ffmpeg to a file and searching for libflite
ffmpeg>nul 2>>"%temp%\ffmpegQM.txt"
>nul find "libflite" "%temp%\ffmpegQM.txt" || (
    del "%temp%\ffmpegQM.txt"
    echo [91mError^^! Your installation of FFmpeg does not have libflite ^(the text to speech library^)^^![0m
    set tts=n
    pause
    call :clearlastprompt
    goto :eof
)
del "%temp%\ffmpegQM.txt"
:: text to speech text and volume
echo What do you want the text-to-speech to say?
set /p "ttstext="
set volume=0
set /p "volume=How much should the volume of the text-to-speech be boosted by (in dB)? Default is 0: "
call :clearlastprompt
goto :eof

:: combines text to speech with output since the main encoders don't factor in text to speech
:encodevoice
set "af2="
:: 
if not "%audiofilters%e" == "e" set "af2=,%audiofilters:-af =%"
:: makes sure that the file doesn't already exist
set "ttsuffix= tts"
:ttexist
set /a "q+=1"
if exist "%cd%\%filename% %ttsuffix%%container%" (
    set "ttsuffix= tts (%q%)"
    goto ttexist
)
echo Encoding and merging text-to-speech...
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i anullsrc -filter_complex "flite=text='%ttstext%':voice=kal16%af2%,volume=%volume%dB"  -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%container%" -movflags +use_metadata_tags -map_metadata 1 -c:v copy -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename%%ttsuffix%%container%"
if exist "%filename%%container%" (del "%filename%%container%")
set outputvar="%cd%\%filename%%ttsuffix%%container%"
set "filename=%filename%%ttsuffix%"
goto :eof

:: miscillaneous filters that are too small to be their own options
:: all of the "toggletc(x)" labels are a part of this, used to toggle the colors
:filterlist
if "%tcltrue%" == "false" (
    choice /m "Do you want some extra video effects?"
) else (
    echo Do you want to add some extra video effects?
)
if "%tcltrue%" == "false" (
    if %errorlevel% == 2 (
        call :clearlastprompt
        goto :eof
    )
)
echo [92mGreen[0m items are selected, [90mgray[0m items are unselected
echo  [38;2;254;165;0m  [D] Done - finish your selection and move to the next prompt[90m
echo  %tcl1% [1] Erosion - makes the edges of objects appear darker[90m
echo  %tcl2% [2] Lagfun - makes darker pixels update slower[90m
echo  %tcl3% [3] Negate - inverts colors[90m
echo  %tcl4% [4] Interlace - combines frames together using interlacing[90m
echo  %tcl5% [5] Edgedetect - inverts colors[90m
echo  %tcl6% [6] Shufflepixels - Reorder pixels in video frames[90m
echo  %tcl7% [7] Guided - apply guided filter for edge-preserving smoothing, dehazing, etc[0m
choice /c 1234567D /n /m "Select one or more options: "
if %errorlevel% == 8 (
    call :titledisplay
    goto :eof
)
call :toggletcl%errorlevel%
echo [12A
goto :filterlist

:: what all of the toglectl(x) functions do is:
:: - confirm that an option has been made (setting tcltrue to true)
:: - if the option was previously set to disabled, enable it and add the filter to the filters, highlight the selection, then exit the function
:: - if the option was previously set to enabled, disable it and remove the filter from the filters, remove the highlight, and exit the function

:toggletcl1
    set tcltrue=true
    if "%tcl1%2" == "[92m2" (
        set "tcl1= "
        set "filtercl=%filtercl:,erosion=%"
        goto :eof
    )
    set "filtercl=%filtercl%,erosion"
    set "tcl1=[92m"
goto :eof

:toggletcl2
    set tcltrue=true
    if "%tcl2%2" == "[92m2" (
        set "tcl2= "
        set "filtercl=%filtercl:,lagfun=%"
        goto :eof
    )
    set "filtercl=%filtercl%,lagfun"
    set "tcl2=[92m"
goto :eof

:toggletcl3
    set tcltrue=true
    if "%tcl3%2" == "[92m2" (
        set "tcl3= "
        set "filtercl=%filtercl:,negate=%"
        goto :eof
    )
    set "filtercl=%filtercl%,negate"
    set "tcl3=[92m"
goto :eof

:toggletcl4
    set tcltrue=true
    if "%tcl4%2" == "[92m2" (
        set "tcl4= "
        set "filtercl=%filtercl:,interlace=%"
        goto :eof
    )
    set "filtercl=%filtercl%,interlace"
    set "tcl4=[92m"
goto :eof

:toggletcl5
    set tcltrue=true
    if "%tcl5%2" == "[92m2" (
        set "tcl5= "
        set "filtercl=%filtercl:,edgedetect=%"
        goto :eof
    )
    set "filtercl=%filtercl%,edgedetect"
    set "tcl5=[92m"
goto :eof

:toggletcl6
    set tcltrue=true
    if "%tcl6%2" == "[92m2" (
        set "tcl6= "
        set "filtercl=%filtercl:,shufflepixels=%"
        goto :eof
    )
    set "filtercl=%filtercl%,shufflepixels"
    set "tcl6=[92m"
goto :eof

:toggletcl7
    set tcltrue=true
    if "%tcl7%2" == "[92m2" (
        set "tcl7= "
        set "filtercl=%filtercl:,guided=%"
        goto :eof
    )
    set "filtercl=%filtercl%,guided"
    set "tcl7=[92m"
goto :eof

:: if discord is selected from the menu, it sends the user to discord, clears the console, and goes back to start
:discord
echo [96mSending to Discord^^![0m
start "" https://discord.com/invite/9tRZ6C7tYz
call :clearlastprompt
goto afterstartup

:: if the website is selected from the menu, it sends the user to the website, clears the console, and goes back to start
:website
echo [96mSending to website^^![0m
start "" https://qualitymuncher.lgbt/
call :clearlastprompt
goto afterstartup

:: suggestions
:suggestion
set /a wb9=3428*12/5234*32-453+54+(8234*2+(300-3)*2)/3*7/2-3053
:: checks for a connection to discord since you need that to send a message to a webhook
call :clearlastprompt
ping /n 1 discord.com  | find "Reply" > nul
if %errorlevel% == 1 (
    set internet=false
    echo [91mSorry, either discord is down or you're not connected to the internet. Please try again later.[0m
    echo.
    pause
    call :clearlastprompt
    goto afterstartup
)
:: asks information about the suggestion for details
choice /c SB /m "Would you like to make a suggestion or report a bug?"
if %errorlevel% == 2 goto bugreport
set /p "mainsuggestion=What's your suggestion? "
set /p "suggestionbody=If needed, please elaborate further here: "
set "author=NO INPUT FOR AUTHOR"
set /p "author=What is your name on discord? [93mThis is optional[0m: "
echo.
call :clearlastprompt
echo %author%'s suggestion:
echo %mainsuggestion%
echo %suggestionbody%
echo.
choice /m "Are you sure you would like to submit this suggestion?"
if %errorlevel% == 2 (
    call :clearlastprompt
    echo [91mOkay, your suggestion has been cancelled.[0m
    echo.
    pause
    call :clearlastprompt
    goto afterstartup
)
:continuesuggest
:: please do not abuse this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New suggestion^^!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/webhooks/100557400%wb9%2094%wb6%4/an%wb11%Px9R%wbh4%4tV%wb19%
call :clearlastprompt
echo [92mYour suggestion has been successfully sent to the developers^^![0m
echo.
pause
call :clearlastprompt
goto afterstartup

:: lets users report bugs
:bugreport
set wbh2=lxyrX4Y5TxLkQXfq
set /p "mainsuggestion=What is the bug? "
set /p "suggestionbody=How do you reproduce the bug: "
set "author=NO INPUT FOR AUTHOR"
set /p "author=What is your name on discord? [93mThis is optional but very helpful[0m: "
echo.
call :clearlastprompt
echo %author%'s bug report:
echo %mainsuggestion%
echo %suggestionbody%
echo.
choice /m "Are you sure you would like to submit this bug report?"
:: if the user does not want to submit the bug report, it goes back to the start
if %errorlevel% == 2 (
    call :clearlastprompt
    echo [91mOkay, your suggestion has been cancelled.[0m
    echo.
    pause
    call :clearlastprompt
    goto afterstartup
)
:: sends the bug report to the webhook
:: please do not abuse this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New bug report^^!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/we^bhooks/100%wbh17%557%mathvar4%400%wb9%2094%wb6%4/an%wb11%Px9R%wbh4%4tV%wb19%
call :clearlastprompt
echo [92mYour bug report has been successfully sent to the developers^^![0m
echo.
pause
call :clearlastprompt
goto afterstartup

:: easter egg that makes customizable rainbow text
:thing3
:: calls a seperate window that jumps to the colorstart label and makes the rainbow text
start "" %0 qmloo
call :clearlastprompt
goto afterstartup

:colorstart
:: speedr is the "step" of the rainbow text (how fast the text changes)
set /p "speedr=Enter a number between 1 and 25: "
set o=0
:: this is the text that is displayed
set /p "startertext=Enter some text: "
:: this loop duplicates the text until it's greater than 120 characters
:qmloop
set QMT=%QMT%%startertext% 
set QMTnospace=%QMT: =_%
echo "%QMTnospace%" > %temp%\QMTnospace.txt
for %%? in (%temp%\QMTnospace.txt) do ( set /a strlength3=%%~z? - 2 )
if not %strlength3% gtr 120 goto qmloop
:: only use the first 120 characters (so it doesn't go over the window size)
set QMT=%QMT:~0,120%
if exist "%temp%\QMTnospace.txt" (del "%temp%\QMTnospace.txt")
cls
:: sets the initial RGB values for the text
set R=255
set G=0
set B=255
:: the start of the loop that makes the text change colors and displays it
:colorpart
echo [38;2;%R%;%G%;%B%m%QMT%[0m
if %R% geq 255 (
    if %B% LEQ 0 (
        set /a G=%G%+%speedr%
    ) else (
        set /a B=%B%-%speedr%
    )
)
if %G% geq 255 (
    if %R% LEQ 0 (
        set /a "B=%B%+%speedr%"
    ) else (
        set /a "R=%R%-%speedr%"
    )
)
if %B% geq 255 (
    if %G% LEQ 0 (
        set /a "R=%R%+%speedr%"
    ) else (
        set /a "G=%G%-%speedr%"
    )
)
if %R% lss 0 set /a R=0
if %G% lss 0 set /a G=0
if %B% lss 0 set /a B=0
if %R% gtr 255 set /a R=255
if %G% gtr 255 set /a G=255
if %B% gtr 255 set /a B=255
goto colorpart

:: atzur told me to write comments that "explain why things are there instead of what they do", so here we go
:: why do users not provide an input to a file which demands an input?
:: perhaps it is to access the main menu
:: that's why there's a main menu here instead of a message telling them to fuck off
:noinput
echo [91mERROR: no input file^^![0m
echo Press [W] to open the website, [D] to join the discord server, [P] to make a suggestion or bug report, or [C] to close.
echo You can also press [F] to input a file manually, [N] to view announcements, or [U] to check for updates.
choice /n /c WDCFPGJMUN
call :clearlastprompt
if %errorlevel% == 1 goto website
if %errorlevel% == 2 goto discord
if %errorlevel% == 4 goto manualfile
if %errorlevel% == 5 goto suggestion
if %errorlevel% == 6 goto thing1
if %errorlevel% == 7 goto thing2
if %errorlevel% == 8 goto thing3
if %errorlevel% == 9 (
    set forceupdate=true
    goto updatecheck
)
if %errorlevel% == 10 (
    call :announcement
    goto afterstartup
)
goto closingbar

:: where most things direct to when the program is done - plays a nice sound if possible, pauses, then prompts the user for some input
:exiting
echo.
where /q ffplay || goto aftersound
if %done% == true start /min cmd /c ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound
if not b%2 == b goto nopipingforyou
echo Press [C] to close, [O] to open the output, [F] to open the file path, or [P] to pipe the output to another script.
choice /n /c COFPL /m "You can also press [L] to generate a debugging log for errors."
if %errorlevel% == 5 (
    call :makelog
    goto closingbar
)
if %errorlevel% == 4 goto piped
if %errorlevel% == 2 %outputvar%
if %errorlevel% == 3 explorer /select, %outputvar%
goto closingbar

:nopipingforyou
choice /n /c CL /m "Press [C] to close or [L] to generate a debugging log for errors."
if %errorlevel% == 2 (
    call :makelog
    goto closingbar
)
goto closingbar

:: makes a log for when a user might encounter an error
:makelog
call :clearlastprompt
:: go to the logs directory, if it exists
set pastdir=%cd%
if not 1%loggingdir% == 1 cd /d %loggingdir%
:: delete old log
del "Quality Muncher Log.txt"
:: stuff to log (anything and everything possible for batch to get that might be responsible for issues)
:: filename and outputvar are seperate from the rest because filesnames can have weird characters that might cause the entire log to fail if it's not seperated
echo filename: %filename% > "Quality Muncher Log.txt"
echo outputvar: %outputvar% >> "Quality Muncher Log.txt"
(
    echo LOG CREATION TIME: %time% ON %date%
    echo.
    echo SIMPLE
    echo     version: %version%
    echo     complexity: %complexity%
    echo     customizationquestion: %customizationquestion%
    echo     input width by height: %width% by %height%
    echo     intput fps: %inputfps%
    echo     output width by height: %desiredwidth% by %desiredheight%
    echo     badvideobitrate: %badvideobitrate%
    echo     badaudiobitrate with added 000: %badaudiobitrate%000
    echo     internet: %internet%
    echo.
    echo VIDEO OPTIONS
    echo     fps: %outputfps%
    echo     videobr: %videobr%
    echo     audiobr: %audiobr%
    echo     scaleq: %scaleq%
    echo     details: %details%
    echo.
    echo ADVANCED
    echo     trimmed: %trimmed%
    echo         starttime: %starttime%
    echo         vidtime {aka video length}: %vidtime%
    echo     corrupt: %corrupt%
    echo         corruptsev: %corruptsev%
    echo     spoofduration: %spoofduration%
    echo         durationtype: %durationtype%
    echo         linecontentog: %linecontentog%
    echo         linecontentnew: %linecontentnew%
    echo     bouncy: %bouncy%
    echo         bouncetype: %bouncetype%
    echo         incrementbounce: %incrementbounce%
    echo         minimumbounce: %incrementbounce%
    echo     speedq: %speedq%
    echo     resample: %resample%
    echo     stretchres %stretchres%
    echo         custom width by height aspect ratio: %widthratio% by %heightratio%
    echo     replaceaudio {added audio}: %replaceaudio%
    echo     colorq: %colorq%
    echo         contrast: %contrastvalue%
    echo         saturation: %saturationvalue%
    echo         brightness: %brightnessvalue%
    echo     addedtextq: %addedtextq%
    echo         toptext: %toptext%
    echo         tsize: %tsize%
    echo         bottomtext: %bottomtext%
    echo         tsize2: %tsize2%
    echo     distortaudio {audio distortion}: %distortaudio%
    echo         method: %method%
    echo         distortionseverity: %distortionseverity%
    echo         distsev {distortionseverity*10}: %distsev%
    echo     noglobalspeed {true means audio speed is always 1}: %noglobalspeed%
    echo     frying: %frying%
    echo     tts: %tts%
    echo         ttstext: %ttstext%
    echo         volume: %volume%
    echo     extra effects
    echo         filtercl: %filtercl%
    echo         tcltrue {at least one effect is enabled}: %tcltrue%
    echo     stutter: %stutter%
    echo         stutteramount: %stutteramount%
    echo.
    echo USER OPTIONS
    echo     autoupdatecheck: %autoupdatecheck%
    echo     stayopen: %stayopen%
    echo     showtitle: %showtitle%
    echo     cleanmode: %cleanmode%
    echo     animate: %animate%
    echo     animatespeed: %animatespeed%
    echo     encodingspeed: %encodingspeed%
    echo     updatespeed: %updatespeed%
    echo     container: %container%
    echo     audiocontainer: %audiocontainer%
    echo     imagecontainer: %imagecontainer%
    echo FFMPEG DETAILS
)>>"Quality Muncher Log.txt"
:: add ffmpeg to the log
ffmpeg>nul 2>>"Quality Muncher Log.txt"
:: prompt to upload to the webhook for the devs
call :titledisplay
choice /m "Log has been made. Upload and send to developers?"
if %errorlevel% == 2 goto :eof
choice /m "Do you want to provide more details about the log? For example, what might've caused it or what the error was."
if %errorlevel% == 1 set /p "detaillog=Please provide more details: "
if %errorlevel% == 2 set detaillog=No details provided.
set /p "author=What is your name on discord? [93mThis is optional but very helpful[0m: "
:: check if the user can connect to the site
ping /n 1 transfer.sh  | find "Reply" > nul
if %errorlevel% == 1 (
    set internet=false
    echo [91mSorry, either the transfer service is down or you're not connected to the internet. Please try again later.[0m
    echo.
    pause
    goto :eof
)
:: upload and save the link to a file, then save to a variable
curl -s --upload-file "Quality Muncher Log.txt" https://transfer.sh > "%temp%\curlurl.txt"
set /p curlurl=<"%temp%\curlurl.txt"
if exist "%temp%\curlurl.txt" (del "%temp%\curlurl.txt")
:: send to the webhook for the devs
:: please don't abuse this webhook it would make me very sad
set wbh2=lxyrX4Y5TxLkQXfq
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"username\": \"Quality Logs\",\"content\": \"New log recieved^^!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%detaillog%\", \"description\": \"%curlurl%\", \"author\": {\"name\": \"%author% at %time% on %date:~4,10%\"}}]}" https://discord.com/api/webhooks/988214286629359656/0bSrcdJdOLGuR-w89lPasi16qVr_cj%wbh2%ndzi0K1CK4MoHYnoTmtcoS
if not 1%loggingdir% == 1 cd /d %pastdir%
call :titledisplay
echo [92mYour log has been successfully sent to the developers^^![0m
echo.
pause
goto :eof

:: pipes the output to another script of the user's choosing
:piped
if %cleanmode% == true call :titledisplay
echo Scripts found:
:: add scripts here, if you want
echo [S] Custom Script
echo [1] FFmpeg
if exist "%~dp0\^^!add text.bat" echo [2] add text
if exist "%~dp0\^^!audio sync.bat" echo [3] audio sync
if exist "%~dp0\^^!change fps.bat" echo [4] change fps
if exist "%~dp0\^^!change speed.bat" echo [5] change speed
if exist "%~dp0\^^!extract frame.bat" echo [6] extract frame
if exist "%~dp0\^^!interpolater.bat" echo [7] interpolater
if exist "%~dp0\^^!replace audio.bat" echo [8] replace audio
if exist "%~dp0\^^!upscale nn.bat" echo [9] upscale NN
if exist "%~dp0\^^!convert to gif.bat" echo [G] convert to GIF
echo.
:: selecting and piping
choice /n /c S123456789CG /m "Select a script to pipe to, or press [C] to close: "
if %errorlevel% == 1 goto customscript
cls
if %errorlevel% == 3 cmd /k call "%~dp0\^^!add text.bat" %outputvar%
if %errorlevel% == 4 cmd /k call "%~dp0\^^!audio sync.bat" %outputvar%
if %errorlevel% == 5 cmd /k call "%~dp0\^^!change fps.bat" %outputvar%
if %errorlevel% == 6 cmd /k call "%~dp0\^^!change speed.bat" %outputvar%
if %errorlevel% == 7 cmd /k call "%~dp0\^^!extract frame.bat" %outputvar%
if %errorlevel% == 8 cmd /k call "%~dp0\^^!interpolater.bat" %outputvar%
if %errorlevel% == 9 cmd /k call "%~dp0\^^!replace audio.bat" %outputvar%
if %errorlevel% == 10 cmd /k call "%~dp0\^^!upscale nn.bat" %outputvar%
if %errorlevel% == 12 cmd /k call "%~dp0\^^!convert to gif.bat" %outputvar%
if %errorlevel% == 11 exit
if %errorlevel% == 2 call :ffmpegpipe
goto closingbar

:ffmpegpipe
set /p "ffmpeginput=ffmpeg -i %outputvar% "
echo.
echo [38;2;254;165;0mEncoding...[0m
echo.
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %outputvar% %ffmpeginput%
set done=true
echo.
echo [92mDone^^![0m
echo.
where /q ffplay || goto aftersound2
if %done% == true start /min cmd /c ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound2
pause
goto :eof

:customscript
call :newline
call :clearlastprompt
set /p "customscript=Enter the path to the script you want to pipe to: "
cls
cmd /k call %customscript% %outputvar%
goto closingbar

:: if the user inputs a file manually instead of with send to or drag and drop
:manualfile
set /p file=Please drag your input here: 
cls
call %0 %file%
exit

:: checks for updates - done automatically unless disabled in options
:updatecheck
if exist "%temp%\QMnewversion.txt" del "%temp%\QMnewversion.txt"
:: checks if github is able to be accessed
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 (
    call :nointernet
    goto afterstartup
)
set internet=true
:: grabs the version of the latest public release from the github
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/version.txt" --output %temp%\QMnewversion.txt
set /p newversion=<%temp%\QMnewversion.txt
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
:: if the new version is the same as the current one, go to the start
:: however, if the user choose to update from the main menu, give the option for the user to force an update
if "%version%" == "%newversion%" (
    set isupdate=false
    if %forceupdate% == false (
        goto afterstartup
    ) else (
        echo Your version of Quality Muncher is up to date^^! Press [C] to continue
        choice /c CF /n /m "Alternatively, you can forcibly update/repair Quality Muncher by pressing [F]."
        if %errorlevel% == 1 (
            goto afterstartup
        ) else (
            call :clearlastprompt
            goto updatescript
        )
    )
) else (
    set isupdate=true
)
:: tells the user a new update is out and asks if they want to update
echo [96mThere is a new version (%newversion%) of Quality Muncher available^^!
echo Press [U] to update or [S] to skip.
echo [90mTo hide this message in the future, set the variable "autoupdatecheck" in the script options to false.[0m
choice /c US /n
echo.
set isupdate=false
if %errorlevel% == 2 (
    call :clearlastprompt
    goto afterstartup
)
:updatescript
:: gives the user some choices when updating
echo Are you sure you want to update? This will overwrite the current file^^!
echo [92m[Y] Yes, update and overwrite.[0m [93m[C] Yes, BUT save a copy of the current file.[0m [91m[N] No, take me back.[0m
choice /c YCN /n
if %errorlevel% == 2 (
    copy %0 "%~dpn0 (OLD).bat" || (
        echo [91mError copying the file^^! Updating has been aborted.[0m
        echo Press any key to go to the menu
        pause>nul
        call :titledisplay
        goto afterstartup
    )
    echo Okay, this file has been saved as a copy in the same directory. Press any key to continue updating.
    pause>nul
)
if %errorlevel% == 3 (
    call :titledisplay
    goto afterstartup
)
echo.
:: installs the latest public version, overwriting the current one, and running it using this input as a parameter so you don't have to run send to again
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/Quality%20Muncher.bat" --output %0 || (
    echo [91mecho Downloading the update failed^^! Please try again later.[0m
    echo Press any key to go to the menu
    pause>nul
    call :titledisplay
    goto afterstartup
)
cls
:: runs the (updated) script
%0 %1
exit

:: runs if there isn't internet (comes from update check)
:nointernet
set internet=false
echo [91mUpdate check failed, skipping.[0m
echo.
goto :eof

:: easter egg that shows a computer with a rainbow
:thing1
:: rainbow added by me
:: credit to Kevin Lam for ASCII art
cls
set v=0
set "atz=                 "
echo              ,----------------,              ,---------,
echo         ,-----------------------,          ,"        ,"^|
echo       ,"                      ,"^|        ,"        ,"  ^|
echo      +-----------------------+  ^|      ,"        ,"    ^|
echo      ^|  .-----------------.  ^|  ^|     +---------+      ^|
echo      ^|  ^|[48;2;255;99;84m%atz%[0m^|  ^|  ^|     ^| -==----'^|      ^|
echo      ^|  ^|[48;2;251;169;72m%atz%[0m^|  ^|  ^|     ^|         ^|      ^|
echo      ^|  ^|[48;2;250;228;66m%atz%[0m^|  ^|  ^|     ^|         ^|      ^|
echo      ^|  ^|[48;2;138;213;72m%atz%[0m^|  ^|  ^|/----^|`---=    ^|      ^|
echo      ^|  ^|[48;2;42;169;243m%atz%[0m^|  ^|  ^|   ,/^|==== ooo ^|      ;
echo      ^|  ^|[48;2;156;78;151m%atz%[0m^|  ^|  ^|  // ^|(((( [33]^|    ,"
echo      ^|  `-----------------'  ^|," .;'| |((((     |  ,"
echo      +-----------------------+  ;;  ^| ^|         ^|,"     -Art by Kevin Lam-
echo         /_)______________(_/  //'   ^| +---------+
echo    ___________________________/___  `,
echo   /  oooooooooooooooo  .o.  oooo /,   \,"-----------
echo  / ==ooooooooooooooo==.o.  ooo= //   ,`\--{)B     ,"
echo /_==__==========__==_ooo__ooo=_/'   /___________,"
echo.
pause
call :titledisplay
goto afterstartup

:: scrapped version, will never run unless cls fails or goto afterstartup fails
:: it's just here if i ever want to use this later
cls
set "atz= "
:atzloop
set "atz=%atz%%atz%"
set /a "v+=1"
if %v% lss 7 goto atzloop
set v=0
set atz=%atz:~0,120%
echo [48;2;255;99;84m%atz%
echo [48;2;253;134;79m%atz%
echo [48;2;251;169;72m%atz%
echo [48;2;250;198;69m%atz%
echo [48;2;250;228;66m%atz%
echo [48;2;195;220;68m%atz%
echo [48;2;138;213;72m%atz%
echo [48;2;91;191;157m%atz%
echo [48;2;42;169;243m%atz%
echo [48;2;98;122;196m%atz%
echo [48;2;156;78;151m%atz%[0m
pause > nul
cls
goto afterstartup

:: random quality
:random
set details=n
:: max and minimum for the random values
set min=1
set max=15
echo.
:: rays "Random Quality Selected^^!" with "Random" in rainbow text color color
echo [91mR[93ma[92mn[96md[94mo[95mm[0m %qs%
:: gets random values
set /a outputfps=%random% %% 30
set /a videobr=%random% * %max% / 32768 + %min%
set /a scaleq=%random% * %max% / 32768 + %min%
set /a audiobr=%random% * %max% / 32768 + %min%
set endingmsg=Random Quality
goto :eof

:: runs at the start of the script if animate is true (disabled by default)
:: make terminal wider until it reaches 120
:loadingbar
mode con: cols=%cols% lines=%lines%
set /a cols=%cols%+%animatespeed%
if not %cols% geq 120 goto loadingbar
set /a animatespeed2=%animatespeed%/5
if %animatespeed2% lss 1 set animatespeed2=1
if not %cols% == 120 set cols=120
:: makes the console taller until it reaches 30
:loadingy
mode con: cols=%cols% lines=%lines%
set /a lines=%lines%+%animatespeed2%
if not %lines% geq 30 goto loadingy
if not %lines% == 30 mode con: cols=%cols% lines=30
:: runs powershell to set the buffer size to enable scrolling
powershell -noprofile -command "&{(get-host).ui.rawui.buffersize=@{width=120;height=9901};}"
goto :eof

:: essentially the opposite of loadingbar (but exits if animate is false)
:closingbar
if %animate% == false exit
:closingloop
mode con: cols=%cols% lines=%lines%
set /a cols=%cols%-5
set /a lines=%lines%-1
if not %cols% == 14 goto closingloop
exit

:: asks if the user wants a custom output name
:outputquestion
choice /m "Would you like a custom output name?"
if %errorlevel% == 2 (
    echo.
    call :clearlastprompt
    goto :eof
)
set /p "filenametemp=Enter your output name [93mwith no extension[0m: "
set "filename=%filenametemp%"
call :newline
call :clearlastprompt
goto :eof

:: audio questions - ran when the user uses an audio file as an input
:: this shouldn't be too comlicated so i didn't leave many comments, but if you have questions dm me (Frost#5872)
:novideostream
set audioencoder=aac
:: the AAC codec has weird issues with mp3 - sometimes this causes issue but really i don't know for sure and i can't consistently reproduce them so this tries to fix that but using a different codec
if %audiocontainer% == .mp3 set audioencoder=libmp3lame
set hasvideo=false
echo [38;2;254;165;0mInput is an audio file.[0m
echo.
set /p "audiobr=[93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad: "
set /a badaudiobitrate=80/%audiobr%
call :durationquestions
call :speedquestions
call :newline
call :audiodistortion
set "filename=%~n1 (Quality Munched)"
if exist "%filename%%audiocontainer%" call :renamefile
call :voicesynth
echo [38;2;254;165;0mEncoding...[0m
echo.
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% -i %1 ^
-vn %metadata% -preset %encodingspeed% ^
-c:a %audioencoder% -b:a %badaudiobitrate%000 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%audiocontainer%"
set outputvar="%cd%\%filename%%audiocontainer%
if "%tts%"=="y" call :encodevoiceNV
goto end

:: text-to-speech encoding for no video stream
:: seperate from the video one since it has some options that aren't the same
:encodevoiceNV
set "af2="
if not "%audiofilters%e" == "e" set "af2=,%audiofilters:-af =%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i anullsrc -filter_complex "flite=text='%ttstext%':voice=kal16%af2%,volume=%volume%dB" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%audiocontainer%" -movflags +use_metadata_tags -map_metadata 1 -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename% tts%audiocontainer%"
if exist "%filename%%audiocontainer%" (del "%filename%%audiocontainer%")
set outputvar="%cd%\%filename% tts%audiocontainer%"
goto :eof

:: checks if a file with the same name as the output already exists, if so, appends a (1) to the name, then (2) if that also exists, then (3), etc
:: used to stop ffmpeg from overwriting files
:renamefile
:: start of the repeat until loop (repeats until the file doesn't exist)
:renamefileloop
if %isimage% == true set container=%imagecontainer%
if %hasvideo% == false set "container=%audiocontainer%"
set /a "i+=1"
if exist "%filename% (%i%)%container%" goto renamefileloop
set "filename=%filename% (%i%)"
goto :eof

:: easter egg that plays a sound
:thing2
:: credit http://jeffwouters.nl/index.php/2012/03/get-your-geek-on-with-powershell-and-some-music/
powershell -noprofile -command [console]::beep(440,500);[console]::beep(440,500);[console]::beep(440,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,1000);[console]::beep(659,500);[console]::beep(659,500);[console]::beep(659,500);[console]::beep(698,350);[console]::beep(523,150);[console]::beep(415,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,1000);
call :clearlastprompt
goto afterstartup

:: used to munch images/gifs
:imagemunch
set isimage=true
set "fryfilter="
echo [38;2;254;165;0mInput is an image or gif.[0m
:: grabs dimensions of the input
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
if exist "%temp%\height.txt" (del "%temp%\height.txt")
if exist "%temp%\width.txt" (del "%temp%\width.txt")
echo.
:: asks questions for quality and size (skipped if using multiqueue)
choice /c ON /m "Old or new image munching method?"
call :clearlastprompt
if %errorlevel% == 2 goto newmunch
:: skip questions if in multiqueue and set the variables
if not check%3 == check (
    set imageq=%3
    set imagesc=%4
    goto skippedque
)
set /p "imageq=[93mOn a scale from 1 to 10[0m, how bad should the quality be? "
call :clearlastprompt
set /p "imagesc=[93mOn a scale from 1 to 10[0m, how much should the image be shrunk by? "
call :clearlastprompt
:skippedque
set /a desiredheight=%height%/%imagesc%
set /a desiredheight=(%desiredheight%/2)*2
if a%2 == aY (
    set fricheck=1
    goto skipq2
)
if a%2 == aN (
    set fricheck=2
    goto skipq2
)
choice /m "Deep fry the image?"
set fricheck=%errorlevel%
:skipq2
set sep=r
if %fricheck% == 1 (
    set "fryfilter=noise=alls=20,eq=saturation=2.5:contrast=200:brightness=0.3,noise=alls=10"
    set "sep=r,"
)
if %fricheck% == 2 call :clearlastprompt
call :newline
set "filename=%~n1 (Quality Munched)"
:: very work-in-progress formula, not even sure if it works completely
set /a badimagebitrate=(%imageq%*2)+10
if %badimagebitrate% LSS 2 set badimagebitrate=2
if exist "%filename%%imagecontainer%" call :renamefile
:afternamecheck
if %fricheck% == 2 (
    echo [38;2;254;165;0mEncoding...[0m
    echo.
)
:: the amount of colors to use in the image
set /a pallete=100/%imageq%
if not "%fryfilter%1" == "1" goto fried
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -vf palettegen=max_colors=%pallete% "%temp%\palletforqm.jpg"
if %imagecontainer% == .gif goto gifmoment1
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -i "%temp%\palletforqm.jpg" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate% -pix_fmt yuv410p -filter_complex "paletteuse,scale=-2:%desiredheight%:flags=%scalingalg%,noise=alls=%imageq%/4,eq=saturation=(%imageq%/50)+1:contrast=1+(%imageq%/50)" "%filename%%imagecontainer%"
:endgifmoment1
if exist "%temp%\palletforqm.jpg" (del "%temp%\palletforqm.jpg")
if exist "%temp%\%filename%%container%" (del "%temp%\%filename%%container%")
goto end

:: used when an image is set to be deep fried
:fried
:: skip the questions if in multiqueue
if not a%2 == a (
    set level=%5
    goto skipq3
)
set /p "level=How fried do you want the image or gif, [93mfrom 1-10[0m: "
choice /m "Do you want the built-in color changes that come with frying?"
if %errorlevel% == 2 (
    set "fryfilter=noise=alls=%level%*2"
    set "sep=r,"
    set frich=1
)
call :clearlastprompt
:skipq3
echo [38;2;254;165;0mEncoding...[0m
echo.
if not 1%frich% == 11 (
    set "fryfilter=eq=saturation=2.5:contrast=%level%,noise=alls=%level%*2"
    set "sep=r,"
)
:: not in order but, but this makes a noise map in 1/10 size, scales it to the final sizxe, makes a pallete of colors to use, scales down the input to the final size and uses the set amount of colors, and displaces the input with the noise map and does the color stuff and bitrate stuff
set /a desiredwidth=((%width%/%imagesc%)/2)*2
set /a smallwidth=((%desiredwidth%/10)/2)*2
set /a smallheight=((%desiredheight%/10)/2)*2
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=1 -frames:v 1 -vf "noise=allf=t:alls=%level%*2:all_seed=%random%,eq=contrast=%level%*%level%" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -vf scale=%desiredwidth%:%desiredheight%:flags=%scalingalg% "%temp%\noisemapscaled.png"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -vf palettegen=max_colors=%pallete% -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -i pipe: -filter_complex "paletteuse,scale=%desiredwidth%:%desiredheight%" "%temp%\scaledinput%imagecontainer%"
if %imagecontainer% == .gif goto gifmoment
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i "%temp%\scaledinput%imagecontainer%" -i "%temp%\noisemapscaled.png" -i "%temp%\noisemapscaled.png" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate%/%level% -pix_fmt yuv410p -filter_complex "split,displace=edge=wrap,scale=%desiredwidth%:%desiredheight%:flags=neighbo%sep%%fryfilter%" "%filename%%imagecontainer%"
set outputvar="%cd%\%filename%%imagecontainer%"
:endgifmoment
if exist "%temp%\noisemapscaled.png" (del "%temp%\noisemapscaled.png")
if exist "%temp%\scaledinput%imagecontainer%" (del "%temp%\scaledinput%imagecontainer%")
if exist "%temp%\palletforqm.jpg" (del "%temp%\palletforqm.jpg")
goto end

:: specific settings used for gif since you need -f gif - used for frying gifs
:gifmoment
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i "%temp%\scaledinput%imagecontainer%" -i "%temp%\noisemapscaled.png" -i "%temp%\noisemapscaled.png" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate%/%level% -pix_fmt yuv410p -filter_complex "split,displace=edge=wrap,scale=%desiredwidth%:%desiredheight%:flags=neighbo%sep%%fryfilter%" -f gif "%filename%.gif"
set outputvar="%cd%\%filename%.gif"
goto endgifmoment

:: used for not frying gifs
:gifmoment1
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -i "%temp%\palletforqm.jpg" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate% -pix_fmt yuv410p -filter_complex "paletteuse,scale=-2:%desiredheight%:flags=%scalingalg%,noise=alls=%imageq%/4,eq=saturation=(%imageq%/50)+1:contrast=1+(%imageq%/50)" -f gif "%filename%.gif"
set outputvar="%cd%\%filename%.gif"
goto endgifmoment1

:: asks if user wants to fry the video
:videofrying
choice /m "Do you want to fry the video? (will cause extreme distortion)"
if %errorlevel% == 2 call :clearlastprompt
if %errorlevel% == 2 goto :eof
set frying=true
set /p "level=How fried do you want the video, [93mfrom 1-10[0m: "
choice /m "Do you want the built-in color changes that come with frying?"
if %errorlevel% == 2 (
    set levelcolor=10
) else (
    set levelcolor=%level%
)
call :clearlastprompt
goto :eof

:fryingmath
:: sets the amount to shift the video back by, fixing some unwanted effects of displacement)
set /a shiftv=%desiredheight%/4
set /a shifth=%desiredwidth%/24
if %shifth% gtr 255 set shifth=255
if %shiftv% gtr 255 set shiftv=255
set shiftv=-%shiftv%
set shifth=-%shifth%
set /a duration=((%duration%/%speedq%)+5)
set "fryfilter=eq=saturation=(%levelcolor%+24)/25:contrast=%levelcolor%,noise=alls=%level%"
set /a smallwidth=((%desiredwidth%/(%level%*2))/2)*2
set /a smallheight=((%desiredheight%/(%level%*2))/2)*2
if %smallheight% lss 10 set smallheight=10
if %smallwidth% lss 10 set smallwidth=10
goto :eof

:: some extra steps for encoding a fried video, in order:
:: generate noise map at 1/10 resolution, scale the map to final resolution, scale the input to the final resolution, add the input and noise together with displacement, and shift it back into place with rgbashift
:encodefried
echo Frying video...
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=%duration%:r=%outputfps% -vf "noise=allf=t:alls=%level%*10:all_seed=%random%,eq=contrast=%level%*2" -f h264 pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -vf scale=%desiredwidth%:%desiredheight%:flags=%scalingalg% "%temp%\noisemapscaled%container%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %videoinp% -vf "fps=%outputfps%,scale=%desiredwidth%:%desiredheight%:flags=%scalingalg%" -c:a copy "%temp%\scaledinput%container%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i "%temp%\scaledinput%container%" -i "%temp%\noisemapscaled%container%" -i "%temp%\noisemapscaled%container%" -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -c:a copy -filter_complex "split,displace=edge=wrap,fps=%outputfps%,scale=%desiredwidth%x%desiredheight%:flags=%scalingalg%,%fryfilter%" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -c:a copy -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -vf "fps=%outputfps%,rgbashift=rh=%shifth%:rv=%shiftv%:bh=%shifth%:bv=%shiftv%:gh=%shifth%:gv=%shiftv%:ah=%shifth%:av=%shiftv%:edge=wrap" "%temp%\scaledandfriedvideotempfix%container%"
:: use the output of the 5th ffmpeg call as the input for the final encoding
set "videoinp=%temp%\scaledandfriedvideotempfix%container%"
if exist "%temp%\noisemapscaled%container%" (del "%temp%\noisemapscaled%container%")
if exist "%temp%\scaledinput%container%" (del "%temp%\scaledinput%container%")
goto :eof

:: clears the screen up until the title, preventing flashing but keeping the terminal clean
:clearlastprompt
if %cleanmode% == false goto :eof
:: move cursor to saved point, then clear any text after the cursor
echo [H[u[0J
goto :eof

:newline
if %cleanmode% == false echo.
goto :eof

:: provides the user a list of recent announcements from the devs
:announcement
:: checks if github is able to be accessed
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 goto failure
set internet=true
:: grabs the announcements from github
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/announce.txt" --output %temp%\anouncementQM.txt || (
    echo [91mecho Downloading the announcements failed^^! Please try again later.[0m
    echo Press any key to go to the menu
    pause>nul
    call :titledisplay
    goto :eof
)
set /p announce=<%temp%\anouncementQM.txt
echo [38;2;255;190;0mAnnouncements:[0m
for /f "tokens=*" %%s in (%temp%\anouncementQM.txt) do (
    set /a "g+=1"
    echo [38;2;90;90;90m[!g!][0m %%s
)
if exist "%temp%\anouncementQM.txt" del "%temp%\anouncementQM.txt"
echo.
pause
if %cleanmode% == true call :titledisplay
goto :eof

:: fails to access github
:failure
set internet=false
echo [91mAnnouncements were not able to be accessed. Either you are not connected to the internet or GitHub is offline.[0m
pause
if %cleanmode% == false goto :eof
echo [H[u[0J
goto :eof

:: asks if user wants to stutter the video
:stutter
call :newline
:: setting the default amount in case the user doesn't enter a value
set stutteramount=2
choice /m "Do you want to add stutter to the video?"
:: if no, exit the function, if yes, set the variable to y (the variable is only used for error logs)
if %errorlevel% == 2 (
    call :clearlastprompt
    goto :eof
) else (
    set stutter=y
)
echo [93mNote that too much stutter will result in the video playing backwards. It's recommended to stay between 2 and 20.[0m
set /p "stutteramount=How much stutter do you want, [93mfrom 2-512[0m: "
:: random is the name of the filter that stutter uses
set "stutterfilter=,random=frames=%stutteramount%"
call :clearlastprompt
goto :eof

:newmunch
set /p "loopn=Number of times to compress the image [93m(recommended to be at least 10)[0m: "
set /p "qv=[93mOn a scale from 1 to 10[0m, how bad should the quality be? "
set /p "imagesc=[93mOn a scale from 1 to 10[0m, how much should the image be shrunk by? "
set /a qv=(%qv%*3)+1
:: new munching
call :newmunchworking %1 %loopn% %qv% %imagesc%
echo.
echo [92mDone^^![0m
set done=true
goto exiting
exit

:newmunchworking
call :clearlastprompt
echo [38;2;254;165;0mEncoding...[0m
echo.
set loopn=%2
set qv=%3
:: qv*3 is used for webp/vp9, qv is used for -q:v in mjpeg
set /a qv3=%qv%*3
set /a imagesc=%4
set "tempfolder=%temp%\processingvideo"
if not exist "%tempfolder%" goto afterrenamefolder
:renamefolder
set /a "u+=1"
if exist "%tempfolder% %u%" goto renamefolder
set "tempfolder=%tempfolder% %u%"
:afterrenamefolder
mkdir "%tempfolder%"
:: grab width and height of the input video
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %1 -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %1 -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
if exist "%temp%\height.txt" (del "%temp%\height.txt")
if exist "%temp%\width.txt" (del "%temp%\width.txt")
:: basic height scaling and checks to make sure they're even
set /a height=%height%/%imagesc%
set /a height=(%height%/2)*2
set /a width=%width%/%imagesc%
set /a width=(%width%/2)*2
set /a widthalt=%width%-2
set /a heightalt=%height%-2
:: sets containers and encoders depending on if it's a gif or an image
set imagecontainerbackup=%imagecontainer%
set webp=webp
set weblib=libwebp
if %imagecontainer% == .gif (
    set imagecontainer=.mkv
    set webp=webm
    set weblib=libvpx
)
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i %1 -preset ultrafast -vf scale=%width%x%height%:flags=%scalingalg% -c:v mjpeg -q:v %qv% -f mjpeg "%tempfolder%\%~n11%imagecontainer%"
set /a loopnreal=%loopn%-1
:: loop through a few encoders until the loop is over
:startmunch
set /a i+=1
set /a i1=%i%+1
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt yuv410p -c:v libx264 -crf %qv% -f h264 "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto endmunch
del "%tempfolder%\%~n1%i%%imagecontainer%"
set /a i+=1
set /a i1=%i%+1
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%widthalt%x%heightalt%:flags=%scalingalg% -preset ultrafast -pix_fmt yuv422p -c:v mjpeg -q:v %qv% -f mjpeg "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto endmunch
del "%tempfolder%\%~n1%i%%imagecontainer%"
set /a i+=1
set /a i1=%i%+1
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=%scalingalg% -c:v %weblib% -pix_fmt yuv411p -compression_level 0 -quality %qv3% -f %webp% "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto endmunch
del "%tempfolder%\%~n1%i%%imagecontainer%"
goto startmunch
:endmunch
set /a i2=%i1%+1
echo %loopn%/%loopn%
set "filename=%~dpn1 (Quality Munched)"
:: skip the loop if the file already doesn't exist
if not exist "%filename%%imagecontainerbackup%" goto afterrename
:: loop until the file doesn't exist
:renamefileimage
set /a "f+=1"
if exist "%filename% (%f%)%imagecontainerbackup%" goto renamefileimage
set "filename=%filename% (%f%)"
:afterrename
:: if it's a gif, encode it as a video then reencode it to a gif
:: otherwisem encode it as a picture
if %imagecontainerbackup% == .gif (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt rgb24 -c:v libx264 -crf %qv% -f h264 "%tempfolder%\%~n1%i%final%imagecontainer%"
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%final%imagecontainer%" -vf "scale=%width%x%height%:flags=%scalingalg%" -f gif "%filename%%imagecontainerbackup%"
) else (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=%scalingalg% -preset ultrafast -pix_fmt yuv410p -c:v mjpeg -q:v %qv% -f mjpeg "%filename%%imagecontainerbackup%"
)
:notgif
rmdir "%tempfolder%" /q /s
set outputvar="%filename%%imagecontainerbackup%"
goto :eof

:setdefaults
:: default values for variables
set isimage=false
set isupdate=false
set cols=15
set lines=8
set replaceaudio=n
set done=false
set hasvideo=true
set distortaudio=n
set tts=n
set frying=false
set stretchres=n
set colorq=n
set addedtextq=n
set resample=n
set stutter=n
set tcltrue=false
set internet=undetermined
set speedq=1
set audiospeedq=1
set corrupt=n
set wb19=eh_zkfWMiOruV
set trimmed=n
set vidtime=262144
set starttime=0
set musicstarttime=0
set contrastvalue=1
set saturationvalue=1
set brightnessvalue=0
set widthratio=1
set heightratio=1
set forceupdate=false
set spoofduration=false
set durationtype=superlong
set bouncy=false
set "audiofilters="
set "tcl1= "
set "tcl2= "
set "tcl3= "
set "tcl4= "
set "tcl5= "
set "tcl6= "
set "tcl7= "
set "qs=Quality Selected^^!"
set "colorfilter="
goto :eof

:titledisplay
cls
echo [s
cls
if %showtitle% == false goto :eof
echo [38;2;39;55;210m       :^^~~~^^.        ^^.            ^^.       :^^        .^^.           .^^ .~~~~~~~~~~~~~~~: :~            .~.
echo [38;2;39;61;210m    ^^!5GP5YYY5PPY^^^^    :@?           :@J      :#@7       ~@^^!           Y^&..JYYYYYY@BJYYYYY^^! ^^!BG~        .?#P:
echo [38;2;40;68;209m  ~BG7:       :?BG:  ^^^^@J           :@Y     .BB5@~      ^^!@^^!           Y@:       .@Y          7BG~    .?#G~
echo [38;2;40;74;209m 7@J            .5^&^^^^ ^^^^@J           :@J     P^&: P^&:     ^^!@^^!           Y@:       :@Y            7BG~.?#G~
echo [38;2;41;81;209m:^&5               BB :@J           :@J    Y@^^^^  .B#.    ^^!@^^!           Y@:       :@Y              7B^&G~
echo [38;2;41;87;209m~@7               5@.:@J           :@Y   ?@^^!    :^&G    ^^!@^^!           Y@:       :@Y               ?@:
echo [38;2;42;94;208m.#G              .^&P :@J           :@J  ^^!@?      ^^^^@5   ^^!@^^!           Y@:       :@Y               ?@^^^^
echo [38;2;42;100;208m ^^^^^&P:           .B#.  5^&^^^^          P^&: ^^^^@Y        ^^!@J  ^^!@^^!           Y@:       :@Y               ?@^^^^
echo [38;2;43;107;208m  .YB5^^!:.   . ^^!^^!:Y^&^^!   Y#5~.   .^^^^?BG^^^^ :^&P          ?@7 ^^!@7           Y@:       :@Y               ?@^^^^
echo [38;2;43;113;207m    .7YPPPPPP*^^!YPP^&@7   :?5PPPPPPY~   5G.           YB.^^^^#GPPPPPPPPPJ ?B.       .B?               7#:
echo [38;2;44;120;207m         ...     .^^^^?^^!       ....      .              .   ...........                              .
echo [38;2;44;126;207m ^^.            ^^. :.            :. ::            :.       .:^^~~^^:     .:            .:     :~~~~~~~~~^^ .^^~~~~~~~~^^:
echo [38;2;45;133;207m~@#^^!         ~B@^^!:@?           :^&J #^&J          .#5    :?PP5YYY5PG57. 7@^^^^           7@^^^^ .YGPYYYYYYYYY? J@5YYYYYYY5PG?.
echo [38;2;45;139;206m~@P#P:     :P#5@^^!:@J           :@Y ^&BGB~        .^&P  .Y#Y~.      .^^!PY ?@^^^^           ?@^^^^.#B:            J@:         ^^^^BB.
echo [38;2;46;146;206m~@^^!.5^&J  .J^&Y.~@^^!:@J           :@Y ^&5 ?#P:      .^&P .BB:              ?@^^^^           7@^^^^~@^^!             J@:          ?@^^^^
echo [38;2;46;152;206m~@7  ~BB~JP^^^^  ~@^^!:@J           :@Y ^&P  .5^&J     .^&P 5@:               ?@~.:::::::::.J@^^^^~@7.::::::::.   J@:...:::::~J#Y
echo [38;2;47;159;205m~@7    ?P:    ~@^^!:@J           :@Y ^&P    ~BB~   .^&P BB                ?@G5PPPPPPPPP5B@^^^^~@G55555555P?   J@^^^^Y^&^&G55555?:
echo [38;2;47;165;205m~@7           ~@^^!:@J           :@J ^&P      ?#P: .^&P J@^^^^               ?@^^^^           ?@^^^^~@^^!             J@: ~5B5^^^^
echo [38;2;48;172;205m~@7           ~@7 P^&^^^^          5@^^^^ ^&P       .5^&?.^&P  P^&~            . ?@^^^^           ?@^^^^~@^^!             J@:   :?BG7.
echo [38;2;48;178;205m^^!@7           ~@7  Y#Y^^^^.    :7GB^^^^ .^&P         ~GB@P   ?BP7:.    .^^^^?G5 ?@^^^^           ?@^^^^~@^^!             J@:      ^^!PBY^^^^
echo [38;2;49;185;204m^^^^#^^!           ^^^^^&~   :JPPP5PPPY^^!    BY           7#Y    .^^!YPPP55PPPJ~  7#:           ^^!#:^^^^^&G55555555555J ?#:        :JB?
echo [38;2;49;191;204m .             .       ..::.                               .::::.      .             .  .::::::::::::.  .            .[0m
echo.[s
goto :eof

:ending
if %animate% == true goto closingbar