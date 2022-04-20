:: if you have any questions about this script, feel free to DM me on Discord, Frost#5872
@echo off
set version=1.3.11
set fromprompt=false
::set this to false to disable automatic update checks
set autoupdatecheck=true
:: sets the title of the window, some variables, and sends some ascii word art
set isupdate=false
title Quality Muncher Version %version%
if not 1%2 == 1 goto verystart
::checks for updates
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
if %autoupdatecheck% == true goto updatecheck

:: sets the title of the window and sends some ascii word art
title Quality Muncher Version %version%
:verystart
set stretchres=n
set colorq=n
set addedtextq=n
set interpq=n
set "qs=Quality Selected!"
echo        :^^~~~^^.        ^^.            ^^.       :^^        .^^.           .^^ .~~~~~~~~~~~~~~~: :~            .~.
echo     !5GP5YYY5PPY^^    :@?           :@J      :#@7       ~@!           Y^&..JYYYYYY@BJYYYYY! !BG~        .?#P:
echo   ~BG7:       :?BG:  ^^@J           :@Y     .BB5@~      !@!           Y@:       .@Y          7BG~    .?#G~
echo  7@J            .5^&^^ ^^@J           :@J     P^&: P^&:     !@!           Y@:       :@Y            7BG~.?#G~
echo :^&5               BB :@J           :@J    Y@^^  .B#.    !@!           Y@:       :@Y              7B^&G~
echo ~@7               5@.:@J           :@Y   ?@!    :^&G    !@!           Y@:       :@Y               ?@:
echo .#G              .^&P :@J           :@J  !@?      ^^@5   !@!           Y@:       :@Y               ?@^^
echo  ^^^&P:           .B#.  5^&^^          P^&: ^^@Y        !@J  !@!           Y@:       :@Y               ?@^^
echo   .YB5!:.   . !!:Y^&!   Y#5~.   .^^?BG^^ :^&P          ?@7 !@7           Y@:       :@Y               ?@^^
echo     .7YPPPPPP^^!YPP^&@7   :?5PPPPPPY~   5G.           YB.^^#GPPPPPPPPPJ ?B.       .B?               7#:
echo          ...     .^^?!       ....      .              .   ...........                              .
echo\
echo  ^^.            ^^. :.            :. ::            :.       .:^^~~^^:     .:            .:     :~~~~~~~~~^^ .^^~~~~~~~~^^:
echo ~@#!         ~B@!:@?           :^&J #^&J          .#5    :?PP5YYY5PG57. 7@^^           7@^^ .YGPYYYYYYYYY? J@5YYYYYYY5PG?.
echo ~@P#P:     :P#5@!:@J           :@Y ^&BGB~        .^&P  .Y#Y~.      .!PY ?@^^           ?@^^.#B:            J@:         ^^BB.
echo ~@!.5^&J  .J^&Y.~@!:@J           :@Y ^&5 ?#P:      .^&P .BB:              ?@^^           7@^^~@!             J@:          ?@^^
echo ~@7  ~BB~JP^^  ~@!:@J           :@Y ^&P  .5^&J     .^&P 5@:               ?@~.:::::::::.J@^^~@7.::::::::.   J@:...:::::~J#Y
echo ~@7    ?P:    ~@!:@J           :@Y ^&P    ~BB~   .^&P BB                ?@G5PPPPPPPPP5B@^^~@G55555555P?   J@^^Y^&^&G55555?:
echo ~@7           ~@!:@J           :@J ^&P      ?#P: .^&P J@^^               ?@^^           ?@^^~@!             J@: ~5B5^^
echo ~@7           ~@7 P^&^^          5@^^ ^&P       .5^&?.^&P  P^&~            . ?@^^           ?@^^~@!             J@:   :?BG7.
echo !@7           ~@7  Y#Y^^.    :7GB^^ .^&P         ~GB@P   ?BP7:.    .^^?G5 ?@^^           ?@^^~@!             J@:      !PBY^^
echo ^^#!           ^^^&~   :JPPP5PPPY!    BY           7#Y    .!YPPP55PPPJ~  7#:           !#:^^^&G55555555555J ?#:        :JB?
echo  .             .       ..::.                               .::::.      .             .  .::::::::::::.  .            .
echo\
color 0f
:: checks if ffmpeg is installed, and if it isn't, it'll send a tutorial to install it. 
where /q ffmpeg
if %errorlevel% == 1 (
     echo You either don't have ffmpeg installed or do not have it in PATH.
     echo Please install it as it's needed for this program to work.
	 choice /n /c gc /m "Press (g) for a guide on installing it, or (c) to close the script."
     if %errorlevel% == 1 start "" https://www.youtube.com/watch?v=WwWITnuWQW4
     exit
)
:inputcheck
set confirmselec=n
:: checks if someone used the script correctly
if %1check == check goto noinput
:: intro, questions and defining variables
echo Frost's Quality Muncher is still in development. This is version %version%.
echo Please DM me at Frost#5872 for support or questions, or join https://discord.gg/9tRZ6C7tYz
:: asks advanced or simple version
echo\
set complexity=s
if not 1%2 == 1 goto skippedlol

