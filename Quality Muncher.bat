:: if you have any questions about this script, feel free to DM me on Discord, Frost#5872, or ask in the discord server
@echo off

:: OPTIONS - THESE RESET AFTER UPDATING SO KEEP A COPY SOMEWHERE
:: you can see a list of the defaults at the start of the version on the GitHub page or by downloading the file again
     :: automatic update checks
     set autoupdatecheck=true
     :: stay open after the file is done rendering
     set stayopen=true
     :: shows title
     set showtitle=true
	 :: enables metadata for debugging purposes
	 set meta=true
	 :: saves a log after rendering, useful for debugging (if enabled, also enables metadata)
	 set log=false
	 :: cool animations
	 set animate=true
	 :: encoding speed, doesn't change much - ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
	 set encodingspeed=ultrafast
	 :: always asks for resample, no matter what (unless you're using multiqueue)
	 set alwaysaskresample=false
	 :: default video container, uses .mp4 as default (don't forget the dot!)
	 set container=.mp4
	 :: default container for audio
	 set audiocontainer=.chyn
	 :: clear screen after each option is selected
	 set cleanmode=true
:: END OF OPTIONS

:: batch breaking for no reason counter: 36

:: warning: if you mess with stuff after this things might break
:: sets a ton of variables that are used later
set imagecontainer=.jpg
set isimage=false
set version=1.4.2
set isupdate=false
if check%2 == check title Quality Muncher v%version%
set inpcontain=%~x1
if not check%2 == check set animate=false&set alwaysaskresample=false
set cols=14
set lines=8
set done=false
set hasvideo=true
set bassboosted=n
if %1p == qmloop goto colorstart
if %animate% == true goto loadingbar
:init
if not check%2 == check set showtitle=false&goto verystart
call :titledisplay
:: sets the title of the window, some variables, and sends an ascii thing
if %log% == true set meta=true
:: checks for updates
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
if %autoupdatecheck% == true goto updatecheck
:: sets more variables to be used later
:verystart
set frying=false
set stretchres=n
set colorq=n
set addedtextq=n
set interpq=n
set resample=n
set "qs=Quality Selected!"
:: checks if ffmpeg is installed, and if it isn't, it'll send a tutorial to install it. 
where /q ffmpeg
if %errorlevel% == 1 (
     echo [91mERROR: You either don't have ffmpeg installed or don't have it in PATH.[0m
     echo Please install it as it's needed for this program to work.
	 choice /n /c gc /m "Press [G] for a guide on installing it, or [C] to close the script."
     if %errorlevel% == 1 start "" https://www.youtube.com/watch?v=WwWITnuWQW4
     exit
)
set confirmselec=n
echo Quality Muncher is still in development. This is version %version%. & echo Please DM me at Frost#5872 for any questions or support, or join the discord server. & echo.
:: checks if someone used the script correctly
if %1check == check goto noinput
:: checks if the input has a video stream (i.e. if the input is an audio file)
set inputvideo=%1
ffprobe -i %inputvideo% -show_streams -select_streams v -loglevel error > %temp%\vstream.txt
set /p vstream=<%temp%\vstream.txt
if exist "%temp%\vstream.txt" (del "%temp%\vstream.txt")
if 1%vstream% == 1 goto novideostream
:: if the video is an image, ask specific image questions
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
echo Press [S] for simple, [A] for advanced, [W] to open the website, [D] to join the discord server, [P] to make a suggestion,
echo [U] to check for updates, [N] to view announcements, or [C] to close.
choice /n /c SAWDCPGJMUN
echo.
call :clearlastprompt
:: determines where to send the user - if advanced, asks for the start time and duration
if %errorlevel% == 2 set complexity=a& echo Advanced mode selected! & echo.&goto advancedfour
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
echo Simple mode selected!
set complexity=s
echo.
:continuefour
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
     echo.
     echo Custom %qs%
	 echo.
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
if "%customizationquestion%" == "c" echo.&echo Custom %qs%
:customquestioncheckpoint
if %customizationquestion% == 6 set customizationquestion=r&goto random
if %customizationquestion% == r goto random
if "%customizationquestion%" == "c" (
	 echo.
     set /p framerate=What fps do you want it to be rendered at: 
     set /p videobr=[93mOn a scale from 1 to 10[0m, how bad should the video bitrate be? 1 bad, 10 very very bad: 
     set /p audiobr=[93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad: 
     set /p scaleq=[93mOn a scale from 1 to 10[0m, how much should the video be shrunk by? 1 none, 10 a lot: 
	 choice /m "Do you want a detailed file name for the output?"
     set endingmsg=Custom Quality
)
if "%customizationquestion%" == "c" (
	 if %errorlevel% == 1 set details=y
)
if %customizationquestion% == 1 (
     echo.
     echo Decent %qs%
     set framerate=24
     set videobr=3
     set scaleq=2
     set audiobr=3
     set endingmsg=Decent Quality
)
if %customizationquestion% == 2 (
     echo.
     echo Bad %qs%
     set framerate=12
     set videobr=5
     set scaleq=4
     set audiobr=5
     set endingmsg=Bad Quality
)
if %customizationquestion% == 3 (
     echo.
     echo Terrible %qs%
     set framerate=6
     set videobr=8
     set scaleq=8
     set audiobr=8
     set endingmsg=Terrible Quality
)
if %customizationquestion% == 4 (
     echo.
     echo Unbearable %qs%
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
call :clearlastprompt
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
if /I %details% == y set "endingmsg=Custom Quality - %framerate% fps^, %videobr% video bitrate input^, %audiobr% audio bitrate input^, %scaleq% scale"
if not %complexity% == s goto advancedone
:continueone
:: Sets the audiobr (should be noted that audio bitrate is in thousands, unlike video bitrate)
set /a badaudiobitrate=80/%audiobr%
:: asks color questions, streching, and audio replacement
if NOT %complexity% == s goto advancedtwo
:continuetwo
if %complexity% == s set stretchres=n
if %stretchres% == y (
     set /a desiredwidth=%desiredwidth%*2
)
set yeahlowqual=n
:filters
:: asks about resampling - if simple mode is on/input fps is under output fps, will come back without asking (unless always ask resample is one)
goto resamplequestion
:afterresample
call :clearlastprompt
:: asks if the user wants to interpolate if framerate input is less than output
set interpq=n
if NOT %complexity% == s (
     if %framerate% gtr %fpsvalue% (
		 choice /c YN /m "The framerate of your input exceeds the framerate of the output. Interpolate to fix this?"
		 call :clearlastprompt
		 if %errorlevel% == 1 set interpq=y
	     echo.
     )
)
:: bitrate formula - still a work in progress
set /a badvideobitrate=(%desiredheight%/2*%desiredwidth%*%framerate%/%videobr%)
:: minimum bitrate in libx264 (the encoder) is 1000, so set it to 1000 if it's under
if %badvideobitrate% LSS 1000 set badvideobitrate=1000
:: audio distortion questions
set "audiofilters="
if NOT %complexity% == s goto advancedthree
:encoding
:: if simple mode, don't ask about video frying
if %complexity% == s goto encoding2
set videoinp=%1
goto videofrying
:encoding2
call :newline
:: defines filters
set "fpsfilter=fps=%framerate%,"
if %interpq% == y set "fpsfilter=minterpolate=fps=%framerate%,"
if %resample% == y set "fpsfilter=tmix=frames=%tmixframes%:weights=1,fps=%framerate%,"
set filters=-filter_complex "scale=%desiredwidth%:%desiredheight%:flags=neighbor,setsar=1:1,%textfilter%%fpsfilter%%speedfilter%format=yuv410p"
if %colorq% == y (
     set filters=-filter_complex "scale=%desiredwidth%:%desiredheight%:flags=neighbor,setsar=1:1,%textfilter%%fpsfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,format=yuv410p"
)
if %complexity% == s set filters=-vf "%fpsfilter%scale=%desiredwidth%:%desiredheight%:flags=neighbor,format=yuv410p"
:: metadata - uses a variety of variables to save space since there are different values stored for different options (simple, advanced, etc)
if %meta% == false goto setfilename
set meta1=-metadata comment="Made with Quality Muncher v%version% - https://github.com/Thqrn/qualitymuncher"
set meta2=-metadata "Quality Muncher Info"=
set meta3=Complexity %complexity%, option %customizationquestion%
set meta4=Input had a width of %width% and a height of %height%. The final bitrates were %badvideobitrate% for video and %badaudiobitrate%000 for audio. Final scale was %desiredwidth% for width and %desiredheight% for height and resample was set to %resample%.
set meta5=fps %framerate%, video bitrate %videobr%, audio bitrate %audiobr%, scaleq %scaleq%, details %details%
set meta6=start %starttime%, duration %time%, speed %speedq%, color %colorq%, interpolated %interpq%, stretched %stretchres%, distorted audio %bassboosted%, added audio %lowqualmusicquestion%, added text %addedtextq%.
:: actually setting the metadata variable
if not %complexity% == s goto advancedmeta
set metadata=%meta1% %meta2%"%meta3%. %meta4%"
if %customizationquestion% == c set metadata=%meta1% %meta2%"%meta3%, %meta5%. %meta4%"
goto setfilename
:advancedmeta
:: metadata used for advanced options
set metadata=%meta1% %meta2%"%meta3%, %meta6% %meta4%"
if %customizationquestion% == c set metadata=%meta1% %meta2%"%meta3%, %meta5%, %meta6% %meta4%"
:: sets the file name
:setfilename
set "filename=%~n1 (%endingmsg%)"
:: asks if the user wants a custom output name
if not %complexity% == s goto outputquestion
:outputcont
:: if the output already exists, add a (1), and if that exists, make it (2), etc
if exist "%filename%%container%" goto renamefile
if %log% == true echo %metadata% > "%~dpn1 (%endingmsg%) log.txt"
call :clearlastprompt
echo [38;2;254;165;0mEncoding...[0m & echo.
if %complexity% == s (
     set time=32727
     set starttime=0
     goto optionthree
)
:: if the user selected to fry the video, encode all of the needed parts (probably will switch to using pipe at some point, but this works for now)
if %frying% == true goto encodefried
:encodenormal
if %yeahlowqual% == n goto optionone
goto optiontwo
:: option one, no extra music
:optionone
ffmpeg -hide_banner -loglevel error -stats ^
-ss %starttime% -t %time% -i %videoinp% ^
%filters% %audiofilters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
goto end
:: option two, there is music
:optiontwo
ffmpeg -hide_banner -loglevel warning -stats ^
-ss %starttime% -t %time% -i %videoinp% -ss %musicstarttime% -i %lowqualmusic% ^
%filters% %audiofilters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
goto end
:: option three, simple mode only, no audio filters
:optionthree
ffmpeg -hide_banner -loglevel error -stats ^
-i %1 ^
%filters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%"
:end
echo. & echo [92mDone![0m
set done=true
if exist "%temp%\scaledinput%container%" (del "%temp%\scaledinput%container%")
if exist "%temp%\scaledandfriedvideotempfix%container%" (del "%temp%\scaledandfriedvideotempfix%container%")
if %stayopen% == false goto ending
if 1%2 == 1 goto :exiting
if not check%2 == check goto ending

:: begin advanced parts - most of the following code isn't read when using simple mode

:: audio distortion questions
:advancedthree
choice /c YN /m "Do you want to distort the audio (earrape)?"
if %errorlevel% == 1 set bassboosted=y&goto skipno
:: if no, checks if speed is something other than one, and if it is, set audiofilters so the audio syncs and then goes to encoding
:: the "hasvideo" variable is false if you're using an audio file
if %bassboosted% == n (
     set "audiofilters="
	 if NOT %speedq% == 1 set "audiofilters=-af atempo=%speedq%"
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
set /p distortionseverity=How distorted should the audio be, [93m1-10[0m: 
set /a distsev=%distortionseverity%*10
set /a bb1=0
set /a bb2=(%distsev%*25)
set /a bb3=2*(%distsev%*25)
set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%|%bb2%|%bb3%,channelmap=1|0,aecho=0.8:0.3:%distsev%*2:0.9"
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %speedq% == 1 (
     set "audiofilters=-af atempo=%speedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%|%bb2%|%bb3%,channelmap=1|0,aecho=0.8:0.3:%distsev%*2:0.9"
)
call :clearlastprompt
if %hasvideo% == false goto nextaudiostep2
echo. & goto encoding
:: old method - just boosts frequencies
:classic
set /p distortionseverity=How distorted should the audio be, [93m1-10[0m: 
set /a distsev=%distortionseverity%*10
set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %speedq% == 1 (
     set "audiofilters=-af atempo=%speedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
)
call :clearlastprompt
if %hasvideo% == false goto nextaudiostep2
goto encoding


:: speed settings/questions
:advancedone
set speedvalid=n&set speedq=default
call :newline
set /p speedq=What should the playback speed of the video be, [93mmust be a positive number between 0.5 and 100[0m, default is 1: 
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
     echo.
     echo [91mNo valid input given, speed has been set to default.[0m
     set speedvalid=y
     set speedq=1
     goto cont
)
set speedfilter="setpts=(1/%speedq%)*PTS,"
set speedfilter=%speedfilter:"=%
call :clearlastprompt
if %hasvideo% == false goto nextaudiostep1
:addtext
call :newline
:: asks if they want to add text
choice /c YN /m "Do you want to add text to the video?"
if %errorlevel% == 1 set addedtextq=y
if %addedtextq% == n set "textfilter="
if %addedtextq% == n goto continueone
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
goto continueone


:advancedtwo
call :newline
call :clearlastprompt
:: questions about modifying video color
set contrastvalue=1 & set saturationvalue=1 & set brightnessvalue=0
choice /c YN /m "Do you want to customize saturation, contrast, and brightness?"
if %errorlevel% == 1 set colorq=y
set contrastvaluefalse=n& set saturationvaluefalse=n& set brightnessvaluefalse=n
:: prompts for specific values
if %colorq% == y (
     set /p contrastvalue=Select a contrast value [93mbetween -1000.0 and 1000.0[0m, default is 1: 
     set /p saturationvalue=Select a saturation value [93mbetween 0.0 and 3.0[0m, default is 1: 
     set /p brightnessvalue=Select a brightness value [93mbetween -1.0 and 1.0[0m, default is 0: 
)
:: tests if the values contain invalid characters
if %colorq% == y (
     set "errormsgcol=value was invalid, it has been set to the default."
     if not "%contrastvalue%"=="%contrastvalue: =%" set contrastvaluefalse=y
     if not "%saturationvalue%"=="%saturationvalue: =%" set saturationvaluefalse=y
     if not "%brightnessvalue%"=="%brightnessvalue: =%" set brightnessvaluefalse=y
     for /f "tokens=1* delims=-.0123456789" %%j in ("j0%contrastvalue:"=%") do (if not "%%k"=="" set contrastvaluefalse=y)
     for /f "tokens=1* delims=.0123456789" %%l in ("l0%saturationvalue:"=%") do (if not "%%m"=="" set saturationvaluefalse=y)
     for /f "tokens=1* delims=-.0123456789" %%n in ("n0%brightnessvalue:"=%") do (if not "%%o"=="" set brightnessvaluefalse=y)
)
if %contrastvaluefalse% == y echo. & echo [91mContrast %errormsgcol%[0m & set contrastvalue=1
if %saturationvaluefalse% == y echo. & echo [91mSaturation %errormsgcol%[0m & set saturationvalue=1
if %brightnessvaluefalse% == y echo. & echo [91mBrightness %errormsgcol%[0m & set brightnessvalue=0
:stretch
echo.
call :clearlastprompt
:: asks about stretching the video - doesn't set the actual resolution since that's done after
choice /c YN /m "Do you want to stretch the video horizontally?"
call :clearlastprompt
if %errorlevel% == 1 set stretchres=y
:: asks if they want music and if so, the file to get it from and the start time
:lowqualmusicq
set musicstarttime=0 & set musicstartest=0 & set lowqualmusicquestion=n & set filefound=y
call :newline
choice /c YN /m "Do you want to add music?"
if %errorlevel% == 1 set lowqualmusicquestion=y
:addingthemusic
:: asks for a specific file to get music from
if %lowqualmusicquestion% == y (
     set yeahlowqual=y
     set /p lowqualmusic=Please drag the desired file here, [93mit must be an audio/video file[0m: 
)
:: sets a variable if it's a valid file
if %lowqualmusicquestion% == y (
     set filefound=n
     if exist %lowqualmusic% set filefound=y
)
:: if it's not a valid file it sends the user back to add a valid file
if %filefound% == n (
     echo. & echo [91mInvalid file! Please drag an existing file from your computer![0m & echo.
     goto addingthemusic
)
:: asks the user when the music should start
if %lowqualmusicquestion% == y (
     set /p musicstarttime=Enter a specific start time of the music [93min seconds[0m: 
     goto filters
)
call :clearlastprompt
goto continuetwo

:: asks about resampling (skips if in simple mode, input fps is less than output, and stays if those are false)
:: always stays if alwaysaskresample is true in options, even if using simple mode
:resamplequestion
if %alwaysaskresample% == true goto bypassnoresample
if "%complexity%" == "s" goto afterresample
if not %fpsvalue% gtr %framerate% goto afterresample
:bypassnoresample
call :newline
choice /c YN /m "Do you want to resample frames? This will look like motion blur, but will take longer to render."
call :clearlastprompt
if %errorlevel% == 1 set resample=y
if %resample% == n goto afterresample
:: determines the number of frames to blend together per frame (does not use decimals/floats because batch is like that)
set /a tmixframes=%fpsvalue%/%framerate%
goto afterresample

:: the start of advanced mode, despite the name being "advanced four"
:advancedfour
call :clearlastprompt
:: asks where to start clip
:startquestion
set starttime=0
set /p starttime=[93mIn seconds[0m, where do you want your clip to start: 
if "%starttime%" == " " set starttime=0
:: asks length of clip
:timequestion
set time=32727
set /p time=[93mIn seconds[0m, how long after the start time do you want it to be: 
if "%time%" == " " set time=32727
echo.
call :clearlastprompt
if %hasvideo% == false goto backtoaudio
goto continuefour

:: if discord is selected from the menu, it sends the user to discord, clears the console, and goes back to start
:discord
echo [96mSending to Discord![0m & start "" https://discord.com/invite/9tRZ6C7tYz & call :clearlastprompt&goto verystart

:: if the website is selected from the menu, it sends the user to the website, clears the console, and goes back to start
:website
echo [96mSending to website![0m & start "" https://qualitymuncher.lgbt/ & call :clearlastprompt&goto verystart

:: suggestions
:suggestion
:: checks for a connection to discord
call :clearlastprompt
ping /n 1 discord.com  | find "Reply" > nul
if %errorlevel% == 1 echo [91mSorry, either discord is down or you're not connected to the internet. Try again later.[0m&echo.&pause&call :clearlastprompt&goto verystart
:: asks information about the suggestion
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
if %errorlevel% == 1 goto continuesuggest
if %errorlevel% == 2 call :clearlastprompt
if %errorlevel% == 2 echo [91mOkay, your suggestion has been cancelled.[0m&echo.&pause&call :clearlastprompt&goto verystart
:continuesuggest
:: please do not spam this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New suggestion!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/webhooks/973701372128157776/A-TFFPzP-hfWR-W2TuOllG_GUEX4SXN7RRqu-xLdSJgcgoQF6_x-GkwrMxDahw5g_aFE
call :clearlastprompt
echo [92mYour suggestion has been successfully sent to the developers![0m &echo.&pause&call :clearlastprompt&goto verystart

:: go to the main menu and press m to see what this does :)
:: if you want a detailed explanation of how it works send me a dm (Frost#5872)
:thing3
start "" %0 qmloo
call :clearlastprompt&goto verystart
:colorstart
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
if %R% == 255 goto red
:redc
if %G% == 255 goto gre
:grec
if %B% == 255 goto blu
:bluc
goto colorpart
pause&cls&goto verystart
:red
if not %B% == 0 set /a "B=%B%-1"
if %B% == 0 set /a "G=%G%+1"
goto redc
:gre
if not %R% == 0 set /a "R=%R%-1"
if %R% == 0 set /a "B=%B%+1"
goto grec
:blu
if not %G% == 0 set /a "G=%G%-1"
if %G% == 0 set /a "R=%R%+1"
goto bluc

:: runs if the user runs the script without using a parameter (i.e. they don't use send to or drag and drop)
:noinput
echo [91mERROR: no input file![0m & echo Drag this .bat into the SendTo folder - press [90;7mWindows + R[0m and type in [90;7mshell:sendto[0m & echo After that, right click on your video, drag over to Send To and click on [90;7mQuality Muncher.bat[0m. & echo.
echo Press [W] to open the website, [D] to join the discord server, [P] to make a suggestion, or [C] to close.
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
where /q ffplay || goto aftersound
if %done% == true ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound
pause & goto closingbar

:: if the user inputs a file manually instead of with send to or drag and drop
:manualfile
set me=%~f0
set /p file=Please drag your input here: 
cls & call "%me%" %file%
exit

:: checks for updates - done automatically unless disabled in options
:updatecheck
:: checks if github is able to be accessed
call :titledisplay
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 goto nointernet
set internet=true
:: grabs the version of the latest public release from the github
curl -s "https://raw.githubusercontent.com/Thqrn/qualitymuncher/main/version.txt" --output %temp%\QMnewversion.txt
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
if %errorlevel% == 3 call :clearlastprompt&goto verystart
echo.
:: installs the latest public version, overwriting the current one, and running it using this input as a parameter so you don't have to run send to again
curl -s "https://raw.githubusercontent.com/Thqrn/qualitymuncher/main/Quality%%20Muncher.bat" --output %0 & cls & %0 %1
exit

:: runs if there isn't internet (comes from update check)
:nointernet
cls
set internet=false & echo [91mUpdate check failed, skipping.[0m & echo.
goto verystart

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
echo      +-----------------------+  ;;  ^| ^|         ^|,"     -Art credit to Kevin Lam-
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
set /a cols=%cols%+5
if not %cols% gtr 124 goto loadingbar
:loadingy
mode con: cols=%cols% lines=%lines%
set /a lines=%lines%+1
if not %lines% gtr 35 goto loadingy
:: runs powershell to set the buffer size to allow users to scroll back up when wanted
powershell -noprofile -command "&{(get-host).ui.rawui.buffersize=@{width=%cols%;height=9901};}"
goto init

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
set /p "filenametemp=Enter your output name: "
set "filename=%filenametemp%"
echo.&goto outputcont

:: audio questions - ran when the user uses an audio file as an input
:: this shouldn't be too comlicated so i didn't leave many comments, but if you have questions dm me (Frost#5872)
:novideostream
set audioencoder=aac
:: the AAC codec has weird issues with mp3 - sometimes this causes issue but really i don't know for sure and i can't consistently reproduce them so this tries to fix that but using a different codec
if %audiocontainer% == .mp3 set audioencoder=libmp3lame
set hasvideo=false
echo [91mInput has no video, skipping video related questions...[0m
echo.
set /p audiobr=[93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad: 
set /a badaudiobitrate=80/%audiobr%
goto startquestion
:backtoaudio
choice /m "Adjust audio speed?"
set speedq=1
if %errorlevel% == 1 goto advancedone
:nextaudiostep1
echo.
goto advancedthree
:nextaudiostep2
set "filename=%~n1 (Quality Munched)"
if exist "%filename%%audiocontainer%" goto renamefile
:nextaudiostep3
echo. & echo [38;2;254;165;0mEncoding...[0m & echo.
ffmpeg -hide_banner -loglevel error -stats ^
-ss %starttime% -t %time% -i %1 ^
-vn %metadata% -preset %encodingspeed% ^
-c:a %audioencoder% -b:a %badaudiobitrate%000 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%audiocontainer%"
goto end

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
echo Input has been detected to be an image/gif.
:: grabs dimensions of the input
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
if exist "%temp%\height.txt" (del "%temp%\height.txt")
if exist "%temp%\width.txt" (del "%temp%\width.txt")
echo.
:: asks questions for quality and size (skipped if using multiqueue)
if not check%3 == check set imageq=%3&set imagesc=%4&goto skippedque
set /p imageq=[93mOn a scale from 1 to 10[0m, how bad should the quality be? 
call :clearlastprompt
set /p imagesc=[93mOn a scale from 1 to 10[0m, how much should the image be shrunk by? 
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
echo.
set "filename=%~n1 (Quality Munched)"
set /a pixelcount=(%desiredheight%*(%width%/%imagesc%))
:: very work-in-progress formula, not even sure if it works completely
set /a badimagebitrate=%pixelcount%/(%imageq%*%imageq%*%imageq%*%imageq%*%imageq%)
if %badimagebitrate% LSS 1 set badimagebitrate=1
if exist "%filename%%imagecontainer%" goto renamefile
:afternamecheck
:: the amount of colors to use in the image
set /a pallete=100/%imageq%
if not "%fryfilter%1" == "1" goto fried
ffmpeg -hide_banner -loglevel error -stats -i %1 -vf palettegen=max_colors=%pallete% "%temp%\palletforqm.jpg"
if %imagecontainer% == .gif goto gifmoment1
ffmpeg -hide_banner -loglevel error -stats -i %1 -i "%temp%\palletforqm.jpg" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate% -pix_fmt yuv410p -filter_complex "paletteuse,scale=-2:%desiredheight%:flags=neighbor,noise=alls=%imageq%/4,eq=saturation=(%imageq%/50)+1:contrast=1+(%imageq%/50)" "%filename%%imagecontainer%"
:endgifmoment1
if exist "%temp%\palletforqm.jpg" (del "%temp%\palletforqm.jpg")
if exist "%temp%\%filename%.mp4" (del "%temp%\%filename%.mp4")
goto end

:: used when an image is set to be deep fried
:fried
if not a%2 == a set level=%5&goto skipq3
set /p level=How fried do you want the image/gif, [93mfrom 1-10[0m: 
call :clearlastprompt
:skipq3
set "fryfilter=eq=saturation=2.5:contrast=%level%,noise=alls=%level%"&set "sep=r,"
:: not in order but, but this makes a noise map in 1/10 size, scales it to the final sizxe, makes a pallete of colors to use, scales down the input to the final size and uses the set amount of colors, and displaces the input with the noise map and does the color stuff and bitrate stuff
set /a desiredwidth=((%width%/%imagesc%)/2)*2
set /a smallwidth=((%desiredwidth%/10)/2)*2
set /a smallheight=((%desiredheight%/10)/2)*2
ffmpeg -hide_banner -loglevel error -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=1 -frames:v 1 -vf "noise=allf=t:alls=%level%*2:all_seed=%random%,eq=contrast=%level%*%level%" "%temp%\noisemap.png"
ffmpeg -hide_banner -loglevel error -stats -i %1 -vf palettegen=max_colors=%pallete% "%temp%\palletforqm.jpg"
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\noisemap.png" -vf scale=%desiredwidth%:%desiredheight%:flags=neighbor "%temp%\noisemapscaled.png"
ffmpeg -hide_banner -loglevel error -stats -i %1 -i "%temp%\palletforqm.jpg" -filter_complex "paletteuse,scale=%desiredwidth%:%desiredheight%" "%temp%\scaledinput%imagecontainer%"
if %imagecontainer% == .gif goto gifmoment
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\scaledinput%imagecontainer%" -i "%temp%\noisemapscaled.png" -i "%temp%\noisemapscaled.png" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate%/%level% -pix_fmt yuv410p -filter_complex "split,displace=edge=wrap,scale=%desiredwidth%:%desiredheight%:flags=neighbo%sep%%fryfilter%" "%filename%%imagecontainer%"
:endgifmoment
if exist "%temp%\noisemap.png" (del "%temp%\noisemap.png")
if exist "%temp%\%filename%.mp4" (del "%temp%\%filename%.mp4")
if exist "%temp%\noisemapscaled.png" (del "%temp%\noisemapscaled.png")
if exist "%temp%\scaledinput%imagecontainer%" (del "%temp%\scaledinput%imagecontainer%")
if exist "%temp%\palletforqm.jpg" (del "%temp%\palletforqm.jpg")
goto end

:: specific settings used for gif since you need -f gif - used for frying gifs
:gifmoment
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\scaledinput%imagecontainer%" -i "%temp%\noisemapscaled.png" -i "%temp%\noisemapscaled.png" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate%/%level% -pix_fmt yuv410p -filter_complex "split,displace=edge=wrap,scale=%desiredwidth%:%desiredheight%:flags=neighbo%sep%%fryfilter%" "%temp%\%filename%.mp4"
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\%filename%.mp4" -f gif "%filename%.gif"
goto endgifmoment

:: used for not frying gifs
:gifmoment1
ffmpeg -hide_banner -loglevel error -stats -i %1 -i "%temp%\palletforqm.jpg" -preset %encodingspeed% -c:v mjpeg -b:v %badimagebitrate% -pix_fmt yuv410p -filter_complex "paletteuse,scale=-2:%desiredheight%:flags=neighbor,noise=alls=%imageq%/4,eq=saturation=(%imageq%/50)+1:contrast=1+(%imageq%/50)" "%temp%\%filename%.mp4"
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\%filename%.mp4" -f gif "%filename%.gif"
goto endgifmoment1

:: asks if user wants to fry the video
:videofrying
choice /m "Do you want to fry the video? (will cause extreme distortion)"
if %errorlevel% == 2 call :clearlastprompt
if %errorlevel% == 2 goto encoding2
set frying=true
set /p level=How fried do you want the video, [93mfrom 1-10[0m: 
choice /m "Do you want the built-in color changes that come with frying?"
if %errorlevel% == 2 (set levelcolor=10) else (set levelcolor=%level%)
:: sets the amount to shift the video back by, fixing some unwanted effects of displacement)
set levelcolor=%level%
set /a shiftv=%desiredheight%/4
set /a shifth=%desiredwidth%/12
if %shifth% gtr 255 set shifth=255
if %shiftv% gtr 255 set shiftv=255
set shiftv=-%shiftv%
set shifth=-%shifth%
if %errorlevel% == 2 set levelcolor=1
set /a duration=((%duration%*%speedq%)+5)
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
echo [1A[38;2;254;165;0m1/6[0m
ffmpeg -hide_banner -loglevel error -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=%duration%:r=%framerate% -vf "noise=allf=t:alls=%level%*2:all_seed=%random%,eq=contrast=%level%*%level%" "%temp%\noisemap.mp4"
echo [2A[0J[38;2;254;165;0m2/6[0m
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\noisemap.mp4" -vf scale=%desiredwidth%:%desiredheight%:flags=neighbor "%temp%\noisemapscaled.mp4"
echo [2A[0J[38;2;254;165;0m3/6[0m
ffmpeg -hide_banner -loglevel error -stats -i %videoinp% -vf "fps=%framerate%,scale=%desiredwidth%:%desiredheight%:flags=neighbor" "%temp%\scaledinput%container%"
echo [2A[0J[38;2;254;165;0m4/6[0m
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\scaledinput%container%" -i "%temp%\noisemapscaled.mp4" -i "%temp%\noisemapscaled.mp4" -preset %encodingspeed% -c:v mjpeg -b:v %badvideobitrate%*2 -pix_fmt yuv410p -filter_complex "split,displace=edge=wrap,fps=%framerate%,scale=%desiredwidth%:%desiredheight%:flags=neighbor,%fryfilter%" "%temp%\scaledandfriedvideotemp%container%"
echo [2A[0J[38;2;254;165;0m5/6[0m
ffmpeg -hide_banner -loglevel error -stats -i "%temp%\scaledandfriedvideotemp%container%" -i "%temp%\noisemapscaled.mp4" -i "%temp%\noisemapscaled.mp4" -preset %encodingspeed% -c:v mjpeg -b:v %badvideobitrate%*2 -pix_fmt yuv410p -vf "fps=%framerate%,rgbashift=rh=%shifth%:rv=%shiftv%:bh=%shifth%:bv=%shiftv%:gh=%shifth%:gv=%shiftv%:ah=%shifth%:av=%shiftv%:edge=wrap" "%temp%\scaledandfriedvideotempfix%container%"
:: use the output of the 5th ffmpeg call as the input for the final encoding
set "videoinp=%temp%\scaledandfriedvideotempfix%container%"
if exist "%temp%\noisemap.mp4" (del "%temp%\noisemap.mp4")
if exist "%temp%\scaledandfriedvideotemp%container%" (del "%temp%\scaledandfriedvideotemp%container%")
if exist "%temp%\noisemapscaled.mp4" (del "%temp%\noisemapscaled.mp4")
echo [2A[0J[38;2;254;165;0m6/6[0m
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
curl -s "https://raw.githubusercontent.com/Thqrn/qualitymuncher/main/announce.txt" --output %temp%\anouncementQM.txt
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
if %cleanmode% == false goto :eof
echo [H[u[0J
goto :eof

:failure
echo [91mAnnouncements were not able to be accessed. Either you are not connected to the internet or GitHub is offline.[0m
pause
if %cleanmode% == false goto :eof
echo [H[u[0J
goto :eof

:titledisplay
cls
echo [s
cls
if %showtitle% == false goto skiptitle
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
echo.
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
:skiptitle
goto :eof

:: how the script exists the code
:ending
if %animate% == true goto closingbar