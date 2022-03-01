@echo off
:: sets the title of the windoww and sends some ascii word art
set version=1.3.1
title Quality Muncher Version %version%
echo\
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
if errorlevel 1 (
     echo You either don't have ffmpeg installed or do not have it in PATH.
	 echo Please install it as it's needed for this program to work.
	 echo Here is a tutorial: https://www.youtube.com/watch?v=WwWITnuWQW4
     pause
	 exit
) else (
    goto inputcheck
)
:inputcheck
:: checks if someone used the script correctly
if %1check == check (
     echo ERROR: no input file
     echo Drag this .bat into the SendTo folder - press Windows + R and type in shell:sendto
     echo After that, right click on your video, drag over to Send To and click on this bat there.
     pause
     exit
)
:: intro, questions and defining variables
echo Frost's Quality Muncher is still in development. This is version %version%
echo Please DM me at Frost#5872 for support or questions, or join https://discord.gg/9tRZ6C7tYz
:: asks where to start clip
:startquestion
set /p starttime=Where do you want your clip to start (in seconds): 
:: checks if it's a positive number, if not then goes back to asking for start time
if 1%starttime% NEQ +1%starttime% (
     echo\
     echo Not a valid number, please enter ONLY whole numbers!
	 echo\
	 goto startquestion
)
if "%starttime%" == " " (
     echo\
     echo Not a valid number, please enter ONLY whole numbers!
	 echo\
	 goto startquestion
)
:: asks length of clip
:timequestion
set /p time=How long after the start time do you want it to be: 
:: checks if it's a postive number, if not then goes back to asking how long it should be
if 1%time% NEQ +1%time% (
     echo\
     echo Not a valid number, please enter ONLY whole numbers!
	 echo\
	 goto timequestion
)
if "%time%" == " " (
     echo\
     echo Not a valid number, please enter ONLY whole numbers!
	 echo\
	 goto timequestion
)
:customization
:: asks for the option and lists them
echo Options:
echo Decent (1)
echo Bad (2)
echo Terrible (3)
echo Unbearable (4)
echo Custom (c)
:customizationoption
set /p customizationquestion=Please enter an option: 
if "%customizationquestion%" == " " (
     echo\
     echo Not a valid option, please try again!
	 echo\
	 goto customizationoption
)
:: defines a few variables that are important for checking if theres a valid input (validanswer) and one that is only used by one other option (details in custom quality)
set details=n
set validanswer=n
:: defines a few variables that will be replaced later, this is very important for checking if they're valid later as it prevents missing operand errors
set framerate=a
set videobr=a
set audiobr=a
set scaleq=a
:: making sure even if people use wrong capitalization it still works
set fixuserreadingerror=false
if %customizationquestion% == c set fixuserreadingerror=true
if %customizationquestion% == C set fixuserreadingerror=true
:: Sets the quality based on customizationquestion
:: validanswer is used to determine if they entered a valid answer to customization question
:: endingmsg is added to the end of the video for the output name (if you dont understand, just run the script and look at the name of the output)
if %fixuserreadingerror% == true (
     echo\
	 echo Custom Quality Selected!
)
:customquestioncheckpoint
if %fixuserreadingerror% == true (
     set /p framerate=What fps do you want it to be rendered at: 
     set /p videobr=On a scale from 1 to 10, how bad should the VIDEO bitrate be? 1 bad, 10 very very bad: 
     set /p audiobr=On a scale from 1 to 10, how bad should the AUDIO bitrate be? 1 bad, 10 very very bad: 
     set /p scaleq=On a scale from 1 to 10, how much should the video be shrunk by? 1 none, 10 a lot: 
	 set /p details=Do you want a detailed file name for the output? y or n: 
	 set endingmsg=Custom Quality
	 set validanswer=y
)
if "%details%" == " " (
     echo\
     echo Not a valid option, please try again!
     echo\
     goto customquestioncheckpoint
)
if %customizationquestion% == 1 (
     echo\
	 echo Decent Quality Selected!
     set framerate=24
     set videobr=3
     set scaleq=2
	 set audiobr=3
	 set endingmsg=Decent Quality
	 set validanswer=y
)
if %customizationquestion% == 2 (
     echo\
	 echo Bad Quality Selected!
     set framerate=12
     set videobr=5
     set scaleq=4
	 set audiobr=5
	 set endingmsg=Bad Quality
	 set validanswer=y
)
if %customizationquestion% == 3 (
     echo\
	 echo Terrible Quality Selected!
     set framerate=6
     set videobr=8
     set scaleq=8
	 set audiobr=8
	 set endingmsg=Terrible Quality
	 set validanswer=y
)
if %customizationquestion% == 4 (
     echo\
	 echo Unbearable Quality Selected!
     set framerate=1
     set videobr=16
     set scaleq=12
	 set audiobr=9
	 set endingmsg=Unbearable Quality
	 set validanswer=y
)
:: if a user didn't enter a valid answer, this is what they'll get
if %validanswer% == n (
     echo\
	 echo Please enter a valid answer!
	 echo\
	 goto customizationoption
)
:: checks if the variables are all whole numbers, if they aren't it'll ask again for their values
set /a testforfps=%framerate%
set /a testforvideobr=%videobr%
set /a testforaudiobr=%audiobr%
set /a testforscaleq=%scaleq%
if NOT %testforfps% == %framerate% (
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
	 echo\
     goto customquestioncheckpoint
)
if NOT %testforvideobr% == %videobr% (]
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
	 echo\
     goto customquestioncheckpoint
)
if NOT %testforaudiobr% == %audiobr% (
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
     echo\
     goto customquestioncheckpoint
)
if NOT %testforscaleq% == %scaleq% (
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
	 echo\
     goto customquestioncheckpoint
)
if "%framerate%" == " " (
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
	 echo\
	 goto customquestioncheckpoint
)
if "%videobr%" == " " (
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
	 echo\
	 goto customquestioncheckpoint
)
if "%audiobr%" == " " (
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
	 echo\
	 goto customquestioncheckpoint
)
if "%scaleq%" == " " (
     echo\
     echo One or more of your inputs for custom quality was invalid! Please only use whole numbers and no letters!
	 echo\
	 goto customquestioncheckpoint
)
:setendingmsg
:: makes the endingmsg contain more details if it's been selected (only available in the custom preset)
if %details% == y (
     set endingmsg=Custom Quality - %framerate% fps^, %videobr% video bitrate input^, %audiobr% audio bitrate input^, %scaleq% scale
)
:speedquestion
:: speed
set speedvalid=n
set speedq=default
set /p speedq=What should the playback speed of the video be, must be a positive number between 0.01 and 2, default is 1: 
if "%speedq%" == " " (
     set speedq=default
)
if "%speedq%" == "n" (
     set speedq=1
)
if %speedq% == default (
     echo\
	 echo No valid input given, speed has been set to default.
	 set speedvalid=y
	 set speedq=1
	 goto cont
)
if %speedvalid% == y (
     goto cont
)
set string=%speedq%
for /f "delims=." %%a in ("%string%") do if NOT "%%a"=="%string%" set speedvalid=y
if %speedvalid% == y (
     goto cont
)
set /a speedqCheck=%speedq%
if NOT %speedqCheck% == %speedq% (set speedvalid=n) else (set speedvalid=y)
:cont
set speedfilter="setpts=(1/%speedq%)*PTS,"
set speedfilter=%speedfilter:"=%
:addtext
echo\
:: add text
set /p addedtextq=Do you want to add text to the video? y/n: 
if "%addedtextq%" == " " (
     set addedtextq=n
)
if %addedtextq% == n (
     goto textfilters
)
set texttoadd=test
if %addedtextq% == y (
     set /p texttoadd=Enter the text now: 
)
if %addedtextq% == y (
     echo "%texttoadd%" > %temp%\textforquality.txt
	 set /p addtext=<%temp%\textforquality.txt
	 set /a scaleqhalf=%scaleq%/2
	 for %%? in (%temp%\textforquality.txt) do ( set /A strlength=%%~z? - 2 )
)
:textfilters
set textfilter="
if %addedtextq% == n (
     goto hwaccel
)
if %addedtextq% == y (
     if %strlength% LSS 4 set strlength=4
)
if %addedtextq% == y (
     set /a halflength=%strlength%/4
)
if %addedtextq% == y (
     set /a fontsize=500/%halflength%
	 set addtext=%addtext:"=%
)
if %addedtextq% == y (
     set textfilter="drawtext=fontfile=C\\:/Windows/Fonts/impact.ttf:text='%addtext%':fontcolor=white:fontsize=%fontsize%:x=(w-text_w)/2:y=(h-text_h)/2,1"
)
if %addedtextq% == y (
     set textfilter=%textfilter:1"=%
)
:hwaccel
:: hwaccel
set hwaccel=-hwaccel %hwaccel%
:: Sets the audio and video bitrate based on audiobr and videobr, adjusting based on framerate and resolution
set /A badaudiobitrate=80/%audiobr%
set /A badvideobitrate=(100*%framerate%/%videobr%)/%scaleq%
:: Credits to Couleur's CTT Upscaler 2.0 for the next 5 lines of code, used to grab the width and height of the input video and set them to variables for use later
set inputvideo=%*
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
echo\
:: allows the user to have the choice of modyfying saturation and contrast.
set contrastvalue=1
set saturationvalue=1
set brightnessvalue=0
set /p colorq=Do you want to customize saturation, contrast, and brightness, y/n: 
if "%colorq%" == " " (
     set colorq=n
)
set contrastvaluefalse=n
set saturationvaluefalse=n
set brightnessvaluefalse=n
if %colorq% == y (
     set /p contrastvalue=Select a contrast value between -1000.0 and 1000.0, default is 1: 
     set /p saturationvalue=Select a saturation value between 0.0 and 3.0, default is 1: 
     set /p brightnessvalue=Select a brightness value between -1.0 and 1.0, default is 0: 
)
:: the next lines test if the values defined above are invalid, dont ask why we use a different method every time
if %colorq% == y (
     set /p contrastvalue=Select a contrast value between -1000.0 and 1000.0, default is 1: 
     set /p saturationvalue=Select a saturation value between 0.0 and 3.0, default is 1: 
     set /p brightnessvalue=Select a brightness value between -1.0 and 1.0, default is 0: 
)
if %colorq% == y (
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
	 for /f "tokens=1* delims=-.0123456789" %%l in ("l0%saturationvalue:"=%") do (
   	     if not "%%m"=="" set saturationvaluefalse=y
	 )
	 for /f "tokens=1* delims=-.0123456789" %%n in ("n0%brightnessvalue:"=%") do (
 	     if not "%%o"=="" set brightnessvaluefalse=y
	 )
)
if %contrastvaluefalse% == y (
     echo\
	 echo Contrast value was invalid, it has been set to the default.
	 set contrastvalue=1
)
if %saturationvaluefalse% == y (
     echo\
	 echo Saturation value was invalid, it has been set to the default.
	 set saturationvalue=1
)
if %brightnessvaluefalse% == y (
     echo\
	 echo Brightness value was invalid, it has been set to the default.
	 set brightnessvalue=0
)
:stretch
echo\
:: asks about stretching the video
set /p stretchres=Do you want to stretch the video horizonatlly, y/n: 
if "%stretchres%" == " " (
     set stretchres=n
)
echo\
:: defines things for music and asks if they want music
:lowqualmusicq
set musicstarttime=0
set musicstartest=0
set lowqualmusicquestion=n
set filefound=y
set /p lowqualmusicquestion=Do you want to add low quality music in the background? y/n: 
if "%lowqualmusicquestion%" == " " (
     echo\
     echo Not a valid option, please try again!
	 echo\
	 goto lowqualmusicq
)
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
)
if %lowqualmusicquestion% == y (
	 if "%musicstarttime%" == " " (
         echo\
         echo Not a valid number, please enter ONLY whole numbers!
	     echo\
	     goto musicstartq
     )
)
:: tests if it's a number
if %lowqualmusicquestion% == y (
	 set /a musicstartest=%musicstarttime%
)
:: if its not a number it makes them go back and do it again
if %lowqualmusicquestion% == y (
	 if NOT %musicstarttime% == %musicstartest% (
         echo\
         echo Not a valid number, please enter ONLY whole numbers!
	     echo\
	     goto musicstartq
     )
	 if "%musicstarttime%" == " " (
         echo\
         echo Not a valid number, please enter ONLY whole numbers!
	     echo\
	     goto musicstartq
     )
	 goto filters
)
set yeahlowqual=n
:filters
:: Finds if the height of the video divided by scaleq is an even number, if not it changes it to an even number
set /A desiredheight=%height%/%scaleq%
set /A desiredheighteventest=(%desiredheight%/2)*2
if %desiredheighteventest% == NOT %desiredheight% (
     set /A desiredheight=%desiredheighteventest%
)
set /A desiredwidth=%width%/%scaleq%
set /A desiredwidtheventest=(%desiredwidth%/2)*2
if %stretchres% == y (
     set widthtest1=%desiredwidtheventest%*2
	 set /a badvideobitrate=%badvideobitrate%*2
)
:: defines filters
set filters=-vf %textfilter%%speedfilter%fps=%framerate%,scale=-2:%desiredheight%,format=yuv420p%videofilters%"
if %stretchres% == y (
	 set filters=-vf %textfilter%%speedfilter%fps=%framerate%,scale=%widthtest1%:%desiredheight%,setsar=1:1,format=yuv420p%videofilters%"
)
if %colorq% == y (
     set filters=-vf %textfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,fps=%framerate%,scale=-2:%desiredheight%,format=yuv420p%videofilters%"
	 if %stretchres% == y (
	     set filters=-vf %textfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,fps=%framerate%,scale=%widthtest1%:%desiredheight%,setsar=1:1,format=yuv420p%videofilters%"
     )
)
:: bass boosting
set audiofilters= 
set bassboosted=n
echo\
set /p bassboosted=Do you want to bass boost the audio, y/n (warning, causes distortion): 
if "%bassboosted%" == " " (
     set bassboosted=n
)
if %bassboosted% == y (
     set audiofilters=-af "firequalizer=gain_entry='entry(0,-3);entry(75,2);entry(250,15);entry(500,1);entry(1000,-5);entry(4000,-5);entry(16000,-5)'"
)
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %speedq% == 1 (
     set audiofilters=-af "atempo=%speedq%"
	 if %bassboosted% == y (
         set audiofilters=-af "atempo=%speedq%,firequalizer=gain_entry='entry(0,-3);entry(75,2);entry(250,15);entry(500,1);entry(1000,-5);entry(4000,-5);entry(16000,-5)'"
     )
)
:encoding
echo\
echo Encoding...
echo\
color 06
if %yeahlowqual% == n (
     goto optionone
)
goto optiontwo
:: option one, no extra music
:optionone
ffmpeg -hide_banner -loglevel error -stats ^
-ss %starttime% -t %time% -i %1 ^
%filters% ^
-c:v libx264 -preset ultrafast -b:v %badvideobitrate%000 ^
-c:a aac -b:a %badaudiobitrate%000 ^
%audiofilters% ^
-vsync vfr -movflags +faststart "%~dpn1 (%endingmsg%).mp4"
goto end
::option two, there is music
:optiontwo
ffmpeg -loglevel warning -stats ^
-ss %starttime% -t %time% -i %1 -ss %musicstarttime% -i %lowqualmusic% ^
%filters% ^
-c:v libx264 -preset ultrafast -b:v %badvideobitrate%000 ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +faststart "%~dpn1 (%endingmsg%).mp4"
:end
echo\
echo Done!
echo\
color 0A
pause