::offer update
if not %isupdate% == true goto modeselect
if not %fromprompt% == false goto modeselect
echo There is a new version (%newversion%) of Quality Muncher available!
echo Press (g) to open the GitHub page or (s) to skip.
echo To hide this message in the future, set the variable "autoupdatecheck" on line 4 to false.
choice /c GS /n
echo\
if %errorlevel% == 2 goto modeselect
start "" %download%

:modeselect
choice /n /c SAWDC /m "Press (s) for simple, (a) for advanced), (w) to open the website, (d) to open the discord server, and (c) to exit."
echo\
if %errorlevel% == 2 goto advancedfour
if %errorlevel% == 3 goto website
if %errorlevel% == 4 goto discord
if %errorlevel% == 5 exit
echo Simple mode selected!
set complexity=s
echo\
:continuefour
:customization
:customizationoption
choice /n /c 1234c /m "Your options for quality are decent (1), bad (2), terrible (3), unbearable (4), and custom (c)."
set customizationquestion=%errorlevel%
if %customizationquestion% == 5 set customizationquestion=c
:skippedlol
if not 1%2 == 1 set customizationquestion=%2
if 1%2 == 1 goto skipcustommultiqueue
if not 1%2 == 1 (
     if %2 == c (
         echo\
         echo Custom %qs%
	     echo\
         set framerate=%3
         set videobr=%4
         set audiobr=%5
         set scaleq=%6
	     if %7 == 1 set details=y
         set endingmsg=Custom Quality
		 goto setendingmsg
	 )
)
:skipcustommultiqueue
:: defines a few variables that will be replaced later, this is important for checking if they're valid later as it prevents missing operand errors
set framerate=a
set videobr=a
set audiobr=a
set scaleq=a
set details=n
:: Sets the quality based on customizationquestion
:: endingmsg is added to the end of the video for the output name (if you don't understand, just run the script and look at the name of the output)
:customquestioncheckpoint
if "%customizationquestion%" == "c" (
     echo\
     echo Custom %qs%
	 echo\
     set /p framerate=What fps do you want it to be rendered at: 
     set /p videobr=On a scale from 1 to 10, how bad should the video bitrate be? 1 bad, 10 very very bad: 
     set /p audiobr=On a scale from 1 to 10, how bad should the audio bitrate be? 1 bad, 10 very very bad: 
     set /p scaleq=On a scale from 1 to 10, how much should the video be shrunk by? 1 none, 10 a lot: 
	 choice /m "Do you want a detailed file name for the output?"
     set endingmsg=Custom Quality
)
if "%customizationquestion%" == "c" (
	 if %errorlevel% == 1 set details=y
)
if %customizationquestion% == 1 (
     echo\
     echo Decent %qs%
     set framerate=24
     set videobr=3
     set scaleq=2
     set audiobr=3
     set endingmsg=Decent Quality
)
if %customizationquestion% == 2 (
     echo\
     echo Bad %qs%
     set framerate=12
     set videobr=5
     set scaleq=4
     set audiobr=5
     set endingmsg=Bad Quality
)
if %customizationquestion% == 3 (
     echo\
     echo Terrible %qs%
     set framerate=6
     set videobr=8
     set scaleq=8
     set audiobr=8
     set endingmsg=Terrible Quality
)
if %customizationquestion% == 4 (
     echo\
     echo Unbearable %qs%
     set framerate=1
     set videobr=16
     set scaleq=12
     set audiobr=9
     set endingmsg=Unbearable Quality
)
:: checks if the variables are all whole numbers, if they aren't it'll ask again for their values
set /a testforfps=%framerate%
set /a testforvideobr=%videobr%
set /a testforaudiobr=%audiobr%
set /a testforscaleq=%scaleq%
set errormsg=One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
if NOT %testforfps% == %framerate% (
     goto errorcustom
)
if NOT %testforvideobr% == %videobr% (
     goto errorcustom
)
if NOT %testforaudiobr% == %audiobr% (
     goto errorcustom
)
if NOT %testforscaleq% == %scaleq% (
     goto errorcustom
)
if "%framerate%" == " " (
     goto errorcustom
)
if "%videobr%" == " " (
     goto errorcustom
)
if "%audiobr%" == " " (
     goto errorcustom
)
if "%scaleq%" == " " (
     goto errorcustom
)
:setendingmsg
set inputvideo=%1
ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -i %inputvideo% -of csv=p=0 > %temp%\fps.txt
set /p fpsvalue=<%temp%\fps.txt
set /a fpsvalue=%fpsvalue%
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
:: makes the endingmsg contain more details if it's been selected (only available in the custom preset)
if /I %details% == y set endingmsg=Custom Quality - %framerate% fps^, %videobr% video bitrate input^, %audiobr% audio bitrate input^, %scaleq% scale
if NOT %complexity% == s goto advancedone
:continueone
:: Sets the audio and video bitrate based on audiobr and videobr, adjusting based on framerate and resolution
set /A badaudiobitrate=80/%audiobr%
set /A badvideobitrate=(100*%framerate%/%videobr%)/%scaleq%
:: grabs info from video to be used later
set inputvideo=%1
if NOT %complexity% == s goto advancedtwo
:continuetwo
set yeahlowqual=n
:filters
echo\
:: Finds if the height of the video divided by scaleq is an even number, if not it changes it to an even number
set /A desiredheight=%height%/%scaleq%
set /A desiredheighteventest=(%desiredheight%/2)*2
if %desiredheighteventest% == NOT %desiredheight% (
     set /A desiredheight=%desiredheighteventest%
)
set /A desiredwidth=%width%/%scaleq%
set /A desiredwidtheventest=(%desiredwidth%/2)*2
if %complexity% == s set stretchres=n
if %stretchres% == y (
     set widthtest1=%desiredwidtheventest%*2
     set /a badvideobitrate=%badvideobitrate%*2
)
set interpq=n
if NOT %complexity% == s (
     if %framerate% gtr %fpsvalue% (
		 choice /c YN /m "The framerate of your input exceeds the framerate of the output. Interpolate to fix this?"
		 if %errorlevel% == 1 set interpq=y
	     echo\
     )
)
:: defines filters
:: filters not working bc interpolating, need fix (filters work but interp doesnt)
set filters=-vf %textfilter%%speedfilter%fps=%framerate%,scale=-2:%desiredheight%:flags=neighbor,format=yuv420p%videofilters%"
if %interpq% == y (
     set filters=-vf %textfilter%%speedfilter%scale=-2:%desiredheight%:flags=neighbor,minterpolate=fps=%framerate%,format=yuv420p%videofilters%"
)
if %stretchres% == y (
     set filters=-vf %textfilter%%speedfilter%fps=%framerate%,scale=%widthtest1%:%desiredheight%:flags=neighbor,setsar=1:1,format=yuv420p%videofilters%"
	 if %interpq% == y (
         set filters=-vf %textfilter%%speedfilter%scale=%widthtest1%:%desiredheight%:flags=neighbor,setsar=1:1,minterpolate=fps=%framerate%,format=yuv420p%videofilters%"
     )
)
if %colorq% == y (
     set filters=-vf %textfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,fps=%framerate%,scale=-2:%desiredheight%:flags=neighbor,format=yuv420p%videofilters%"
	 if %interpq% == y (
         set filters=-vf %textfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,scale=-2:%desiredheight%:flags=neighbor,minterpolate=fps=%framerate%,format=yuv420p%videofilters%"
     )
     if %stretchres% == y (
          set filters=-vf %textfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,fps=%framerate%,scale=%widthtest1%:%desiredheight%:flags=neighbor,setsar=1:1,format=yuv420p%videofilters%"
		 if %interpq% == y (
             set filters=-vf %textfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,scale=%widthtest1%:%desiredheight%:flags=neighbor,setsar=1:1,minterpolate=fps=%framerate%,format=yuv420p%videofilters%"
         )
     )
)
if %complexity% == s set filters=-vf "fps=%framerate%,scale=-2:%desiredheight%:flags=neighbor,format=yuv420p%videofilters%"
:: bass boosting
set audiofilters= 
set bassboosted=n
if NOT %complexity% == s goto advancedthree
:encoding
echo Encoding...
echo\
color 06
if %complexity% == s (
     set time=32727
     set starttime=0
     goto optionthree
)
if %yeahlowqual% == n goto optionone
goto optiontwo
:: option one, no extra music
:optionone
ffmpeg -hide_banner -loglevel error -stats ^
-ss %starttime% -t %time% -i %1 ^
%filters% ^
-c:v libx264 -preset ultrafast -b:v %badvideobitrate%000 ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +faststart "%~dpn1 (%endingmsg%).mp4"
goto end
::option two, there is music
:optiontwo
ffmpeg -hide_banner -loglevel warning -stats ^
-ss %starttime% -t %time% -i %1 -ss %musicstarttime% -i %lowqualmusic% ^
%filters% ^
-c:v libx264 -preset ultrafast -b:v %badvideobitrate%000 ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +faststart "%~dpn1 (%endingmsg%).mp4"
goto end
:optionthree
ffmpeg -hide_banner -loglevel error -stats ^
-i %1 ^
%filters% ^
-c:v libx264 -preset ultrafast -b:v %badvideobitrate%000 ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +faststart "%~dpn1 (%endingmsg%).mp4"
goto end
:end
if exist "%temp%\height.txt" (del "%temp%\height.txt")
if exist "%temp%\width.txt" (del "%temp%\width.txt")
if exist "%temp%\fps.txt" (del "%temp%\fps.txt")
if exist "%temp%\toptext.txt" (del "%temp%\toptext.txt")
if exist "%temp%\bottomtext.txt" (del "%temp%\bottomtext.txt")
echo\
echo Done!
echo\
color 0A
if 1%2 == 1 goto :exiting
if not 1%2 == 1 goto :ending




:advancedone
:: speed
set speedvalid=n
set speedq=default
echo\
set /p speedq=What should the playback speed of the video be, must be a positive number between 0.5 and 100, default is 1: 
if "%speedq%" == " " (
     set speedq=default
)
if "%speedq%" == "n" set speedq=1
if %speedq% == default (
     echo\
     echo No valid input given, speed has been set to default.
     set speedvalid=y
     set speedq=1
     goto cont
)
if %speedvalid% == y goto cont
set string=%speedq%
for /f "delims=." %%a in ("%string%") do if NOT "%%a"=="%string%" set speedvalid=y
if %speedvalid% == y goto cont
set /a speedqCheck=%speedq%
if NOT %speedqCheck% == %speedq% (set speedvalid=n) else (set speedvalid=y)
:cont
set speedfilter="setpts=(1/%speedq%)*PTS,"
set speedfilter=%speedfilter:"=%
:addtext
echo\
:: add text
choice /c YN /m "Do you want to add text to the video?"
if %errorlevel% == 1 set addedtextq=y
if %addedtextq% == n set textfilter="
if %addedtextq% == n goto continueone
:: top text
set "toptext= "
set /p toptext=Top text: 
set toptextnospace=%toptext: =_%
echo "%toptextnospace%" > %temp%\toptext.txt
set /p toptextnospace=<%temp%\toptext.txt
for %%? in (%temp%\toptext.txt) do ( set /A strlength=%%~z? - 2 )
if %strlength% LSS 16 set strlength=16
set /a fontsize=(%width%/%strlength%)*2
set toptext=%toptext:"=%
:: bottom text
set "bottomtext= "
set /p bottomtext=Bottom text: 
set bottomtextnospace=%bottomtext: =_%
echo "%bottomtextnospace%" > %temp%\bottomtext.txt
set /p bottomtextnospace=<%temp%\bottomtext.txt
for %%? in (%temp%\bottomtext.txt) do ( set /A strlengthb=%%~z? - 2 )
if %strlengthb% LSS 16 set strlengthb=16
set /a fontsizebottom=(%width%/%strlengthb%)*2
set bottomtext=%bottomtext:"=%
:: setting text filter
set "textfilter=1drawtext=borderw=(%fontsize%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%toptext%':fontcolor=white:fontsize=%fontsize%:x=(w-text_w)/2:y=(0.25*text_h),drawtext=borderw=(%fontsizebottom%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%bottomtext%':fontcolor=white:fontsize=%fontsizebottom%:x=(w-text_w)/2:y=(h-1.25*text_h),"
set textfilter=%textfilter:1drawtext="drawtext%
goto continueone


:advancedtwo
echo\
:: allows the user to have the choice of modifying saturation and contrast.
set contrastvalue=1
set saturationvalue=1
set brightnessvalue=0
choice /c YN /m "Do you want to customize saturation, contrast, and brightness?"
if %errorlevel% == 1 set colorq=y
set contrastvaluefalse=n
set saturationvaluefalse=n
set brightnessvaluefalse=n
if %colorq% == y (
     set /p contrastvalue=Select a contrast value between -1000.0 and 1000.0, default is 1: 
     set /p saturationvalue=Select a saturation value between 0.0 and 3.0, default is 1: 
     set /p brightnessvalue=Select a brightness value between -1.0 and 1.0, default is 0: 
)
:: the next lines test if the values defined above are invalid, don't ask why we use a different method every time
if %colorq% == y (
     set "errormsgcol=value was invalid, it has been set to the default."
     if "%contrastvalue%" == " " (
          set contrastvaluefalse=y
     )
     if "%saturationvalue%" == " " (
          set saturationvaluefalse=y
     )
     if "%brightnessvalue%" == " " (
          set brightnessvaluefalse=y
     )
     for /f "tokens=1* delims=-.0123456789" %%j in ("j0%contrastvalue:"=%") do (
          if not "%%k"=="" set contrastvaluefalse=y
     )
     for /f "tokens=1* delims=.0123456789" %%l in ("l0%saturationvalue:"=%") do (
          if not "%%m"=="" set saturationvaluefalse=y
     )
     for /f "tokens=1* delims=-.0123456789" %%n in ("n0%brightnessvalue:"=%") do (
          if not "%%o"=="" set brightnessvaluefalse=y
     )
)
if %contrastvaluefalse% == y (
     echo\
     echo Contrast %errormsgcol%
     set contrastvalue=1
)
if %saturationvaluefalse% == y (
     echo\
     echo Saturation %errormsgcol%
     set saturationvalue=1
)
if %brightnessvaluefalse% == y (
     echo\
     echo Brightness %errormsgcol%
     set brightnessvalue=0
)
:stretch
echo\
:: asks about stretching the video
choice /c YN /m "Do you want to stretch the video horizontally?"
if %errorlevel% == 1 set stretchres=y
:: defines things for music and asks if they want music
:lowqualmusicq
set musicstarttime=0
set musicstartest=0
set lowqualmusicquestion=n
set filefound=y
echo\
choice /c YN /m "Do you want to add music?"
if %errorlevel% == 1 set lowqualmusicquestion=y
:addingthemusic
:: asks for a specific file to get music from
if %lowqualmusicquestion% == y (
     set yeahlowqual=y
     set /p lowqualmusic=Please drag the desired file here, it must be an audio file: 
)
:: sets a variable if it's a valid file
if %lowqualmusicquestion% == y (
     set filefound=n
     if exist %lowqualmusic% set filefound=y
)
:: if its not a valid file it sends the user back to add a valid file
if %filefound% == n (
     echo\
     echo Invalid file! Please drag an existing file from your computer!
     echo\
     goto addingthemusic
)
:musicstartq
:: asks the user when the music should start
if %lowqualmusicquestion% == y (
     set /p musicstarttime=Enter a specific start time of the music in seconds: 
     goto filters
)
goto continuetwo


:advancedthree
choice /c YN /m "Do you want to distort the audio (earrape)?"
if %errorlevel% == 1 set bassboosted=y
if %bassboosted% == y set /p distortionseverity=How distorted should the audio be, 1-10: 
if %bassboosted% == y set /a distsev=%distortionseverity%*10
if %bassboosted% == y (
     set audiofilters=-af "firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
)
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %speedq% == 1 (
     set audiofilters=-af "atempo=%speedq%"
     if %bassboosted% == y (
          set audiofilters=-af "atempo=%speedq%,firequalizer=gain_entry='entry(0,100);entry(600,100);entry(1500,100);entry(3000,100);entry(6000,100);entry(12000,100);entry(16000,100)'"
     )
)
echo\
goto encoding



:advancedfour
set complexity=a
echo Advanced mode selected!
echo\
:: asks where to start clip
:startquestion
set starttime=0
set /p starttime=In seconds, where do you want your clip to start: 
if "%starttime%" == " " set starttime=0
:: asks length of clip
:timequestion
set time=32727
set /p time=In seconds, how long after the start time do you want it to be: 
if "%time%" == " " set time=32727
echo\
goto continuefour


:middletext
set textposx=(w-text_w)/2
set textposy=(h-text_h)/2
goto afterpos


:bottomtext
set textposx=(w-text_w)/2
set textposy=(h-1.5*text_h)
goto afterpos

:errorcustom
echo\
echo %errormsg%
echo\
goto customquestioncheckpoint

:toptext
set textposx=(w-text_w)/2
set textposy=(0.5*text_h)
goto afterpos

:discord
echo Sending to Discord!
start "" https://discord.com/invite/9tRZ6C7tYz
echo\
cls && goto verystart

:website
echo Sending to website!
start "" http://catgirl.church/
echo\
cls && goto verystart

:noinput
echo ERROR: no input file
echo Drag this .bat into the SendTo folder - press Windows + R and type in shell:sendto
echo After that, right click on your video, drag over to Send To and click on this bat there.
echo\
if not %isupdate% == true goto choicenoinput
goto choicenoinputupdate
:choicenoinput
choice /n /c WDC /m "Press (w) to open the website, (d) to open the discord server, or (c) to exit."
echo\
set confirmselec=y
if %errorlevel% == 1 goto website
if %errorlevel% == 2 goto discord
exit
:choicenoinputupdate
echo Press (w) to open the website, (d) to open the discord server, or (c) to exit.
echo There is a new version (%newversion%) available to download. Press (g) to open.
choice /n /c WDCG
echo\
set confirmselec=y
if %errorlevel% == 1 goto website
if %errorlevel% == 2 goto discord
if %errorlevel% == 3 exit
set "download=https://github.com/Thqrn/qualitymuncher/blob/main/Quality%%20Muncher.bat"
start "" %download%
cls && goto verystart

:exiting
pause && exit

:updatecheck
set "download=https://github.com/Thqrn/qualitymuncher/blob/main/Quality%%20Muncher.bat"
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 goto nointernet
set internet=true
curl -s "https://raw.githubusercontent.com/Thqrn/qualitymuncher/main/version.txt" --output %temp%\QMnewversion.txt
set /p newversion=<%temp%\QMnewversion.txt
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
if "%version%" == "%newversion%" (set isupdate=false) else (set isupdate=true)
goto verystart

:nointernet
set internet=false
echo Update check failed, skipping.
echo\
goto verystart

:ending