:: this script is *very* loosely based on vladaad's old discord compressor, all parts of which will be mentioned when the code comes up
:: a very small amount of this code is also inspired by or directly taken from small portions of Couleur's CTT Upscaler 2.0
:: if it isn't mentioned in a comment above the code, i wrote it, but if i made a mistake please message me at Frost#5872
:: this makes it so not every line of code is sent
@echo off
:: sets the title of the windoww and sends some ascii word art
title Frost's Quality Muncher 1.2.5
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
:: hardware acceleration, from vladaad, this helps make rendering faster
set hwaccel=auto
:: Input check (from vladaad) this checks if someone used the script correctly
color 0f
if %1check == check (
     echo ERROR: no input file
     echo Drag this .bat into the SendTo folder - press Windows + R and type in shell:sendto
     echo After that, right click on your video, drag over to Send To and click on this bat there.
     pause
     exit
)
:: intro, questions and defining variables
echo This version (1.2.5) of Frost#5872's quality muncher is still in development.
echo Feel free to DM me for support or questions.
set /p starttime=Where do you want your clip to start (in seconds): 
set /p time=How long after the start time do you want it to be: 
echo Pick a preset:
echo Decent (1)
echo Bad (2)
echo Terrible (3)
echo Unbearable (4)
echo Custom (c)
set /p customizationquestion=Enter an option from the above list: 
:: sets the options to decent preset, will be overridden if they have selected a valid preset (its a lazy way of doing it but it works, ill clean it up later)
set framerate=12
set videobr=5
set scaleq=4
set audiobr=5
set endingmsg=Decent Quality
set details=n
set validanswer=n
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
     set /p framerate=What fps do you want it to be rendered at: 
     set /p videobr=On a scale from 1 to 10, how bad should the VIDEO bitrate be? 1 bad, 10 very very bad: 
     set /p audiobr=On a scale from 1 to 10, how bad should the AUDIO bitrate be? 1 bad, 10 very very bad: 
     set /p scaleq=On a scale from 1 to 10, how much should the video be shrunk by? 1 none, 10 a lot: 
	 set /p details=Do you want a detailed file name for the output? y or n: 
	 set endingmsg=Custom Quality
	 set validanswer=y
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
	 echo You didn't enter a valid answer! The preset has been set to "decent".
)
:: makes the endingmsg contain more details if it's been selected (only available in the custom preset)
if %details% == y (
     set endingmsg=Custom Quality - %framerate% fps^, %videobr% video bitrate input^, %audiobr% audio bitrate input^, %scaleq% scale
)
:: hwaccel (from vladaad)
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
:: Finds if the height of the video divided by scaleq is an even number, if not it changes it to an even number
set /A desiredheight=%height%/%scaleq%
set /A desiredheighteventest=(%desiredheight%/2)*2
if %desiredheighteventest% == NOT %desiredheight% (
     set /A desiredheight=%desiredheighteventest%
)
:: based off of vladaad's part and i replaced a lot of it with my stuff
set filters=-vf "fps=%framerate%,scale=-2:h=%desiredheight%,format=yuv420p%videofilters%"
:: Running (from vladaad) this just tells the user it started encoding
echo\
echo Encoding...
echo\
color 06
:: FFmpeg (from vladaad) runs the video, starts encoding, does all of this and i added 2 things
ffmpeg -loglevel warning -stats %hwaccel% ^
-ss %starttime% -t %time% -i %1 ^
%filters% ^
-c:v libx264 -preset ultrafast -b:v %badvideobitrate%000 ^
-c:a aac -b:a %badaudiobitrate%000 ^
-vsync vfr -movflags +faststart "%~dpn1 (%endingmsg%).mp4"
:: End (from vladaad) just ends the script
echo\
echo Done!
echo\
color 0A
pause