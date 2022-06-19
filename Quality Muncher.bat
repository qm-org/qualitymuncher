:: This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
:: This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
:: You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

:: made by Frost#5872
:: https://github.com/qm-org/qualitymuncher

@echo off
:: OPTIONS - THESE RESET AFTER UPDATING SO KEEP A COPY SOMEWHERE
:: you can see a list of the defaults at the start of the version on the GitHub page or by downloading the file again
     :: automatic update checks, highly recommended to keep this enabled
     set autoupdatecheck=true
     :: saves a log after rendering, useful for debugging
     set log=false
     :: stay open after the file is done rendering
     set stayopen=true
     :: always asks for resample, no matter what (unless you're using multiqueue)
     set alwaysaskresample=false
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
     :: speed at which the ffmpeg stats update, lower is faster
     set updatespeed=0.05
     :: the video container, uses .mp4 as default (don't forget the dot!)
     set container=.mp4
     :: the container for audio, uses .mp3 as default
     set audiocontainer=.mp3
     :: the image container, uses .jpg as default
     set imagecontainer=.jpg
:: END OF OPTIONS

:: warning: if you mess with stuff after this things might break
:: sets a ton of variables that are used later
if check%1 == check goto dircheck
set inpath=%~dp1
set inpath=%inpath:~0,-1%
if not "%cd%" == "%inpath%" cd /d %inpath%
:dircheck
set isimage=false
set version=1.4.4
set isupdate=false
:: if less than 2 parameters (not multiqueue), set the title
if check%2 == check title Quality Muncher v%version%
set inpcontain=%~x1
:: set animate and always ask resample to false if more than 1 parameter (multiqueue)
if not check%2 == check set animate=false&set alwaysaskresample=false&set showtitle=false
:: variables to be used later
set cols=15
set lines=8
set yeahlowqual=n
set done=false
set nonoglobalspeed=false
set hasvideo=true
set bassboosted=n
set tts=n
set frying=false
set stretchres=n
set colorq=n
set addedtextq=n
set interpq=n
set resample=n
set stutter=n
set "qs=Quality Selected!"
if %1p == qmloop goto colorstart
if %animate% == true call :loadingbar
:: don't display title in multiqueue
if not check%2 == check goto verystart
call :titledisplay
:: checks for updates
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
if %autoupdatecheck% == true goto updatecheck
:: sets more variables to be used later
:verystart
:: checks if ffmpeg is installed, and if it isn't, it'll send a tutorial to install it. 
where /q ffmpeg
if %errorlevel% == 1 (
     echo [91mERROR: You either don't have ffmpeg installed or don't have it in PATH.[0m
     echo Please install it as it's needed for this program to work.
     choice /n /c gc /m "Press [G] for a guide on installing it, or [C] to close the script."
     if %errorlevel% == 1 start "" https://www.youtube.com/watch?v=WwWITnuWQW4
     goto closingbar
)
set confirmselec=n
:: checks for inputs, if no input tell them and send to a secondary main menu
if %1check == check goto noinput
:: checks if the input has a video stream (i.e. if the input is an audio file) and if there isn't a video stream, ask audio questions instead
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
if "%~x1" == ".gif" set imagecontainer=.gif&goto imagemunch
:: intro, questions and defining variables
:: asks advanced or simple version
set complexity=s
if not check%2 == check goto skipped
:: main menu options
:modeselect
echo Press [S] for simple, [A] for advanced, [W] to open the website, [D] to join the discord server, [P] to make a
echo suggestion or bug report, [U] to check for updates, [N] to view announcements, or [C] to close.
choice /n /c SAWDCPGJMUN
call :newline
call :clearlastprompt
:: determines where to send the user - if advanced, asks for the start time and duration
if %errorlevel% == 2 set complexity=a& echo [96mAdvanced mode selected![0m&goto afterall
if %errorlevel% == 3 goto website
if %errorlevel% == 4 goto discord
if %errorlevel% == 5 goto closingbar
if %errorlevel% == 6 goto suggestion
if %errorlevel% == 7 goto thing1
if %errorlevel% == 8 goto thing2
if %errorlevel% == 9 goto thing3
if %errorlevel% == 10 goto updatecheck
if %errorlevel% == 11 call :announcement&goto verystart
:: only sends this if simple is selected
echo [96mSimple mode selected![0m
set complexity=s
:afterall
echo Your options for quality are decent [1], bad [2], terrible [3], unbearable [4], custom [C], or random [R].
choice /n /c 1234CR
call :clearlastprompt
set customizationquestion=%errorlevel%
if %customizationquestion% == 5 set customizationquestion=c
if %customizationquestion% == 6 set customizationquestion=r&goto random
:skipped
if 1%2 == 1 goto skipcustommultiqueue
set customizationquestion=%2
if not %2 == c goto skipcustommultiqueue
if %2 == c (
     echo Custom %qs%
     set framerate=%3
     set videobr=%4
     set audiobr=%5
     set scaleq=%6
     if %7 == 1 set details=y
     set endingmsg=Custom Quality
     goto setendingmsg
)
:skipcustommultiqueue
if %customizationquestion% == 6 set customizationquestion=r&goto random
:: defines a few variables that will be replaced later, this is important for checking if they're valid as it prevents missing operand (undefined variable) errors
set framerate=a
set videobr=a
set audiobr=a
set scaleq=a
set details=n
:: sets the quality based on customizationquestion
:: endingmsg is added to the end of the video for the output name
if "%customizationquestion%" == "c" echo Custom %qs%
:customquestioncheckpoint
if %customizationquestion% == 6 set customizationquestion=r&goto random
if %customizationquestion% == r goto random
if "%customizationquestion%" == "c" (
     set /p "framerate=What fps do you want it to be rendered at: "
     set /p "videobr=[93mOn a scale from 1 to 10[0m, how bad should the video bitrate be? 1 bad, 10 very very bad: "
     set /p "audiobr=[93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad: "
     set /p "scaleq=[93mOn a scale from 1 to 10[0m, how much should the video be shrunk by? 1 none, 10 a lot: "
     choice /m "Do you want a detailed file name for the output?"
     set endingmsg=Custom Quality
)
if "%customizationquestion%" == "c" (
     if %errorlevel% == 1 set details=y
)
if %customizationquestion% == 1 (
     echo.
     echo [96mDecent %qs%[0m
     set framerate=24
     set videobr=3
     set scaleq=2
     set audiobr=3
     set endingmsg=Decent Quality
)
if %customizationquestion% == 2 (
     echo.
     echo [96mBad %qs%[0m
     set framerate=12
     set videobr=5
     set scaleq=4
     set audiobr=5
     set endingmsg=Bad Quality
)
if %customizationquestion% == 3 (
     echo.
     echo [96mTerrible %qs%[0m
     set framerate=6
     set videobr=8
     set scaleq=8
     set audiobr=8
     set endingmsg=Terrible Quality
)
if %customizationquestion% == 4 (
     echo.
     echo [96mUnbearable %qs%[0m
     set framerate=1
     set videobr=16
     set scaleq=12
     set audiobr=9
     set endingmsg=Unbearable Quality
)
:: if custom quality is selected, checks if the variables are all whole numbers, if they aren't it'll ask again for their values
if not %customizationquestion% == c goto setendingmsg
set errormsg=[91mOne or more of your inputs for custom quality was invalid! Please use only numbers![0m
if not "%framerate%"=="%framerate: =%" goto errorcustom
if not "%videobr%"=="%videobr: =%" goto errorcustom
if not "%audiobr%"=="%audiobr: =%" goto errorcustom
if not "%scaleq%"=="%scaleq: =%" goto errorcustom
set /a testforfps=%framerate%
set /a testforvideobr=%videobr%
set /a testforaudiobr=%audiobr%
set /a testforscaleq=%scaleq%
if not %testforfps% == %framerate% goto errorcustom
if not %testforvideobr% == %videobr% goto errorcustom
if not %testforaudiobr% == %audiobr% goto errorcustom
if not %testforscaleq% == %scaleq% goto errorcustom
:: grabs info from video to be used later (duration, dimensions, and framerate)
:setendingmsg
if %complexity% == a (call :durationquestions) else call :clearlastprompt
ffprobe -i %inputvideo% -show_entries format=duration -v quiet -of csv="p=0" > %temp%\fileduration.txt
set /p duration=<%temp%\fileduration.txt
set /a "duration=%duration%" > nul 2> nul
if exist "%temp%\fileduration.txt" (del "%temp%\fileduration.txt")
ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -i %inputvideo% -of csv=p=0 > %temp%\fps.txt
set /p fpsvalue=<%temp%\fps.txt
if exist "%temp%\fps.txt" (del "%temp%\fps.txt")
set /a fpsvalue=%fpsvalue%
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
if exist "%temp%\height.txt" (del "%temp%\height.txt")
if exist "%temp%\width.txt" (del "%temp%\width.txt")
:: finds the output height and makes sure it's an even number (divisable by two)
:: this works because batch doesn't support floats (decimals)
set /a desiredheight=%height%/%scaleq%
set /a desiredheight=(%desiredheight%/2)*2
set /a desiredwidth=%width%/%scaleq%
set /a desiredwidth=(%desiredwidth%/2)*2
:: makes the endingmsg more detailed if it's been selected (only available in the custom preset)
if /I %details% == y set "endingmsg=Custom Quality - %framerate% fps, %videobr% video bitrate input, %audiobr% audio bitrate input, %scaleq% scale"
:: speed and on-screen text questions (advanced mode only)
if not %complexity% == s goto speedandtextquestions
:afterspeedandtextquestions
:: Sets the audiobr (should be noted that audio bitrate is in thousands, unlike video bitrate)
set /a badaudiobitrate=80/%audiobr%
:: asks color questions, streching, and audio replacement (advanced mode only)
if NOT %complexity% == s goto colorandstretchquestions
:aftercolorandstretchquestions
if %complexity% == s set stretchres=n
if %stretchres% == n goto filters
:: setting the width to match the aspect ratio (from the stretch questions)
:: in the words of the great vladaad, "fucking batch doesn't know what a float is"
set /a "widthmod=(%desiredwidth%*%widthratio%) %% %heightratio%"
set /a "desiredwidth=((%desiredwidth%*%widthratio%)+%widthmod%)/%heightratio%"
set /a desiredwidth=(%desiredwidth%/2)*2
:: setting font size again to account for stretch
if %addedtextq% == n goto filters
set /a fontsize=(%desiredwidth%/%strlength%)*2
set /a fontsizebottom=(%desiredwidth%/%strlengthb%)*2
:fontcheck
set /a triplefontsize=%fontsize%*3
if %triplefontsize% gtr %desiredheight% set /a fontsize=%fontsize%-5&goto fontcheck
:fontcheck2
set /a triplefontsizebottom=%fontsizebottom%*3
if %triplefontsizebottom% gtr %desiredheight% set /a fontsizebottom=%fontsizebottom%-5&goto fontcheck2
set "textfilter=drawtext=borderw=(%fontsize%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%toptext%':fontcolor=white:fontsize=%fontsize%:x=(w-text_w)/2:y=(0.25*text_h),drawtext=borderw=(%fontsizebottom%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%bottomtext%':fontcolor=white:fontsize=%fontsizebottom%:x=(w-text_w)/2:y=(h-1.25*text_h),"
:filters
:: asks about resampling - if simple mode is on/input fps is under output fps, will come back without asking (unless always ask resample is one)
goto resamplequestion
:afterresamplequestion
call :clearlastprompt
:: if framerate input is less than output, asks if the user wants to interpolate (advanced mode only)
set interpq=n
if NOT %complexity% == s (
     if %framerate% gtr %fpsvalue% (
          choice /c YN /m "The framerate of your input exceeds the framerate of the output. Interpolate to fix this?"
          if %errorlevel% == 1 set interpq=y
          call :newline&call :clearlastprompt
     )
)
:: setting bitrate
set /a badvideobitrate=(%desiredheight%/2*%desiredwidth%*%framerate%/%videobr%)
:: minimum bitrate in libx264 is 1000, so set it to 1000 if it's under
if %badvideobitrate% LSS 1000 set badvideobitrate=1000
:: audio distortion questions (advanced mode only)
set "audiofilters="
if NOT %complexity% == s goto audiodistortion
:encoding
:: if simple mode, skip video frying
if %complexity% == s goto encoding2
set videoinp=%1
goto videofrying
:encoding2
call :newline
:: text to speech questions (advanced mode only)
if NOT %complexity% == s call :voicesynth
:: stutter questions (advanced mode only)
if NOT %complexity% == s call :stutter
:: video filters
:: sets filters for fps
set "fpsfilter=fps=%framerate%,"
if %interpq% == y set "fpsfilter=minterpolate=fps=%framerate%,"
if %resample% == y set "fpsfilter=tmix=frames=%tmixframes%:weights=1,fps=%framerate%,"
:: actual filters
set filters=-filter_complex "scale=%desiredwidth%:%desiredheight%:flags=neighbor,setsar=1:1,%textfilter%%fpsfilter%%speedfilter%format=yuv410p%stutterfilter%"
if %colorq% == y (
     set filters=-filter_complex "scale=%desiredwidth%:%desiredheight%:flags=neighbor,setsar=1:1,%textfilter%%fpsfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,format=yuv410p%stutterfilter%"
)
:: if simple mode, only use this filter
if %complexity% == s set filters=-vf "%fpsfilter%scale=%desiredwidth%:%desiredheight%:flags=neighbor,format=yuv410p"
:: sets logs (for debugging only, disabled by default)
:: uses a variety of variables to save space since there are different values stored for different options (simple, advanced, etc)
if %log% == false goto setfilename
set lo1=-metadata comment="Made with Quality Muncher v%version% - https://github.com/qm-org/qualitymuncher"
set lo2=-metadata "Quality Muncher Info"=
set lo3=Complexity %complexity%, option %customizationquestion%
set lo4=Input had a width of %width% and a height of %height%. The final bitrates were %badvideobitrate% for video and %badaudiobitrate%000 for audio. Final scale was %desiredwidth% for width and %desiredheight% for height and resample was set to %resample%.
set lo5=fps %framerate%, video bitrate %videobr%, audio bitrate %audiobr%, scaleq %scaleq%, details %details%
set lo6=start %starttime%, duration %time%, speed %speedq%, color %colorq%, interpolated %interpq%, stretched %stretchres%, distorted audio %bassboosted%, added audio %lowqualmusicquestion%, added text %addedtextq%.
:: actually setting the metadata variable
if not %complexity% == s goto advancedmeta
set metadata=%lo1% %lo2%"%lo3%. %lo4%"
if %customizationquestion% == c set metadata=%lo1% %lo2%"%lo3%, %lo5%. %lo4%"
goto setfilename
:advancedmeta
:: metadata used for advanced options
set metadata=%lo1% %lo2%"%lo3%, %lo6% %lo4%"
if %customizationquestion% == c set metadata=%lo1% %lo2%"%lo3%, %lo5%, %lo6% %lo4%"
:: sets the file name
:setfilename
set "filename=%~n1 (%endingmsg%)"
:: asks if the user wants a custom output name
if not %complexity% == s goto outputquestion
:outputcont
:: if the output already exists, add a (1), and if that exists, make it (2), etc
if exist "%filename%%container%" goto renamefile
:: prints log (for debugging only, disabled by default)
if %log% == true echo %metadata% > "%~dpn1 (%endingmsg%) log.txt"
call :clearlastprompt
echo [38;2;254;165;0mEncoding...[0m & echo.
if %complexity% == s goto optionthree
:: if the user selected to fry the video, encode all of the needed parts (probably will switch to using pipe at some point, but this works for now)
if %frying% == true goto encodefried
:encodenormal
if %yeahlowqual% == n goto optionone
goto optiontwo
:: option one, no extra music
:optionone
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %time% -i %videoinp% ^
%filters% %audiofilters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
set outputvar="%cd%\%filename%%container%"
goto end
:: option two, there is music
:optiontwo
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel warning -stats ^
-ss %starttime% -t %time% -i %videoinp% -ss %musicstarttime% -i %lowqualmusic% ^
%filters% %audiofilters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
set outputvar="%cd%\%filename%%container%"
goto end
:: option three, simple mode only, no audio filters
:optionthree
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-i %1 ^
%filters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
set outputvar="%cd%\%filename%%container%"
:end
:: if text to speech, encode the voice and merge
if %hasvideo% == false goto skipvoice
if "%tts%"=="y" call :encodevoice
:skipvoice
echo. & echo [92mDone![0m
set done=true
if exist "%temp%\scaledandfriedvideotempfix%container%" (del "%temp%\scaledandfriedvideotempfix%container%")
if %stayopen% == false goto ending
if 1%2 == 1 goto exiting
if not check%2 == check goto ending

:: advanced parts - most of the following code isn't read when using simple mode

:: audio distortion questions
:audiodistortion
set "audiospeedq=%speedq%"
if %nonoglobalspeed% == true set audiospeedq=1
choice /c YN /m "Do you want to distort the audio (earrape)?"
if %errorlevel% == 1 set bassboosted=y&goto skipno
:: if no, checks if speed is something other than one, and if it is, set audiofilters so the audio syncs and then goes to encoding
:: the "hasvideo" variable is false if you're using an audio file
if %bassboosted% == n (
     set "audiofilters="
     if NOT %audiospeedq% == 1 set "audiofilters=-af atempo=%audiospeedq%"
     echo.
     call :clearlastprompt
     if %hasvideo% == false goto nextaudiostep2
     goto encoding
)
:skipno
:: sends the user to the method they choose
choice /n /c 12 /m "Which distortion method should be used, old [1] or new [2]?"
if %errorlevel% == 1 goto classic
if %errorlevel% == 2 goto newmethod
:: new method - boosts frequencies, swaps channels, adds echo and delay
:newmethod
set /p "distortionseverity=How distorted should the audio be, [93m1-10[0m: "
set /a distsev=%distortionseverity%*10
set /a bb1=0
set /a bb2=(%distsev%*25)
set /a bb3=2*(%distsev%*25)
set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%^|%bb2%^|%bb3%,channelmap=1^|0,aecho=0.8:0.3:%distsev%*2:0.9"
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %audiospeedq% == 1 (
     set "audiofilters=-af atempo=%audiospeedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%^|%bb2%^|%bb3%,channelmap=1^|0,aecho=0.8:0.3:%distsev%*2:0.9"
)
call :clearlastprompt
if %hasvideo% == false goto nextaudiostep2
call :newline & goto encoding
:: old method - just boosts frequencies
:classic
set /p "distortionseverity=How distorted should the audio be, [93m1-10[0m: "
set /a distsev=%distortionseverity%*10
set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %audiospeedq% == 1 (
     set "audiofilters=-af atempo=%audiospeedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
)
call :clearlastprompt
if %hasvideo% == false goto nextaudiostep2
goto encoding


:: speed settings/questions
:speedandtextquestions
set speedvalid=n&set speedq=default
call :newline
set /p "speedq=What should the playback speed of the video be, [93mmust be a positive number between 0.5 and 100[0m, default is 1: "
if not "%speedq%"=="%speedq: =%" set speedq=default
if "%speedq%" == "n" set speedq=1
if %speedvalid% == y goto cont
set string=%speedq%
for /f "delims=." %%a in ("%string%") do if NOT "%%a"=="%string%" set speedvalid=y
if %speedvalid% == y goto cont
set /a speedqCheck=%speedq%
if NOT %speedqCheck% == %speedq% (set speedvalid=n) else (set speedvalid=y)
if %speedvalid% == n set speedq=default
:cont
:: speed is default if no value is given or the value given is not a number
if %speedq% == default (
     echo [91mNo valid input given, speed has been set to default.[0m
     set speedvalid=y
     set speedq=1
     goto cont
)
set speedfilter="setpts=(1/%speedq%)*PTS,"
set speedfilter=%speedfilter:"=%
if %hasvideo% == false call :clearlastprompt&goto nextaudiostep1
echo Should the audio speed stay the same, regardless of the video speed? [93m(Default: N)[0m [Y,N]?
choice /n
if %errorlevel% == 2 set noglobalspeed=true
call :clearlastprompt
:addtext
call :newline
:: asks if they want to add text
choice /c YN /m "Do you want to add text to the video?"
if %errorlevel% == 1 set addedtextq=y
if %addedtextq% == n set "textfilter="
if %addedtextq% == n goto afterspeedandtextquestions
:: top text
set "toptext= "
set /p toptext=Top text: 
:: lots of stuff here, but basically uses the length of the text and the size of the video to figure out the font size to use so nothing clips
set toptextnospace=%toptext: =_%
echo "%toptextnospace%" > %temp%\toptext.txt
for %%? in (%temp%\toptext.txt) do ( set /a strlength=%%~z? - 2 )
if %strlength% LSS 16 set strlength=16
set /a fontsize=(%desiredwidth%/%strlength%)*2
:: bottom text - same stuff as top text but with different variable names
set "bottomtext= "
set /p bottomtext=Bottom text: 
set bottomtextnospace=%bottomtext: =_%
echo "%bottomtextnospace%" > %temp%\bottomtext.txt
for %%? in (%temp%\bottomtext.txt) do ( set /a strlengthb=%%~z? - 2 )
if %strlengthb% LSS 16 set strlengthb=16
set /a fontsizebottom=(%desiredwidth%/%strlengthb%)*2
:: setting text filter
if exist "%temp%\toptext.txt" (del "%temp%\toptext.txt")
if exist "%temp%\bottomtext.txt" (del "%temp%\bottomtext.txt")
set "textfilter=drawtext=borderw=(%fontsize%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%toptext%':fontcolor=white:fontsize=%fontsize%:x=(w-text_w)/2:y=(0.25*text_h),drawtext=borderw=(%fontsizebottom%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%bottomtext%':fontcolor=white:fontsize=%fontsizebottom%:x=(w-text_w)/2:y=(h-1.25*text_h),"
call :clearlastprompt
goto afterspeedandtextquestions


:colorandstretchquestions
call :newline
call :clearlastprompt
:: questions about modifying video color
set contrastvalue=1 & set saturationvalue=1 & set brightnessvalue=0
choice /c YN /m "Do you want to customize saturation, contrast, and brightness?"
if %errorlevel% == 1 set colorq=y
:: prompts for specific values
if %colorq% == y (
     set /p "contrastvalue=Select a contrast value [93mbetween -1000.0 and 1000.0[0m, default is 1: "
     set /p "saturationvalue=Select a saturation value [93mbetween 0.0 and 3.0[0m, default is 1: "
     set /p "brightnessvalue=Select a brightness value [93mbetween -1.0 and 1.0[0m, default is 0: "
)
:: tests if the values contain invalid characters
if %colorq% == y (
     if not "%contrastvalue%"=="%contrastvalue: =%" set contrastvalue=1
     if not "%saturationvalue%"=="%saturationvalue: =%" set set saturationvalue=1
     if not "%brightnessvalue%"=="%brightnessvalue: =%" set brightnessvalue=0
     for /f "tokens=1* delims=-.0123456789" %%j in ("j0%contrastvalue:"=%") do (if not "%%k"=="" set contrastvalue=1)
     for /f "tokens=1* delims=.0123456789" %%l in ("l0%saturationvalue:"=%") do (if not "%%m"=="" set saturationvalue=1)
     for /f "tokens=1* delims=-.0123456789" %%n in ("n0%brightnessvalue:"=%") do (if not "%%o"=="" set brightnessvalue=0)
)
:stretch
call :newline
call :clearlastprompt
:: asks about stretching the video - doesn't set the actual resolution since that's done after
choice /c YN /m "Do you want to stretch the video?"
if %errorlevel% == 1 (set stretchres=y) else (call :clearlastprompt&goto lowqualmusicq)
set widthratio=1
set heightratio=1
echo [93mUse only whole numbers.[0m
set /p "widthratio=How stretched should be width be? [93mDefault is 1 (no stretch)[0m: "
set /p "heightratio=How stretched should be height be? [93mDefault is 1 (no stretch)[0m: "
set "aspectratio=%widthratio%/%heightratio%"
call :clearlastprompt
:: asks if they want music and if so, the file to get it from and the start time
:lowqualmusicq
set musicstarttime=0 & set musicstartest=0 & set lowqualmusicquestion=n & set filefound=y
call :newline
choice /c YN /m "Do you want to add music?"
if %errorlevel% == 1 (set lowqualmusicquestion=y) else (call :clearlastprompt&goto aftercolorandstretchquestions)
:addingthemusic
:: asks for a specific file to get music from
set yeahlowqual=y
set /p lowqualmusic=Please drag the desired file here, [93mit must be an audio/video file[0m: 
:: if it's not a valid file it sends the user back to input a valid file
if not exist %lowqualmusic% call :clearlastprompt&echo [91mInvalid file! Please drag an existing file from your computer![0m &goto addingthemusic
:: asks the user when the music should start
set /p "musicstarttime=Enter a specific start time of the music [93min seconds[0m: "
call :clearlastprompt
goto aftercolorandstretchquestions

:: asks about resampling (skips if in simple mode, input fps is less than output, and stays if those are false)
:: always stays if alwaysaskresample is true in options, even if using simple mode
:resamplequestion
if %alwaysaskresample% == true goto bypassnoresample
if "%complexity%" == "s" goto afterresamplequestion
if not %fpsvalue% gtr %framerate% goto afterresamplequestion
:bypassnoresample
call :newline
choice /c YN /m "Do you want to resample frames? This will look like motion blur, but will take longer to render."
call :newline
call :clearlastprompt
if %errorlevel% == 1 set resample=y
if %resample% == n goto afterresamplequestion
:: determines the number of frames to blend together per frame (does not use decimals/floats because batch is like that)
set tmixframes=(%fpsvalue%/%framerate%)
set /a tmixcheck=%tmixframes%
if %tmixcheck% gtr 128 set tmixframes=128
goto afterresamplequestion

:: the start of advanced mode, despite the name being "advanced four"
:durationquestions
call :clearlastprompt
:: asks where to start clip
:startquestion
set starttime=0
set /p "starttime=[93mIn seconds[0m, where do you want your clip to start: "
if "%starttime%" == " " set starttime=0
:: asks length of clip
:timequestion
set time=32727
set /p "time=[93mIn seconds[0m, how long after the start time do you want it to be: "
if "%time%" == " " set time=32727
call :clearlastprompt
if %hasvideo% == false goto backtoaudio
goto :eof

:: text to speech
:voicesynth
choice /m "Do you want to add text-to-speech?"
if %errorlevel% == 1 set tts=y
if %errorlevel% == 2 call :clearlastprompt&goto :eof
echo What do you want the text-to-speech to say?
set /p "ttstext="
set volume=0
set /p "volume=How much should the volume of the text-to-speech be boosted by (in dB)? Default is 0: "
call :clearlastprompt
goto :eof

:: combines text to speech with output
:encodevoice
set "af2="
if not "%audiofilters%e" == "e" set "af2=,%audiofilters:-af =%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i anullsrc -filter_complex "flite=text='%ttstext%':voice=kal16%af2%,volume=%volume%dB"  -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%container%" -movflags +use_metadata_tags -map_metadata 1 -c:v copy -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename% tts%container%"
if exist "%filename%%container%" (del "%filename%%container%")
set outputvar="%cd%\%filename% tts%container%"
goto :eof

:: if discord is selected from the menu, it sends the user to discord, clears the console, and goes back to start
:discord
echo [96mSending to Discord![0m & start "" https://discord.com/invite/9tRZ6C7tYz & call :clearlastprompt&goto verystart

:: if the website is selected from the menu, it sends the user to the website, clears the console, and goes back to start
:website
echo [96mSending to website![0m & start "" https://qualitymuncher.lgbt/ & call :clearlastprompt&goto verystart

:: suggestions
:suggestion
set wbhs=OllG_GUEX4SXN7RRqu-xLdS
:: checks for a connection to discord
call :clearlastprompt
ping /n 1 discord.com  | find "Reply" > nul
if %errorlevel% == 1 echo [91mSorry, either discord is down or you're not connected to the internet. Please try again later.[0m&echo.&pause&call :clearlastprompt&goto verystart
:: asks information about the suggestion
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
if %errorlevel% == 2 call :clearlastprompt&echo [91mOkay, your suggestion has been cancelled.[0m&echo.&pause&call :clearlastprompt&goto verystart
:continuesuggest
:: please do not spam this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New suggestion!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/webhooks/973701372128157776/A-TFFPzP-hfWR-W2Tu%wbhs%JgcgoQF6_x-GkwrMxDahw5g_aFE
call :clearlastprompt
echo [92mYour suggestion has been successfully sent to the developers![0m &echo.&pause&call :clearlastprompt&goto verystart

:bugreport
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
if %errorlevel% == 1 goto continuebug
if %errorlevel% == 2 call :clearlastprompt
if %errorlevel% == 2 echo [91mOkay, your suggestion has been cancelled.[0m&echo.&pause&call :clearlastprompt&goto verystart
:continuebug
:: please do not spam this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New bug report!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/webhooks/973701372128157776/A-TFFPzP-hfWR-W2Tu%wbhs%JgcgoQF6_x-GkwrMxDahw5g_aFE
call :clearlastprompt
echo [92mYour bug report has been successfully sent to the developers![0m &echo.&pause&call :clearlastprompt&goto verystart

:: go to the main menu and press m to see what this does :)
:thing3
start "" %0 qmloo
call :clearlastprompt&goto verystart
:colorstart
set /p "speedr=Enter a number between 1 and 25: "
set o=0
set /p "startertext=Enter some text: "
:qmloop
set QMT=%QMT%%startertext% 
set QMTnospace=%QMT: =_%
echo "%QMTnospace%" > %temp%\QMTnospace.txt
for %%? in (%temp%\QMTnospace.txt) do ( set /a strlength3=%%~z? - 2 )
if not %strlength3% gtr 120 goto qmloop
set QMT=%QMT:~0,120%
if exist "%temp%\QMTnospace.txt" (del "%temp%\QMTnospace.txt")
cls
set R=255
set G=0
set B=255
:colorpart
echo [38;2;%R%;%G%;%B%m%QMT%[0m
if %R% geq 255 goto red
:redc
if %G% geq 255 goto gre
:grec
if %B% geq 255 goto blu
:bluc
if %R% lss 0 set /a R=0
if %G% lss 0 set /a G=0
if %B% lss 0 set /a B=0
if %R% gtr 255 set /a R=255
if %G% gtr 255 set /a G=255
if %B% gtr 255 set /a B=255
goto colorpart
pause&cls&goto verystart
:red
if not %B% LEQ 0 set /a "B=%B%-%speedr%"
if %B% LEQ 0 set /a "G=%G%+%speedr%"
goto redc
:gre
if not %R% LEQ 0 set /a "R=%R%-%speedr%"
if %R% LEQ 0 set /a "B=%B%+%speedr%1"
goto grec
:blu
if not %G% LEQ 0 set /a "G=%G%-%speedr%"
if %G% LEQ 0 set /a "R=%R%+%speedr%"
goto bluc

:: runs if the user runs the script without using a parameter (i.e. they don't use send to / drag and drop)
:noinput
echo [91mERROR: no input file![0m
echo Press [W] to open the website, [D] to join the discord server, [P] to make a suggestion or bug report, or [C] to close.
echo You can also press [F] to input a file manually, [N] to view announcements, or [U] to check for updates.
choice /n /c WDCFPGJMUN
call :clearlastprompt
set confirmselec=y
if %errorlevel% == 1 goto website
if %errorlevel% == 2 goto discord
if %errorlevel% == 4 goto manualfile
if %errorlevel% == 5 goto suggestion
if %errorlevel% == 6 goto thing1
if %errorlevel% == 7 goto thing2
if %errorlevel% == 8 goto thing3
if %errorlevel% == 9 goto updatecheck
if %errorlevel% == 10 call :announcement&goto verystart
goto closingbar

:: where most things direct to when the program is done - plays a nice sound if possible, pauses, then exits
:exiting
echo.
where /q ffplay || goto aftersound
if %done% == true start /min cmd /c ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound
choice /n /c COFP /m "Press [C] to close, [O] to open the output, [F] to open the file path, or [P] to pipe the output to another script."
if %errorlevel% == 4 goto piped
if %errorlevel% == 2 %outputvar%
if %errorlevel% == 3 explorer /select, %outputvar%
goto closingbar

:: pipe the output
:piped
if %cleanmode% == true call :titledisplay
echo Scripts found:
:: add scripts here, if you want
echo [S] Custom Script
echo [1] FFmpeg
if exist "%~dp0\!add text.bat" echo [2] Add text
if exist "%~dp0\!audio sync.bat" echo [3] Audio sync
if exist "%~dp0\!change fps.bat" echo [4] Change fps
if exist "%~dp0\!change speed.bat" echo [5] Change speed
if exist "%~dp0\!extract frame.bat" echo [6] Extract frame
if exist "%~dp0\!interpolater.bat" echo [7] Interpolater
if exist "%~dp0\!replace audio.bat" echo [8] Replace audio
if exist "%~dp0\!upscale nn.bat" echo [9] Upscale NN
echo.
:: selecting and piping
choice /n /c S123456789C /m "Select a script to pipe to, or press [C] to close: "
if %errorlevel% == 1 goto customscript
cls
if %errorlevel% == 3 cmd /k call "%~dp0\!add text.bat" %outputvar%
if %errorlevel% == 4 cmd /k call "%~dp0\!audio sync.bat" %outputvar%
if %errorlevel% == 5 cmd /k call "%~dp0\!change fps.bat" %outputvar%
if %errorlevel% == 6 cmd /k call "%~dp0\!change speed.bat" %outputvar%
if %errorlevel% == 7 cmd /k call "%~dp0\!extract frame.bat" %outputvar%
if %errorlevel% == 8 cmd /k call "%~dp0\!interpolater.bat" %outputvar%
if %errorlevel% == 9 cmd /k call "%~dp0\!replace audio.bat" %outputvar%
if %errorlevel% == 10 cmd /k call "%~dp0\!upscale nn.bat" %outputvar%
if %errorlevel% == 11 exit
set /p "ffmpeginput=ffmpeg -i %outputvar% "
echo. & echo [38;2;254;165;0mEncoding...[0m & echo.
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %outputvar% %ffmpeginput%
echo. & echo [92mDone![0m
echo.
where /q ffplay || goto aftersound2
if %done% == true start /min cmd /c ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound2
pause
goto closingbar

:customscript
call :newline&call :clearlastprompt
set /p "customscript=Enter the path to the script you want to pipe to: "
cls
cmd /k call %customscript% %outputvar%
goto closingbar

:: if the user inputs a file manually instead of with send to or drag and drop
:manualfile
set /p file=Please drag your input here: 
cls & call %0 %file%
exit

:: checks for updates - done automatically unless disabled in options
:updatecheck
:: checks if github is able to be accessed
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 call :nointernet&goto verystart
set internet=true
:: grabs the version of the latest public release from the github
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/version.txt" --output %temp%\QMnewversion.txt
set /p newversion=<%temp%\QMnewversion.txt
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
:: if the new version is the same as the current one, go to the start
if "%version%" == "%newversion%" (set isupdate=false) else (set isupdate=true)
if not %isupdate% == true goto verystart
:: tells the user a new update is out and asks if they want to update
echo [96mThere is a new version (%newversion%) of Quality Muncher available! & echo Press [U] to update or [S] to skip. & echo [90mTo hide this message in the future, set the variable "autoupdatecheck" in the script options to false.[0m
choice /c US /n
echo. & set isupdate=false
if %errorlevel% == 2 call :clearlastprompt&goto verystart
:: gives the user some choices when updating
echo Are you sure you want to update? This will overwrite the current file!
echo [92m[Y] Yes, update and overwrite.[0m [93m[C] Yes, BUT save a copy of the current file.[0m [91m[N] No, take me back.[0m
choice /c YCN /n
if %errorlevel% == 2 copy %0 "%~dpn0 (OLD).bat"&echo Okay, this file has been saved as a copy in the same directory. Press any key to continue updating. & pause>nul
if %errorlevel% == 3 call :titledisplay&goto verystart
echo.
:: installs the latest public version, overwriting the current one, and running it using this input as a parameter so you don't have to run send to again
curl -s "https://qualitymuncher.lgbt/Quality%%20Muncher.bat" --output %0 & cls & %0 %1
exit

:: runs if there isn't internet (comes from update check)
:nointernet
set internet=false & echo [91mUpdate check failed, skipping.[0m & echo.
goto :eof

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
cls&call :titledisplay&goto verystart
cls
goto verystart

:: scrapped version, will never run unless cls fails or goto verystart fails
:: pretty much just here if i ever want to use this later
cls
set "atz= "
:atzloop
set "atz=%atz%%atz%"
set /a "v+=1"
if %v% lss 7 goto atzloop
set v=0
set atz=%atz:~0,126%
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
cls&goto verystart

:: ran if random preset is selected
:random
set details=n
set min=1
set max=15
echo.
echo [91mR[0m[93ma[0m[92mn[0m[96md[0m[94mo[0m[95mm[0m %qs%
:: %% means modulo/mod, which gives the remainder of that number divided by the next number (random/30 in this case)
set /a framerate=%random% %% 30
set /a videobr=%random% * %max% / 32768 + %min%
set /a scaleq=%random% * %max% / 32768 + %min%
set /a audiobr=%random% * %max% / 32768 + %min%
set endingmsg=Random Quality
goto setendingmsg

:: runs at start of script, just a fun animation (disabled if animations are off)
:loadingbar
mode con: cols=%cols% lines=%lines%
set /a cols=%cols%+%animatespeed%
if not %cols% geq 120 goto loadingbar
set /a animatespeed2=%animatespeed%/5
if %animatespeed2% lss 1 set animatespeed2=1
if not %cols% == 120 set cols=120
:loadingy
mode con: cols=%cols% lines=%lines%
set /a lines=%lines%+%animatespeed2%
if not %lines% geq 30 goto loadingy
if not %lines% == 30 mode con: cols=%cols% lines=30
:: runs powershell to set the buffer size to allow users to scroll back up when wanted
powershell -noprofile -command "&{(get-host).ui.rawui.buffersize=@{width=120;height=9901};}"
goto :eof

:: almost the same as loading bar but runs on exit (disabled if animations are off)
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
if %errorlevel% == 2 echo.&call :clearlastprompt
if %errorlevel% == 2 goto outputcont
set /p "filenametemp=Enter your output name [93mwith no extension[0m: "
set "filename=%filenametemp%"
echo.&goto outputcont

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
call :clearlastprompt
goto startquestion
:backtoaudio
choice /m "Adjust audio speed?"
set speedq=1
if %errorlevel% == 1 goto speedandtextquestions
if %errorlevel% == 2 call :clearlastprompt
:nextaudiostep1
call :newline
goto audiodistortion
:nextaudiostep2
set "filename=%~n1 (Quality Munched)"
if exist "%filename%%audiocontainer%" goto renamefile
:nextaudiostep3
call :voicesynth
echo [38;2;254;165;0mEncoding...[0m & echo.
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %time% -i %1 ^
-vn %metadata% -preset %encodingspeed% ^
-c:a %audioencoder% -b:a %badaudiobitrate%000 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%audiocontainer%"
set outputvar="%cd%\%filename%%audiocontainer%
if "%tts%"=="y" call :encodevoiceNV
goto end

:: voice synth encoding for no video stream
:encodevoiceNV
set "af2="
if not "%audiofilters%e" == "e" set "af2=,%audiofilters:-af =%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i anullsrc -filter_complex "flite=text='%ttstext%':voice=kal16%af2%,volume=%volume%dB" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%audiocontainer%" -movflags +use_metadata_tags -map_metadata 1 -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename% tts%audiocontainer%"
if exist "%filename%%audiocontainer%" (del "%filename%%audiocontainer%")
set outputvar="%cd%\%filename% tts%audiocontainer%"
goto :eof

:: checks if a file with the same name as the output already exists, if so, appends a (1) to the name, then (2) if that also exists, then (3), etc
:renamefile
if %isimage% == true set container=%imagecontainer%
if %hasvideo% == false set "container=%audiocontainer%"
set /a "i+=1"
if exist "%filename% (%i%)%container%" goto renamefile
set "filename=%filename% (%i%)"
if %hasvideo% == false goto nextaudiostep3
if %isimage% == true goto afternamecheck
goto outputcont

:thing2
:: credit http://jeffwouters.nl/index.php/2012/03/get-your-geek-on-with-powershell-and-some-music/
powershell -noprofile -command [console]::beep(440,500);[console]::beep(440,500);[console]::beep(440,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,1000);[console]::beep(659,500);[console]::beep(659,500);[console]::beep(659,500);[console]::beep(698,350);[console]::beep(523,150);[console]::beep(415,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,1000);
call :clearlastprompt
goto verystart

:: ran when images or gifs are used as an input
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
if not check%3 == check set imageq=%3&set imagesc=%4&goto skippedque
set /p "imageq=[93mOn a scale from 1 to 10[0m, how bad should the quality be? "
call :clearlastprompt
set /p "imagesc=[93mOn a scale from 1 to 10[0m, how much should the image be shrunk by? "
call :clearlastprompt
:skippedque
set /a desiredheight=%height%/%imagesc%
set /a desiredheight=(%desiredheight%/2)*2
if a%2 == aY set fricheck=1&goto skipq2
if a%2 == aN set fricheck=2&goto skipq2
choice /m "Deep fry the image?"
set fricheck=%errorlevel%
:skipq2
set sep=r
if %fricheck% == 1 set "fryfilter=noise=alls=20,eq=saturation=2.5:contrast=200:brightness=0.3,noise=alls=10"&set "sep=r,"
if %fricheck% == 2 call :clearlastprompt
call :newline
set "filename=%~n1 (Quality Munched)"
:: very work-in-progress formula, not even sure if it works completely
set /a badimagebitrate=(%imageq%*2)+10
if %badimagebitrate% LSS 2 set badimagebitrate=2
if exist "%filename%%imagecontainer%" goto renamefile
:afternamecheck
if %fricheck% == 2 echo [38;2;254;165;0mEncoding...[0m & echo.
:: the amount of colors to use in the image
set /a pallete=100/%imageq%
if not "%fryfilter%1" == "1" goto fried
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -vf palettegen=max_colors=%pallete% "%temp%\palletforqm.jpg"
if %imagecontainer% == .gif goto gifmoment1
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -i "%temp%\palletforqm.jpg" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate% -pix_fmt yuv410p -filter_complex "paletteuse,scale=-2:%desiredheight%:flags=neighbor,noise=alls=%imageq%/4,eq=saturation=(%imageq%/50)+1:contrast=1+(%imageq%/50)" "%filename%%imagecontainer%"
:endgifmoment1
if exist "%temp%\palletforqm.jpg" (del "%temp%\palletforqm.jpg")
if exist "%temp%\%filename%%container%" (del "%temp%\%filename%%container%")
goto end

:: used when an image is set to be deep fried
:fried
if not a%2 == a set level=%5&goto skipq3
set /p "level=How fried do you want the image or gif, [93mfrom 1-10[0m: "
choice /m "Do you want the built-in color changes that come with frying?"
if %errorlevel% == 2 (set "fryfilter=noise=alls=%level%*2"&set "sep=r,"&set frich=1)
call :clearlastprompt
:skipq3
echo [38;2;254;165;0mEncoding...[0m & echo.
if not 1%frich% == 11 set "fryfilter=eq=saturation=2.5:contrast=%level%,noise=alls=%level%*2"&set "sep=r,"
:: not in order but, but this makes a noise map in 1/10 size, scales it to the final sizxe, makes a pallete of colors to use, scales down the input to the final size and uses the set amount of colors, and displaces the input with the noise map and does the color stuff and bitrate stuff
set /a desiredwidth=((%width%/%imagesc%)/2)*2
set /a smallwidth=((%desiredwidth%/10)/2)*2
set /a smallheight=((%desiredheight%/10)/2)*2
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=1 -frames:v 1 -vf "noise=allf=t:alls=%level%*2:all_seed=%random%,eq=contrast=%level%*%level%" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -vf scale=%desiredwidth%:%desiredheight%:flags=neighbor "%temp%\noisemapscaled.png"
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
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %1 -i "%temp%\palletforqm.jpg" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate% -pix_fmt yuv410p -filter_complex "paletteuse,scale=-2:%desiredheight%:flags=neighbor,noise=alls=%imageq%/4,eq=saturation=(%imageq%/50)+1:contrast=1+(%imageq%/50)" -f gif "%filename%.gif"
set outputvar="%cd%\%filename%.gif"
goto endgifmoment1

:: asks if user wants to fry the video
:videofrying
choice /m "Do you want to fry the video? (will cause extreme distortion)"
if %errorlevel% == 2 call :clearlastprompt
if %errorlevel% == 2 goto encoding2
set frying=true
set /p "level=How fried do you want the video, [93mfrom 1-10[0m: "
choice /m "Do you want the built-in color changes that come with frying?"
if %errorlevel% == 2 (set levelcolor=10) else (set levelcolor=%level%)
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
call :clearlastprompt
goto encoding2

:: some extra steps for encoding a fried video, in order:
:: generate noise map at 1/10 resolution, scale the map to final resolution, scale the input to the final resolution, add the input and noise together with displacement, and shift it back into place with rgbashift
:encodefried
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=%duration%:r=%framerate% -vf "noise=allf=t:alls=%level%*10:all_seed=%random%,eq=contrast=%level%*2" -f h264 pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -vf scale=%desiredwidth%:%desiredheight%:flags=neighbor "%temp%\noisemapscaled%container%" 
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %videoinp% -vf "fps=%framerate%,scale=%desiredwidth%:%desiredheight%:flags=neighbor" -c:a copy "%temp%\scaledinput%container%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i "%temp%\scaledinput%container%" -i "%temp%\noisemapscaled%container%" -i "%temp%\noisemapscaled%container%" -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -c:a copy -filter_complex "split,displace=edge=wrap,fps=%framerate%,scale=%desiredwidth%x%desiredheight%:flags=neighbor,%fryfilter%" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -c:a copy -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -vf "fps=%framerate%,rgbashift=rh=%shifth%:rv=%shiftv%:bh=%shifth%:bv=%shiftv%:gh=%shifth%:gv=%shiftv%:ah=%shifth%:av=%shiftv%:edge=wrap" "%temp%\scaledandfriedvideotempfix%container%"
:: use the output of the 5th ffmpeg call as the input for the final encoding
set "videoinp=%temp%\scaledandfriedvideotempfix%container%"
if exist "%temp%\noisemapscaled%container%" (del "%temp%\noisemapscaled%container%")
if exist "%temp%\scaledinput%container%" (del "%temp%\scaledinput%container%")
goto encodenormal

:clearlastprompt
if %cleanmode% == false goto :eof
echo [H[u[0J
goto :eof

:newline
if %cleanmode% == false echo.
goto :eof

:announcement
:: checks if github is able to be accessed
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 goto failure
set internet=true
:: grabs the version of the latest public release from the github
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/announce.txt" --output %temp%\anouncementQM.txt
set /p announce=<%temp%\anouncementQM.txt
echo [38;2;255;190;0mAnnouncements:[0m
setlocal enabledelayedexpansion
for /f "tokens=*" %%s in (%temp%\anouncementQM.txt) do (
    set /a "g+=1"
    echo [38;2;90;90;90m[!g!][0m %%s
)
endlocal
if exist "%temp%\anouncementQM.txt" (del "%temp%\anouncementQM.txt")
echo.
pause
if %cleanmode% == true call :titledisplay
goto :eof

:: fails to access github
:failure
echo [91mAnnouncements were not able to be accessed. Either you are not connected to the internet or GitHub is offline.[0m
pause
if %cleanmode% == false goto :eof
echo [H[u[0J
goto :eof

:: asks if user wants to stutter the video
:stutter
call :newline
set stutteramount=2
choice /m "Do you want to add stutter to the video?"
if %errorlevel% == 2 call :clearlastprompt&goto :eof
echo [93mNote that too much stutter will result in the video playing backwards. It's recommended to stay between 2 and 20.[0m
set /p "stutteramount=How much stutter do you want, [93mfrom 2-512[0m: "
set "stutterfilter=,random=frames=%stutteramount%"
call :clearlastprompt&goto :eof

:newmunch
set /p "loopn=Number of times to compress the image [93m(recommended to be at least 10)[0m: "
set /p "qv=[93mOn a scale from 1 to 10[0m, how bad should the quality be? "
set /p "imagesc=[93mOn a scale from 1 to 10[0m, how much should the image be shrunk by? "
set /a qv=(%qv%*3)+1
:: new munching
call :newmunchworking %1 %loopn% %qv% %imagesc%
echo. & echo [92mDone![0m
set done=true
goto exiting
exit

:newmunchworking
call :clearlastprompt
echo [38;2;254;165;0mEncoding...[0m & echo.
set loopn=%2
set qv=%3
:: qv3 is used for webp/vp9, qv is used for -q:v in mjpeg
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
set webp=webp&set weblib=libwebp&set mjpegformat=mjpeg
if %imagecontainer% == .gif set imagecontainer=.mkv&set webp=webm&set weblib=libvpx&set mjpegformat=gif
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i %1 -preset ultrafast -vf scale=%width%x%height%:flags=neighbor -c:v mjpeg -q:v %qv% -f mjpeg "%tempfolder%\%~n11%imagecontainer%"
set /a loopnreal=%loopn%-1
:: loop through a few encoders until the loop is over
:startmunch
set /a i+=1
set /a i1=%i%+1
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt yuv410p -c:v libx264 -crf %qv% -f h264 "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% (goto endmunch)
del "%tempfolder%\%~n1%i%%imagecontainer%"
set /a i+=1
set /a i1=%i%+1
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%widthalt%x%heightalt%:flags=neighbor -preset ultrafast -pix_fmt yuv422p -c:v mjpeg -q:v %qv% -f mjpeg "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% (goto endmunch)
del "%tempfolder%\%~n1%i%%imagecontainer%"
set /a i+=1
set /a i1=%i%+1
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=neighbor -c:v %weblib% -pix_fmt yuv411p -compression_level 0 -quality %qv3% -f %webp% "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% (goto endmunch)
del "%tempfolder%\%~n1%i%%imagecontainer%"
goto startmunch
:endmunch
set /a i2=%i1%+1
echo %loopn%/%loopn%
:: rename file until it doesn't exist
set "filename=%~dpn1 (Quality Munched)"
if not exist "%filename%%imagecontainerbackup%" goto afterrename
:renamefileimage
set /a "f+=1"
if exist "%filename% (%f%)%imagecontainerbackup%" goto renamefileimage
set "filename=%filename% (%f%)"
:afterrename
:: if not a gif, run the next line and skip the 2 after, else run the 2 after the next line
if not %imagecontainerbackup% == .gif ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=neighbor -preset ultrafast -pix_fmt yuv410p -c:v mjpeg -q:v %qv% -f mjpeg "%filename%%imagecontainerbackup%"&goto notgif
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt rgb24 -c:v libx264 -crf %qv% -f h264 "%tempfolder%\%~n1%i%final%imagecontainer%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%final%imagecontainer%" -vf "scale=%width%x%height%:flags=neighbor" -f gif "%filename%%imagecontainerbackup%"
:notgif
rmdir "%tempfolder%" /q /s
set outputvar="%filename%%imagecontainerbackup%"
goto :eof

:titledisplay
cls
echo [s
cls
if %showtitle% == false goto :eof
echo [38;2;39;55;210m       :^^~~~^^.        ^^.            ^^.       :^^        .^^.           .^^ .~~~~~~~~~~~~~~~: :~            .~.
echo [38;2;39;61;210m    !5GP5YYY5PPY^^    :@?           :@J      :#@7       ~@!           Y^&..JYYYYYY@BJYYYYY! !BG~        .?#P:
echo [38;2;40;68;209m  ~BG7:       :?BG:  ^^@J           :@Y     .BB5@~      !@!           Y@:       .@Y          7BG~    .?#G~
echo [38;2;40;74;209m 7@J            .5^&^^ ^^@J           :@J     P^&: P^&:     !@!           Y@:       :@Y            7BG~.?#G~
echo [38;2;41;81;209m:^&5               BB :@J           :@J    Y@^^  .B#.    !@!           Y@:       :@Y              7B^&G~
echo [38;2;41;87;209m~@7               5@.:@J           :@Y   ?@!    :^&G    !@!           Y@:       :@Y               ?@:
echo [38;2;42;94;208m.#G              .^&P :@J           :@J  !@?      ^^@5   !@!           Y@:       :@Y               ?@^^
echo [38;2;42;100;208m ^^^&P:           .B#.  5^&^^          P^&: ^^@Y        !@J  !@!           Y@:       :@Y               ?@^^
echo [38;2;43;107;208m  .YB5!:.   . !!:Y^&!   Y#5~.   .^^?BG^^ :^&P          ?@7 !@7           Y@:       :@Y               ?@^^
echo [38;2;43;113;207m    .7YPPPPPP^^!YPP^&@7   :?5PPPPPPY~   5G.           YB.^^#GPPPPPPPPPJ ?B.       .B?               7#:
echo [38;2;44;120;207m         ...     .^^?!       ....      .              .   ...........                              .
echo [38;2;44;126;207m ^^.            ^^. :.            :. ::            :.       .:^^~~^^:     .:            .:     :~~~~~~~~~^^ .^^~~~~~~~~^^:
echo [38;2;45;133;207m~@#!         ~B@!:@?           :^&J #^&J          .#5    :?PP5YYY5PG57. 7@^^           7@^^ .YGPYYYYYYYYY? J@5YYYYYYY5PG?.
echo [38;2;45;139;206m~@P#P:     :P#5@!:@J           :@Y ^&BGB~        .^&P  .Y#Y~.      .!PY ?@^^           ?@^^.#B:            J@:         ^^BB.
echo [38;2;46;146;206m~@!.5^&J  .J^&Y.~@!:@J           :@Y ^&5 ?#P:      .^&P .BB:              ?@^^           7@^^~@!             J@:          ?@^^
echo [38;2;46;152;206m~@7  ~BB~JP^^  ~@!:@J           :@Y ^&P  .5^&J     .^&P 5@:               ?@~.:::::::::.J@^^~@7.::::::::.   J@:...:::::~J#Y
echo [38;2;47;159;205m~@7    ?P:    ~@!:@J           :@Y ^&P    ~BB~   .^&P BB                ?@G5PPPPPPPPP5B@^^~@G55555555P?   J@^^Y^&^&G55555?:
echo [38;2;47;165;205m~@7           ~@!:@J           :@J ^&P      ?#P: .^&P J@^^               ?@^^           ?@^^~@!             J@: ~5B5^^
echo [38;2;48;172;205m~@7           ~@7 P^&^^          5@^^ ^&P       .5^&?.^&P  P^&~            . ?@^^           ?@^^~@!             J@:   :?BG7.
echo [38;2;48;178;205m!@7           ~@7  Y#Y^^.    :7GB^^ .^&P         ~GB@P   ?BP7:.    .^^?G5 ?@^^           ?@^^~@!             J@:      !PBY^^
echo [38;2;49;185;204m^^#!           ^^^&~   :JPPP5PPPY!    BY           7#Y    .!YPPP55PPPJ~  7#:           !#:^^^&G55555555555J ?#:        :JB?
echo [38;2;49;191;204m .             .       ..::.                               .::::.      .             .  .::::::::::::.  .            .[0m
echo.[s
goto :eof

:: exiting
:ending
if %animate% == true goto closingbar