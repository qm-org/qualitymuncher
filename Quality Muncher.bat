:: if you have any questions about this script, feel free to DM me on Discord, Frost#5872
@echo off

:: OPTIONS - THESE RESET AFTER UPDATING SO KEEP A COPY SOMEWHERE
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
	 set audiocontainer=.mp3
:: END OF OPTIONS

:: batch breaking for no reason counter: 10

:: if you mess with stuff after this things might break
set inpcontain=%~x1
if not check%2 == check set animate=false&set alwaysaskresample=false
set cols=14
set lines=8
set done=false
set hasvideo=true
set bassboosted=n
if %animate% == true goto loadingbar
:init
:: sets the title of the window, some variables, and sends an ascii thing
set version=1.3.17
set isupdate=false
if check%2 == check title Quality Muncher v%version%
if %log% == true set meta=true
if not check%2 == check set showtitle=false&goto verystart
:: checks for updates
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
if %autoupdatecheck% == true goto updatecheck

:verystart
set stretchres=n
set colorq=n
set addedtextq=n
set interpq=n
set resample=n
set "qs=Quality Selected!"
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
echo\
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
echo\
:skiptitle
:: checks if ffmpeg is installed, and if it isn't, it'll send a tutorial to install it. 
where /q ffmpeg
if %errorlevel% == 1 (
     echo [91mERROR: You either don't have ffmpeg installed or don't have it in PATH.[0m
     echo Please install it as it's needed for this program to work.
	 choice /n /c gc /m "Press [G] for a guide on installing it, or [C] to close the script."
     if %errorlevel% == 1 start "" https://www.youtube.com/watch?v=WwWITnuWQW4
     exit
)
:inputcheck
set confirmselec=n
:: checks if someone used the script correctly
echo Quality Muncher is still in development. This is version %version%. & echo Please DM me at Frost#5872 for any questions or support, or join the discord server. & echo\
if %1check == check goto noinput
:: has input, now checks for video streams
set inputvideo=%1
ffprobe -i %inputvideo% -show_streams -select_streams v -loglevel error > %temp%\vstream.txt
set /p vstream=<%temp%\vstream.txt
if 1%vstream% == 1 goto novideostream
:: this line has to be filled or else batch shits itself and dies (yes this is serious, i dont even know why)
:: intro, questions and defining variables
:: asks advanced or simple version
set complexity=s
if not check%2 == check goto skipped

:modeselect
echo Press [S] for simple, [A] for advanced, [W] to open the website, [D] to join the discord server, [P] to make a suggestion, or
echo [C] to close.
choice /n /c SAWDCP
echo\
if %errorlevel% == 2 goto advancedfour
if %errorlevel% == 3 echo [96mSending to website![0m & start "" https://qualitymuncher.lgbt/ & cls & goto verystart
if %errorlevel% == 4 goto discord
if %errorlevel% == 5 goto closingbar
if %errorlevel% == 6 goto suggestion
echo Simple mode selected!
set complexity=s
echo\
:continuefour
:customization
:customizationoption
echo Your options for quality are decent [1], bad [2], terrible [3], unbearable [4], custom [C], or random [R].
choice /n /c 1234CR
set customizationquestion=%errorlevel%
if %customizationquestion% == 5 set customizationquestion=c
if %customizationquestion% == 6 set customizationquestion=r&goto random
:skipped
if 1%2 == 1 goto skipcustommultiqueue
set customizationquestion=%2
if not %2 == c goto skipcustommultiqueue
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
:skipcustommultiqueue
if %customizationquestion% == 6 set customizationquestion=r&goto random
:: defines a few variables that will be replaced later, this is important for checking if they're valid later as it prevents missing operand errors
set framerate=a
set videobr=a
set audiobr=a
set scaleq=a
set details=n
:: Sets the quality based on customizationquestion
:: endingmsg is added to the end of the video for the output name (if you don't understand, just run the script and look at the name of the output)
if "%customizationquestion%" == "c" echo\&echo Custom %qs%
:customquestioncheckpoint
if %customizationquestion% == 6 set customizationquestion=r&goto random
if %customizationquestion% == r goto random
if "%customizationquestion%" == "c" (
	 echo\
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
if NOT %testforfps% == %framerate% goto errorcustom
if NOT %testforvideobr% == %videobr% goto errorcustom
if NOT %testforaudiobr% == %audiobr% goto errorcustom
if NOT %testforscaleq% == %scaleq% goto errorcustom
:: grabs info from video to be used later
:setendingmsg
ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -i %inputvideo% -of csv=p=0 > %temp%\fps.txt
set /p fpsvalue=<%temp%\fps.txt
set /a fpsvalue=%fpsvalue%
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %temp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %temp%\height.txt
set /p height=<%temp%\height.txt
set /p width=<%temp%\width.txt
:: makes the endingmsg contain more details if it's been selected (only available in the custom preset)
if /I %details% == y set endingmsg=Custom Quality - %framerate% fps^, %videobr% video bitrate input^, %audiobr% audio bitrate input^, %scaleq% scale
if not %complexity% == s goto advancedone
:continueone
:: Sets the audio and video bitrate based on audiobr and videobr, adjusting based on framerate and resolution
set /A badaudiobitrate=80/%audiobr%
if NOT %complexity% == s goto advancedtwo
:continuetwo
set yeahlowqual=n
:filters
:: user picks yes or no resampling/tmix
goto resamplequestion
:afterresample
echo\
:: finds if the height of the video divided by scaleq is an even number, if not it changes it to an even number
set /A desiredheight=%height%/%scaleq%
set /A desiredheighteventest=(%desiredheight%/2)*2
if %desiredheighteventest% == NOT %desiredheight% (
     set /A desiredheight=%desiredheighteventest%
)
set /A desiredwidth=%width%/%scaleq%
set /A desiredwidtheventest=(%desiredwidth%/2)*2
if %complexity% == s set stretchres=n
if %stretchres% == y (
     set desiredwidtheventest=%desiredwidtheventest%*2								   
)
:: asks if the user wants to interpolate if framerate input is less than output
set interpq=n
if NOT %complexity% == s (
     if %framerate% gtr %fpsvalue% (
		 choice /c YN /m "The framerate of your input exceeds the framerate of the output. Interpolate to fix this?"
		 if %errorlevel% == 1 set interpq=y
	     echo\
     )
)
:: bitrate formula
set /A badvideobitrate=(%desiredheight%/2*%desiredwidtheventest%*%framerate%/%videobr%)
if %badvideobitrate% LSS 1000 set badvideobitrate=1000
:: defines filters
set "fpsfilter=fps=%framerate%,"
if %interpq% == y set "fpsfilter=minterpolate=fps=%framerate%,"
if %resample% == y set "fpsfilter=tmix=frames=%tmixframes%:weights=1,fps=%framerate%,"
set filters=-vf %textfilter%%fpsfilter%%speedfilter%scale=-2:%desiredheight%:flags=neighbor,format=yuv420p%videofilters%"
if %stretchres% == y (
     set filters=-vf %textfilter%%fpsfilter%%speedfilter%scale=%desiredwidtheventest%:%desiredheight%:flags=neighbor,setsar=1:1,format=yuv420p%videofilters%"
)
if %colorq% == y (
     set filters=-vf %textfilter%%fpsfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,scale=-2:%desiredheight%:flags=neighbor,format=yuv420p%videofilters%"
     if %stretchres% == y (
          set filters=-vf %textfilter%%fpsfilter%%speedfilter%eq=contrast=%contrastvalue%:saturation=%saturationvalue%:brightness=%brightnessvalue%,scale=%desiredwidtheventest%:%desiredheight%:flags=neighbor,setsar=1:1,format=yuv420p%videofilters%"
     )
)
if %complexity% == s set filters=-vf "%fpsfilter%scale=-2:%desiredheight%:flags=neighbor,format=yuv420p%videofilters%"
:: bass boosting
set audiofilters= 
if NOT %complexity% == s goto advancedthree
:encoding
:: metadata
if %meta% == false goto encodingmsg
set meta1=-metadata comment="Made with Quality Muncher v%version% - https://github.com/Thqrn/qualitymuncher"
set meta2=-metadata "Quality Muncher Info"=
set meta3=Complexity %complexity%, option %customizationquestion%
set meta4=Input had a width of %width% and a height of %height%. The final bitrates were %badvideobitrate% for video and %badaudiobitrate%000 for audio. Final scale was %desiredwidtheventest% for width and %desiredheight% for height and resample was set to %resample%.
set meta5=fps %framerate%, video bitrate %videobr%, audio bitrate %audiobr%, scaleq %scaleq%, details %details%
set meta6=start %starttime%, duration %time%, speed %speedq%, color %colorq%, interpolated %interpq%, stretched %stretchres%, distorted audio %bassboosted%, added audio %lowqualmusicquestion%, added text %addedtextq%.
:: I HAVE NO CLUE WHAT META 7 EVEN DOES BUT IF I REMOVE IT, AND THE USER PICKS ADVANCED, THE SCRIPT CRASHES??????? IDK WHY
set meta7=
if not %complexity% == s goto advancedmeta
set metadata=%meta1% %meta2%"%meta3%. %meta4%"
if %customizationquestion% == c set metadata=%meta1% %meta2%"%meta3%, %meta5%. %meta4%"
goto encodingmsg
:advancedmeta
set metadata=%meta1% %meta2%"%meta3%, %meta6% %meta4%"
if %customizationquestion% == c set metadata=%meta1% %meta2%"%meta3%, %meta5%, %meta6% %meta4%"
:: encoding msg
:encodingmsg
if %log% == true echo %metadata% > "%~dpn1 (%endingmsg%) log.txt"
echo [38;2;254;165;0mEncoding...[0m & echo\
:: determining which encoding option to use
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
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +use_metadata_tags+faststart "%~dpn1 (%endingmsg%)%container%"
goto end
:: option two, there is music
:optiontwo
ffmpeg -hide_banner -loglevel warning -stats ^
-ss %starttime% -t %time% -i %1 -ss %musicstarttime% -i %lowqualmusic% ^
%filters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +use_metadata_tags+faststart "%~dpn1 (%endingmsg%)%container%"
goto end
:optionthree
ffmpeg -hide_banner -loglevel error -stats ^
-i %1 ^
%filters% ^
-c:v libx264 %metadata% -preset %encodingspeed% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%~dpn1 (%endingmsg%)%container%"
:end
if exist "%temp%\height.txt" (del "%temp%\height.txt")
if exist "%temp%\width.txt" (del "%temp%\width.txt")
if exist "%temp%\fps.txt" (del "%temp%\fps.txt")
if exist "%temp%\toptext.txt" (del "%temp%\toptext.txt")
if exist "%temp%\bottomtext.txt" (del "%temp%\bottomtext.txt")
if exist "%temp%\badvideobitrate.txt" (del "%temp%\badvideobitrate.txt")
if exist "%temp%\vstream.txt" (del "%temp%\vstream.txt")
echo\ & echo [92mDone![0m & echo\
set done=true
if %stayopen% == false goto ending
if 1%2 == 1 goto :exiting
if not check%2 == check goto ending



:: speed settings
:advancedone
set speedvalid=n&set speedq=default
echo\
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
if %speedq% == default (
     echo\
     echo [91mNo valid input given, speed has been set to default.[0m
     set speedvalid=y
     set speedq=1
     goto cont
)
set speedfilter="setpts=(1/%speedq%)*PTS,"
set speedfilter=%speedfilter:"=%
if %hasvideo% == false goto nextaudiostep1
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
for %%? in (%temp%\toptext.txt) do ( set /A strlength=%%~z? - 2 )
if %strlength% LSS 16 set strlength=16
set /a fontsize=(%width%/%strlength%)*2
:: bottom text
set "bottomtext= "
set /p bottomtext=Bottom text: 
set bottomtextnospace=%bottomtext: =_%
echo "%bottomtextnospace%" > %temp%\bottomtext.txt
for %%? in (%temp%\bottomtext.txt) do ( set /A strlengthb=%%~z? - 2 )
if %strlengthb% LSS 16 set strlengthb=16
set /a fontsizebottom=(%width%/%strlengthb%)*2
:: setting text filter
set "textfilter=1drawtext=borderw=(%fontsize%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%toptext%':fontcolor=white:fontsize=%fontsize%:x=(w-text_w)/2:y=(0.25*text_h),drawtext=borderw=(%fontsizebottom%/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='%bottomtext%':fontcolor=white:fontsize=%fontsizebottom%:x=(w-text_w)/2:y=(h-1.25*text_h),"
set textfilter=%textfilter:1drawtext="drawtext%
goto continueone


:advancedtwo
echo\
:: allows the user to have the choice of modifying saturation and contrast.
set contrastvalue=1 & set saturationvalue=1 & set brightnessvalue=0
choice /c YN /m "Do you want to customize saturation, contrast, and brightness?"
if %errorlevel% == 1 set colorq=y
set contrastvaluefalse=n & set saturationvaluefalse=n & set brightnessvaluefalse=n
if %colorq% == y (
     set /p contrastvalue=Select a contrast value [93mbetween -1000.0 and 1000.0[0m, default is 1: 
     set /p saturationvalue=Select a saturation value [93mbetween 0.0 and 3.0[0m, default is 1: 
     set /p brightnessvalue=Select a brightness value [93mbetween -1.0 and 1.0[0m, default is 0: 
)
:: the next lines test if the values defined above are invalid, don't ask why we use a different method every time
if %colorq% == y (
     set "errormsgcol=value was invalid, it has been set to the default."
     if not "%contrastvalue%"=="%contrastvalue: =%" set contrastvaluefalse=y
     if not "%saturationvalue%"=="%saturationvalue: =%" set saturationvaluefalse=y
     if not "%brightnessvalue%"=="%brightnessvalue: =%" set brightnessvaluefalse=y
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
     echo\ & echo [91mContrast %errormsgcol%[0m & set contrastvalue=1
)
if %saturationvaluefalse% == y (
     echo\ & echo [91mSaturation %errormsgcol%[0m & set saturationvalue=1
)
if %brightnessvaluefalse% == y (
     echo\ & echo [91mBrightness %errormsgcol%[0m & set brightnessvalue=0
)
:stretch
echo\
:: asks about stretching the video
choice /c YN /m "Do you want to stretch the video horizontally?"
if %errorlevel% == 1 set stretchres=y
:: defines things for music and asks if they want music
:lowqualmusicq
set musicstarttime=0 & set musicstartest=0 & set lowqualmusicquestion=n & set filefound=y
echo\
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
:: if its not a valid file it sends the user back to add a valid file
if %filefound% == n (
     echo\ & echo [91mInvalid file! Please drag an existing file from your computer![0m & echo\
     goto addingthemusic
)
:musicstartq
:: asks the user when the music should start
if %lowqualmusicquestion% == y (
     set /p musicstarttime=Enter a specific start time of the music [93min seconds[0m: 
     goto filters
)
goto continuetwo

:resamplequestion
if %alwaysaskresample% == true goto bypassnoresample
if "%complexity%" == "s" goto afterresample
if not %fpsvalue% gtr %framerate% goto afterresample
:bypassnoresample
echo\
choice /c YN /m "Do you want to resample frames? This will look like motion blur, but will take longer to render."
if %errorlevel% == 1 set resample=y
echo %resample%
if %resample% == n goto afterresample
set /A tmixframes=%fpsvalue%/%framerate%
goto afterresample

:advancedthree
choice /c YN /m "Do you want to distort the audio (earrape)?"
if %errorlevel% == 1 set bassboosted=y&goto skipno
if %bassboosted% == n (
     set audiofilters= 
	 if NOT %speedq% == 1 set audiofilters=-af "atempo=%speedq%"
	 echo\
	 if %hasvideo% == false goto nextaudiostep2
	 goto encoding
)
:skipno
choice /n /c 12 /m "Which distortion method should be used, old [1] or new [2]?"
if %errorlevel% == 1 goto classic
if %errorlevel% == 2 goto newmethod
:: batch will shit itself and die if there isnt a line here
:: new method
:newmethod
set /p distortionseverity=How distorted should the audio be, [93m1-10[0m: 
set /a distsev=%distortionseverity%*10
set /a bb1=0
set /a bb2=(%distsev%*25)
set /a bb3=2*(%distsev%*25)
set audiofilters=-af "firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%|%bb2%|%bb3%,channelmap=1|0,aecho=0.8:0.3:%distsev%*2:0.9"
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %speedq% == 1 (
     set audiofilters=-af "atempo=%speedq%"
     if %bassboosted% == y set audiofilters=-af "atempo=%speedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%|%bb2%|%bb3%,channelmap=1|0,aecho=0.8:0.3:%distsev%*2:0.9"
)
if %hasvideo% == false goto nextaudiostep2
echo\ & goto encoding

:: old method
:classic
set /p distortionseverity=How distorted should the audio be, [93m1-10[0m: 
set /a distsev=%distortionseverity%*10
set audiofilters=-af "firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
:: checks if speed is not the default and if it isnt it changes the audio speed to match
if NOT %speedq% == 1 (
     set audiofilters=-af "atempo=%speedq%"
     if %bassboosted% == y set audiofilters=-af "atempo=%speedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
)
if %hasvideo% == false goto nextaudiostep2
:: does batch also do it here
goto encoding


:advancedfour
set complexity=a& echo Advanced mode selected! & echo\
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
echo\
if %hasvideo% == false goto backtoaudio
goto continuefour

:discord
echo [96mSending to Discord![0m & start "" https://discord.com/invite/9tRZ6C7tYz & cls & goto verystart

:website
echo [96mSending to website![0m & start "" https://qualitymuncher.lgbt/ & cls & goto verystart

:: suggestions
:suggestion
ping /n 1 discord.com  | find "Reply" > nul
if %errorlevel% == 1 echo [91mSorry, either discord is down or you're not connected to the internet. Try again later.[0m&echo\&pause&cls&goto verystart
set /p "mainsuggestion=What's your suggestion? "
set /p "suggestionbody=If needed, please elaborate further here: "
set /p "author=What is your name on discord? [93mThis is optional[0m: "
echo\
echo %author%'s suggestion:
echo %mainsuggestion%
echo %suggestionbody%
echo\
choice /m "Are you sure you would like to submit this suggestion?"
if %errorlevel% == 1 goto continuesuggest
if %errorlevel% == 2 echo [91mOkay, your suggestion has been cancelled.[0m&echo\&pause&cls&goto verystart
:continuesuggest
:: please do not spam this webhook it would make me very sad
curl -s -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New suggestion!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/webhooks/973701372128157776/A-TFFPzP-hfWR-W2TuOllG_GUEX4SXN7RRqu-xLdSJgcgoQF6_x-GkwrMxDahw5g_aFE
echo [92mYour suggestion has been successfully sent to the developers![0m &echo\&pause&cls&goto verystart

:noinput
echo [91mERROR: no input file![0m & echo Drag this .bat into the SendTo folder - press [90;7mWindows + R[0m and type in [90;7mshell:sendto[0m & echo After that, right click on your video, drag over to Send To and click on [90;7mQuality Muncher.bat[0m. & echo\
echo Press [W] to open the website, [D] to join the discord server, [P] to make a suggestion, or [C] to close.
echo You can also press [F] to input a file manually.
choice /n /c WDCFP
echo\ & set confirmselec=y
if %errorlevel% == 1 goto website
if %errorlevel% == 2 goto discord
if %errorlevel% == 4 goto manualfile
if %errorlevel% == 5 goto suggestion
goto closingbar

:exiting
where /q ffplay || goto aftersound
if %done% == true ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound
pause & goto closingbar

:manualfile
set me=%~f0
set /p file=Please drag your input here: 
cls & call "%me%" %file%
exit

:updatecheck
set "download=https://github.com/Thqrn/qualitymuncher/blob/main/Quality%%20Muncher.bat"\
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 goto nointernet
set internet=true
curl -s "https://raw.githubusercontent.com/Thqrn/qualitymuncher/main/version.txt" --output %temp%\QMnewversion.txt
set /p newversion=<%temp%\QMnewversion.txt
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
if "%version%" == "%newversion%" (set isupdate=false) else (set isupdate=true)
if not %isupdate% == true goto verystart
echo [96mThere is a new version (%newversion%) of Quality Muncher available! & echo Press [U] to update or [S] to skip. & echo [90mTo hide this message in the future, set the variable "autoupdatecheck" in the script options to false.[0m
choice /c US /n
echo\ & set isupdate=false
if %errorlevel% == 2 cls && goto verystart
echo Automatic updating will only work properly if Quality Muncher is in send-to. Proceed?
choice
if %errorlevel% == 2 goto closingbar
echo\ & echo [7mWhen prompted, make sure you press [O] and then press enter.[0m & echo\
powershell -noprofile "iex(iwr -useb install.qualitymuncher.lgbt)" & cls & "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\SendTo\Quality Muncher.bat" %1

:nointernet
cls
set internet=false & echo [91mUpdate check failed, skipping.[0m & echo\
goto verystart

:random
set details=n
set min=1
set max=15
echo\
echo [91mR[0m[93ma[0m[92mn[0m[96md[0m[94mo[0m[95mm[0m %qs%
set /a framerate=%random% %% 30
set /a videobr=%random% * %max% / 32768 + %min%
set /a scaleq=%random% * %max% / 32768 + %min%
set /a audiobr=%random% * %max% / 32768 + %min%
set endingmsg=Random Quality
goto setendingmsg

:loadingbar
mode con: cols=%cols% lines=%lines%
set /a cols=%cols%+5
if not %cols% gtr 124 goto loadingbar
:loadingy
mode con: cols=%cols% lines=%lines%
set /a lines=%lines%+1
if not %lines% gtr 35 goto loadingy
powershell -noprofile -command "&{(get-host).ui.rawui.buffersize=@{width=%cols%;height=9901};}"
goto init

:closingbar
if %animate% == false exit
:closingloop
mode con: cols=%cols% lines=%lines%
set /a cols=%cols%-5
set /a lines=%lines%-1
if not %cols% == 14 goto closingloop
exit

:novideostream
set audioencoder=aac
if %audiocontainer% == .mp3 set audioencoder=libmp3lame
set hasvideo=false
echo [91mInput has no video, skipping video related questions...[0m
echo\
set /p audiobr=[93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad: 
set /A badaudiobitrate=80/%audiobr%
goto startquestion
:backtoaudio
choice /m "Adjust audio speed? "
set speedq=1
if %errorlevel% == 1 goto advancedone
:nextaudiostep1
echo\
goto advancedthree
:nextaudiostep2
echo\ & echo [38;2;254;165;0mEncoding...[0m & echo\
ffmpeg -hide_banner -loglevel error -stats ^
-ss %starttime% -t %time% -i %1 ^
-vn %metadata% -preset %encodingspeed% ^
-c:a %audioencoder% -b:a %badaudiobitrate%000 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +use_metadata_tags+faststart "%~dpn1 (Quality Munched)%audiocontainer%"
goto end


:ending
if %animate% == true goto closingbar