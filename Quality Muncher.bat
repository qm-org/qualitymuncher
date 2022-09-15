:: This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
:: This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
:: You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

:: made by Frost#5872
:: https://github.com/qm-org/qualitymuncher

:: ik this shitty code is really fucked up rn with the comments and stuff all over the place
:: so if you need help figuring out what anything does shoot me a message or ask in the server
:: and i'll explain whatever you need me to

:: TODO - frost
:: - information/credits/disclaimers etc page in the menu or maybe extras
:: - more comments on code (maybe needed? idk how complex this seems to someone who didn't write it)
:: - sort the functions better (very disorganized)
:: - ???

:main
@echo off
echo Log has been started>"%temp%\qualitymuncherdebuglog.txt"
setlocal enabledelayedexpansion
set me=%0

:: OPTIONS - THESE RESET AFTER UPDATING SO KEEP A COPY SOMEWHERE (unless you use the defaults)
    :: automatic update checks, highly recommended to keep this enabled
    set autoupdatecheck=y
    :: directory for logs, if none set the input's directory is used ***add quotes if there is a space***
    set loggingdir=
    :: stay open after the file is done rendering
    set stayopen=y
    :: shows title
    set showtitle=y
    :: shows messages beneath titles
    set displaymessages=y
    :: cool animations (slows startup speed by a few seconds)
    set animate=n
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

:: ################################################################################################################################
:: #####################    WARNING: modifying any lines past here might result in the program breaking^^!    #####################
:: ################################################################################################################################

:: code page, version, and title
chcp 437 > nul
set version=1.5.1
echo Quality Muncher v%version% successfully started on %date% at %time%>>"%temp%\qualitymuncherdebuglog.txt"
echo ---------------INPUTS---------------->>"%temp%\qualitymuncherdebuglog.txt"
echo %*>>"%temp%\qualitymuncherdebuglog.txt"
echo ------------------------------------->>"%temp%\qualitymuncherdebuglog.txt"
set ismultiqueue=n
if not check%2 == check (
    set ismultiqueue=y
    echo More than one parameter is being used to run the file>>"%temp%\qualitymuncherdebuglog.txt"
)
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
echo Default variables set>>"%temp%\qualitymuncherdebuglog.txt"
:: plays an animation is the first parameter is qmloo
if %animate% == y call :loadingbar
call :titledisplay
:: checks for updates
if %autoupdatecheck% == y call :updatecheck
:: afterstartup is everything that happens after the main "startup" - setting constants, defaults, options, doing animations, checking updates, etc
:afterstartup
:: checks if ffmpeg is installed, and if it isn't, it'll send a tutorial to install it. 
where /q ffmpeg.exe || (
    echo FFmpeg not found, sending error, pausing, then exiting>>"%temp%\qualitymuncherdebuglog.txt"
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
:: checks if the input has a video stream (i.e. if the input is an audio file)
:: and if there isn't a video stream, ask audio questions instead
call :imagecheck %1
if %1check == check (
    echo File was ran without parameters ^(no input^)>>"%temp%\qualitymuncherdebuglog.txt"
    goto guimenurefresh
)
if not exist "%~1" (
    goto guimenurefresh
    echo File parameter does not exist>>"%temp%\qualitymuncherdebuglog.txt"
)
set inputvideo=%1
ffprobe -i %inputvideo% -show_streams -select_streams a -loglevel error > %temp%\astream.txt
set /p astream=<%temp%\astream.txt
if exist "%temp%\astream.txt" (del "%temp%\astream.txt")
if 1%astream% == 1 (
    echo Input does not have an audio stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasaudio=n
) else (
    echo Input has an audio stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasaudio=y
)
ffprobe -i %inputvideo% -show_streams -select_streams v -loglevel error > %temp%\vstream.txt
set /p vstream=<%temp%\vstream.txt
if exist "%temp%\vstream.txt" (del "%temp%\vstream.txt")
if 1%vstream% == 1 (
    echo Input does not have a video stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasvideo=n
    if %hasaudio% == y (
        goto novideostream
    ) else (
        echo Video has neither audio nor video streams, assumed to be an invalid input and going to noinput in the TUI>>"%temp%\qualitymuncherdebuglog.txt"
        set noinput=y
        goto guimenurefresh
    )
) else (
    echo Input has a video stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasvideo=y
)
:: if the video is an image, ask specific image questions instead
goto guimenurefresh

:titledisplay
cls
if %showtitle% == n (
    goto :eof
) else (
    echo [s
)
cls
echo                  [38;2;39;55;210m____                 _  _  _              __  __                      _
echo                 [38;2;0;87;228m/ __ \               ^| ^|(_)^| ^|            ^|  \/  ^|                    ^| ^|
echo                [38;2;0;111;235m^| ^|  ^| ^| _   _   __ _ ^| ^| _ ^| ^|_  _   _    ^| \  / ^| _   _  _ __    ___ ^| ^|__    ___  _ __
echo                [38;2;0;130;235m^| ^|  ^| ^|^| ^| ^| ^| / _` ^|^| ^|^| ^|^| __^|^| ^| ^| ^|   ^| ^|\/^| ^|^| ^| ^| ^|^| '_ \  / __^|^| '_ \  / _ \^| '__^|
echo                [38;2;0;148;230m^| ^|__^| ^|^| ^|_^| ^|^| {_^| ^|^| ^|^| ^|^| ^|_ ^| ^|_^| ^|   ^| ^|  ^| ^|^| ^|_^| ^|^| ^| ^| ^|^| {__ ^| ^| ^| ^|^|  __/^| ^|
echo                 [38;2;0;163;221m\___\_\ \__,_^| \__,_^|^|_^|^|_^| \__^| \__, ^|   ^|_^|  ^|_^| \__,_^|^|_^| ^|_^| \___^|^|_^| ^|_^| \___^|^|_^|
echo                                                   [38;2;0;178;211m__/ ^|
echo                                                  [38;2;49;191;204m^|___/[0m
call :messagedisplay
echo.[s
goto :eof

:guimenu
set guimenutitleisshowing=y
:guimenurefresh
if %hasvideo% == y (
    set videogui=[V]ideo
    if %isimage% == y set videogui=[I]mage
) else (
    set videogui=[38;2;100;100;100m[V]ideo[0m
    if %isimage% == y set videogui=[38;2;100;100;100m[I]mage[0m
)
if %hasaudio% == y (
    set audiogui=[A]udio
) else (
    set audiogui=[38;2;100;100;100m[A]udio[0m
)
if %guimenutitleisshowing% == y (
    call :titledisplay
) else (
    call :clearlastprompt
)
set guimenutitleisshowing=n
echo                                                         [31m[C]lose[0m
echo.
echo                                     %videogui%                                  %audiogui%
echo.
echo                                                         [E]xtra
echo.
echo                                  [L]oad Config                            [S]ave Config
echo.
if %hasvideo% == y (
    if %isimage% == y (
        echo Main GUI choices: VALSCEIR>>"%temp%\qualitymuncherdebuglog.txt"
        echo                                                         [92m[R]ender[0m
        echo.
        choice /c VALSCEIR /n
    ) else (
        if not %videobr% == a (
            echo Main GUI choices: VALSCEIR>>"%temp%\qualitymuncherdebuglog.txt"
            echo                                                         [92m[R]ender[0m
            echo.
            choice /c VALSCEIR /n
        ) else (
            echo Main GUI choices: VALSCEI>>"%temp%\qualitymuncherdebuglog.txt"
            echo                                                         [38;2;100;100;100m[R]ender[0m
            echo                                      You must set the quality before you can render.
            choice /c VALSCEI /n
        )
    )
) else (
    if %hasaudio% == y (
        if not %audiobr% == a (
            echo Main GUI choices: VALSCEIR>>"%temp%\qualitymuncherdebuglog.txt"
            echo                                                         [92m[R]ender[0m
            echo.
            choice /c VALSCEIR /n
        ) else (
            echo Main GUI choices: VALSCEI>>"%temp%\qualitymuncherdebuglog.txt"
            echo                                                         [38;2;100;100;100m[R]ender[0m
            echo                                      You must set the quality before you can render.
            choice /c VALSCEI /n
        )
    ) else (
        echo Main GUI choices: VALSCEI>>"%temp%\qualitymuncherdebuglog.txt"
        echo                                                         [38;2;100;100;100m[R]ender[0m
        echo                                            You must have an input to render.
        choice /c VALSCEI /n
    )
)
echo Main GUI option is %errorlevel%  >>"%temp%\qualitymuncherdebuglog.txt"
if %errorlevel% == 1 (
    if %hasvideo% == y (
        if %isimage% == y (
            echo 
        ) else (
            goto guivideooptions
        )
    ) else (
        echo 
    )
)
if %errorlevel% == 2 (
    if %hasaudio% == y (
        goto guiaudiooptions
    ) else (
        echo 
    )
)
if %errorlevel% == 3 (
    call :clearlastprompt
    call :customconfig
    goto guimenurefresh
)
if %errorlevel% == 4 (
    call :savetoconfig
    goto guimenurefresh
)
if %errorlevel% == 5 (
    echo                                              [31mAre you sure you want to exit?[0m
    choice /n
    if !errorlevel! == 1 (
        exit /b
    ) else (
        goto guimenurefresh
    )
)
if %errorlevel% == 6 (
    goto guiextra
)
if %errorlevel% == 7 (
    if %isimage% == y (
        goto guiimageoptions
    ) else (
        echo 
    )
)
if %errorlevel% == 8 (
    goto render
)
goto guimenurefresh

:autosaveconfig
call :savetoconfigbypassname temp
goto :eof

:customconfig
echo Please enter either:
echo  - the path of your config file
echo  - [38;2;254;165;0mB[0m to go back
echo  - or [38;2;254;165;0mR[0m to use your last used settings
set /p "configfile="
if %configfile% == b goto :eof
if %configfile% == B goto :eof
if %configfile% == R (
    if not exist "%temp%\qualitymuncherconfig_autosave.bat" (
        echo [91mMost recent settings were unable to be found.[0m
        pause
        goto :eof
    )
    call "%temp%\qualitymuncherconfig_autosave.bat"
    goto :eof
)
if %configfile% == r (
    if not exist "%temp%\qualitymuncherconfig_autosave.bat" (
        echo [91mMost recent settings were unable to be found.[0m
        pause
        goto :eof
    )
    call "%temp%\qualitymuncherconfig_autosave.bat"
    goto :eof
)
if not exist %configfile% (
    call :clearlastprompt
    echo [91mFile not found.[0m
    goto :customconfig
)
call %configfile%
goto :eof

:titledisplayvideo
cls
if %showtitle% == n (
    goto :eof
) else (
    echo [s
)
cls
echo                      [38;2;39;55;210m__      __ _      _                   ____          _    _
echo                      [38;2;0;87;228m\ \    / /(_)    ^| ^|                 / __ \        ^| ^|  (_)
echo                       [38;2;0;111;235m\ \  / /  _   __^| ^|  ___   ___     ^| ^|  ^| ^| _ __  ^| ^|_  _   ___   _ __   ___
echo                        [38;2;0;130;235m\ \/ /  ^| ^| / _` ^| / _ \ / _ \    ^| ^|  ^| ^|^| '_ \ ^| __^|^| ^| / _ \ ^| '_ \ / __^|
echo                         [38;2;0;148;230m\  /   ^| ^|^| (_^| ^|^|  __/^| (_) ^|   ^| ^|__^| ^|^| ^|_) ^|^| ^|_ ^| ^|^| (_) ^|^| ^| ^| ^|\__ \
echo                          [38;2;0;163;221m\/    ^|_^| \__,_^| \___^| \___/     \____/ ^| .__/  \__^|^|_^| \___/ ^|_^| ^|_^|^|___/
echo                                                                  [38;2;0;178;211m^| ^|
echo                                                                  [38;2;49;191;204m^|_^|[0m
call :messagedisplay
echo.[s
goto :eof

:guivideooptions
set guivideotitleisshowing=y
:guivideooptionsrefresh
call :autosaveconfig
call :checktogglesvideo
if %guivideotitleisshowing% == y (
    call :titledisplayvideo
) else (
    call :clearlastprompt
)
set guivideotitleisshowing=n
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
echo                %gui_video_quality%                    %gui_video_starttimeandduration%                       %gui_video_speed%
echo.
echo                 %gui_video_text%                                %gui_video_color%                              %gui_video_stretch%
echo.
echo              %gui_video_corruption%                        %gui_video_durationspoof%                        %gui_video_bouncywebm%
echo.
echo       %gui_video_resamplinginterpolation%                     %gui_video_frying%                           %gui_video_framestutter%
echo.
echo             %gui_video_outputasgif%                  %gui_video_miscillaneousfilters%                      %gui_video_novideo%
echo.
echo.
echo.
choice /c 123456789RFSGMBN /n
call :clearlastprompt
echo Video GUI option is %errorlevel% >>"%temp%\qualitymuncherdebuglog.txt"
set /a gui_video_var=%errorlevel%
:: quality
if %gui_video_var% == 1 call :qualityselect
:: start time and duration
if %gui_video_var% == 2 call :durationquestions
:: speed
if %gui_video_var% == 3 call :speedquestions
:: text
if %gui_video_var% == 4 call :addtext
:: color
if %gui_video_var% == 5 call :colorquestions
:: stretch
if %gui_video_var% == 6 call :stretch
:: corruption
if %gui_video_var% == 7 call :corruption
:: duration spoof
if %gui_video_var% == 8 call :durationspoof
:: bouncy webm
if %gui_video_var% == 9 call :webmstretch
:: resampling/interpolation
if %gui_video_var% == 10 if %resample% == y (
    set resample=n
) else (
    set resample=y
)
:: frying
if %gui_video_var% == 11 call :videofrying
:: frame stutter
if %gui_video_var% == 12 call :stutter
:: output as gif
if %gui_video_var% == 13 if %outputasgif% == y (
    set outputasgif=n
) else (
    set outputasgif=y
)
:: miscillaneous filters
if %gui_video_var% == 14 call :filterlist
:: back
if %gui_video_var% == 15 goto guimenu
:: no video
if %gui_video_var% == 16 if %novideo% == y (
    set novideo=n
) else (
    set novideo=y
)
goto guivideooptionsrefresh

:titledisplayaudio
cls
if %showtitle% == n (
    goto :eof
) else (
    echo [s
)
cls
echo                                           [38;2;39;55;210m_  _             ____          _    _
echo                          [38;2;0;87;228m/\              ^| ^|(_)           / __ \        ^| ^|  (_)
echo                         [38;2;0;111;235m/  \   _   _   __^| ^| _   ___     ^| ^|  ^| ^| _ __  ^| ^|_  _   ___   _ __   ___
echo                        [38;2;0;130;235m/ /\ \ ^| ^| ^| ^| / _` ^|^| ^| / _ \    ^| ^|  ^| ^|^| '_ \ ^| __^|^| ^| / _ \ ^| '_ \ / __^|
echo                       [38;2;0;148;230m/ ____ \^| ^|_^| ^|^| (_^| ^|^| ^|^| (_) ^|   ^| ^|__^| ^|^| ^|_) ^|^| ^|_ ^| ^|^| (_) ^|^| ^| ^| ^|\__ \
echo                      [38;2;0;163;221m/_/    \_\\__,_^| \__,_^|^|_^| \___/     \____/ ^| .__/  \__^|^|_^| \___/ ^|_^| ^|_^|^|___/
echo                                                                  [38;2;0;178;211m^| ^|
echo                                                                  [38;2;49;191;204m^|_^|[0m
call :messagedisplay
echo.[s
goto :eof

:guiaudiooptions
set guiaudiotitleisshowing=y
:guiaudiooptionsrefresh
call :autosaveconfig
call :checktogglesaudio
if %guiaudiotitleisshowing% == y (
    call :titledisplayaudio
) else (
    call :clearlastprompt
)
set guiaudiotitleisshowing=n
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
echo                %gui_audio_quality%                     %gui_audio_starttimeandduration%                      %gui_audio_speed%
echo.
echo               %gui_audio_distortion%                       %gui_audio_texttospeech%                         %gui_audio_replacing%
echo.
echo                                                       %gui_audio_noaudio%
echo.
echo.
echo.
choice /c 123456BN /n
call :clearlastprompt
echo Audio GUI option is %errorlevel% >>"%temp%\qualitymuncherdebuglog.txt"
set /a gui_audio_var=%errorlevel%
:: quality
if %gui_audio_var% == 1 call :audioqualityselect
:: start time and duration
if %gui_audio_var% == 2 call :durationquestions
:: speed
if %gui_audio_var% == 3 (
    set hasvideoog=%hasvideo%
    set hasvideo=n
    call :speedquestions
    set hasvideo=!hasvideoog!
)
:: distortion
if %gui_audio_var% == 4 call :audiodistortion
:: text to speech
if %gui_audio_var% == 5 call :voicesynth
:: replacing
if %gui_audio_var% == 6 call :replaceaudioquestion
:: back
if %gui_audio_var% == 7 goto guimenu
:: no audio
if %gui_audio_var% == 8 if %noaudio% == y (
    set noaudio=n
) else (
    set noaudio=y
)
goto guiaudiooptionsrefresh

:titledisplayextra
cls
if %showtitle% == n (
    goto :eof
) else (
    echo [s
)
cls
echo                                            [38;2;39;55;210m______        _
echo                                           [38;2;0;87;228m^|  ____^|      ^| ^|
echo                                           [38;2;0;111;235m^| ^|__   __  __^| ^|_  _ __  __ _  ___
echo                                           [38;2;0;130;235m^|  __^|  \ \/ /^| __^|^| '__^|/ _` ^|/ __^|
echo                                           [38;2;0;148;230m^| ^|____  ^>  ^< ^| ^|_ ^| ^|  ^| {_^| ^|\__ \
echo                                           [38;2;0;163;221m^|______^|/_/\_\ \__^|^|_^|   \__,_^|^|___/[0m
call :messagedisplay
echo.[s
goto :eof

:guiextra
set guiextratitleisshowing=y
:guiextrarefresh
call :autosaveconfig
call :checktogglesaudio
if %guiextratitleisshowing% == y (
    call :titledisplayextra
) else (
    call :clearlastprompt
)
set guiextratitleisshowing=n
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
echo                [W]ebsite                            [A]nnouncements                           [R]eport Bug
echo.
echo                [D]iscord                                [U]pdate                              [S]uggestion
echo.
echo.
choice /n /c BWARDUS
echo Extra GUI option is %errorlevel% >>"%temp%\qualitymuncherdebuglog.txt"
set /a gui_extra_var=%errorlevel%
call :clearlastprompt
if %gui_extra_var% == 1 goto guimenu
if %gui_extra_var% == 2 call :website
if %gui_extra_var% == 3 call :announcement
if %gui_extra_var% == 4 call :bugreport
if %gui_extra_var% == 5 call :discord
if %gui_extra_var% == 6 set "forceupdate=y"&call :updatecheck
if %gui_extra_var% == 7 call :suggestionactual
goto guiextrarefresh

:titledisplayimage
cls
if %showtitle% == n (
    goto :eof
) else (
    echo [s
)
cls
echo                      [38;2;39;55;210m_____                                   ____          _    _
echo                     [38;2;0;87;228m^|_   _^|                                 / __ \        ^| ^|  (_)
echo                       [38;2;0;111;235m^| ^|   _ __ ___    __ _   __ _   ___  ^| ^|  ^| ^| _ __  ^| ^|_  _   ___   _ __   ___
echo                       [38;2;0;130;235m^| ^|  ^| '_ ` _ \  / _` ^| / _` ^| / _ \ ^| ^|  ^| ^|^| '_ \ ^| __^|^| ^| / _ \ ^| '_ \ / __^|
echo                      [38;2;0;148;230m_^| ^|_ ^| ^| ^| ^| ^| ^|^| {_^| ^|^| (_^| ^|^|  __/ ^| ^|__^| ^|^| ^|_) ^|^| ^|_ ^| ^|^| (_) ^|^| ^| ^| ^|\__ \
echo                     [38;2;0;163;221m^|_____^|^|_^| ^|_^| ^|_^| \__,_^| \__, ^| \___^|  \____/ ^| .__/  \__^|^|_^| \___/ ^|_^| ^|_^|^|___/
echo                                                [38;2;0;178;211m__/ ^|               ^| ^|
echo                                               [38;2;49;191;204m^|___/                ^|_^|[0m
call :messagedisplay
echo.[s
goto :eof

:guiimageoptions
set guivideotitleisshowing=y
:guiimageoptionsrefresh
call :autosaveconfig
call :checktogglesvideo
if %guiimagetitleisshowing% == y (
    call :titledisplayimage
) else (
    call :clearlastprompt
)
set guiimagetitleisshowing=n
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
echo                [Q]uality                            [T]imes to Compress                          [S]cale
echo.
echo.
choice /n /c BQTS
call :clearlastprompt
echo Extra GUI option is %errorlevel% >>"%temp%\qualitymuncherdebuglog.txt"
:: back
if %errorlevel% == 1 goto guimenu
:: quality
if %errorlevel% == 2 (
    echo                                 [93mOn a scale from 1 to 10[0m, how bad should the quality be?
    echo                                                   ^(Current value: %qv%^)
    set /p "qv="
)
:: times to compress
if %errorlevel% == 3 (
    echo                    How many times do you want to compress the image [93m^(recommended to be at least 10^)[0m?
    echo                                                  ^(Current value: %loopn%^)
    set /p "loopn="
)
:: scale
if %errorlevel% == 4 (
    echo                                 [93mOn a scale from 1 to 10[0m, how much should the image be shrunk by?
    echo                                                   ^(Current value: %imagesc%^)
    set /p "imagesc="
)
goto guiimageoptionsrefresh

:encodevideomultiq
:: encoding all files
set totalfiles=0
for %%x in (%*) do set /a totalfiles+=1
set filesdone=1
for %%a in (%*) do (
    if not %complexity% == s set videoinp=%%a
    title [!filesdone!/%totalfiles%] Quality Muncher v%version%
    set filesdoneold=!filesdone!
    echo Rendering video !filesdone!/%totalfiles%>>"%temp%\qualitymuncherdebuglog.txt"
    set /a filesdone=!filesdone!+1
    call :videospecificstuff %%a
)
title [Done] Quality Muncher v%version%
:end
echo.
echo [92mDone^^![0m
set done=y
:: delete temp files and show ending (unless stayopen is n)
if exist "%temp%\scaledandfriedvideotempfix%container%" (del "%temp%\scaledandfriedvideotempfix%container%")
if %stayopen% == n goto ending
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
:: gets the input framerate, which is used in determining whether to ask about interpolation, frame resampling, or neither
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
if %frying% == y call :fryingmath
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
if %ismultiqueue% == n (
    if not %complexity% == s call :outputquestion
)
:: if the file already exists, append a (1), and if that exists, append a (2) instead, etc
:: this is to avoid duplicate files, conflicts, issues, and whatever else
if exist "%filename%%container%" call :renamefile
:: let the user know encoding is happening
if %ismultiqueue% == y (
    if not %filesdone% == 1 echo.
    echo [38;2;254;165;0m[%filesdoneold%/%totalfiles%] Encoding %1[0m
) else (
    echo [38;2;254;165;0mEncoding...[0m
)
echo.
if %novideo% == y (
    set filters=-vn
    set frying=n
)
set audiofiltersnormal=%audiofilters%
if %noaudio% == y (
    set audiofiltersnormal=-an
)
:: if simple, go to encoding option 3 (avoids any variables that might be missing in simple mode)
if %complexity% == s goto encodesimple
:: if the user selected to fry the video, encode all of the needed parts
if %frying% == y call :encodefried
:: goto the correct encoding option
if %replaceaudio% == n goto encodewithnormalaudio
if %replaceaudio% == y goto encodereplacedaudio
:: option one, audio is not replaced
:encodewithnormalaudio
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% -i %videoinp% ^
%filters% %audiofiltersnormal% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%" && echo FFmpeg call 1 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 1 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
set outputvar="%cd%\%filename%%container%"
goto endofthis
:: option two, audio was replaced
:encodereplacedaudio
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% -i %videoinp% -ss %musicstarttime% -i %lowqualmusic% ^
%filters% %audiofiltersnormal ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 -shortest ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%" && echo FFmpeg call 2 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 2 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
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
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%container%" && echo FFmpeg call 3 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 3 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
set outputvar="%cd%\%filename%%container%"
:endofthis
:: if text to speech, encode the voice and merge outputs
if %hasvideo% == n goto skipvideoencodingoptions
if %tts% == y call :encodevoice
if %spoofduration% == y goto outputdurationspoof
if %bouncy% == y call :encodebouncy
:donewithdurationspoof
if "%corrupt%"=="y" call :corruptoutput
:skipvideoencodingoptions
if %outputasgif% == y (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %outputvar% -f gif -an "%filename%.gif" && echo FFmpeg call 4 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 4 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    del %outputvar%
    set outputvar="%cd%\%filename%.gif"
)
goto :eof

:: advanced parts - most of the following code isn't read when using simple mode

:: audio distortion questions
:audiodistortion
echo                                    Do you want to distort the audio (earrape)? [Y/N]
choice /n
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
echo                       Which distortion method should be used, simple [1] or advanced [2]?
choice /n /c 12
set disrortionseverity=3
if %errorlevel% == 1 (
    set method=classic
    goto classic
) else (
    set method=new
    goto newmethod
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
call :clearlastprompt
goto :eof

:: corruption questions, used to enable/disable video corruption
:corruption
echo                                            Do you want to corrupt the video?
:: since corruption works by randomly destroying or otherwise changing bytes, warn users of unexpected issues
echo     [91mWarning^^! While the output will still be playable, some other options might behave strangely or break completely^^![0m
choice /n
if %errorlevel% == 1 (
    set corrupt=y
) else (
    set corrupt=n
    call :clearlastprompt
    goto :eof
)
echo                             [93mOn a scale from 1 to 10[0m, how much should the video be corrupted?
set /p "corruptsev="
call :clearlastprompt
goto :eof

:: takes the output and corrupts it
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
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel fatal -stats -i %outputvar% -c copy -bsf noise=((%desiredwidth%*%desiredheight%)/2073600*1000000/(%corruptsev%*10)) "%filename%%cuffix%%container%" && echo FFmpeg call 5 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 5 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: delete the old output
if exist %outputvar% (del %outputvar%)
:: set the needed variables for piping and such
set outputvar="%cd%\%filename%%cuffix%%container%"
set "filename=%filename%%cuffix%"
goto :eof

:durationspoof
echo                                      Do you want to spoof the duration of the video?
echo                    [91mWarning^^! This is an EXTREMELY expiramental feature and might not work as intended^^![0m
if %corrupt% == y echo                    [91mThis setting may cause issues when used with corruption (which you have enabled).[0m
choice /n
if %errorlevel% == 1 (
    set spoofduration=y
) else (
    set spooofduration=n
    call :clearlastprompt
    goto :eof
)
echo    Do you want the video to have a super long duration [1], a super long negative duration [2], or an ever-increasing
echo                                                       duration [3]?
choice /n /c 123
if %errorlevel% == 1 set durationtype=superlong
if %errorlevel% == 2 set durationtype=superlongnegative
if %errorlevel% == 3 set durationtype=increasing
call :clearlastprompt
goto :eof

:outputdurationspoof
:: text to speech doesn't have duration in metadata or something so reencode it
if %tts% == y (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %outputvar% -c:v libx264 -preset %encodingspeed% -b:v %badvideobitrate% -c:a copy -shortest ^-vsync vfr -movflags +use_metadata_tags+faststart "%filename%2.mp4" && echo FFmpeg call 6 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 6 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    del %outputvar%
    set outputvar="%cd%\%filename%2.mp4"
)
set nextline=n
:: encode the video to hex
certutil -encodehex %outputvar% "%temp%\%filename% hexed.txt"
set theline=n
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
if %nextline% == y (
    if %durationtype% == superlongnegative (
        set /a "theline=%linenum%+1"
    ) else (
        set /a "theline=%linenum%"
    )
    set /a numofloops+=1
    if %durationtype% == superlong call :thelinesuperlong
    if %durationtype% == superlongnegative call :superlongnegative
    if %durationtype% == increasing call :thelineincreasing
    if %numofloops%1 == 11 set nextline=n
)
:: exit the for loop if the line is found and replaced
if %linenum% gtr %theline% goto endloop
if not %durationtype% == superlongnegative (
    if %nextline% == y (
        goto endloop
    )
)
if not "%linecontent%" == "%linecontent:mvhd=%" set nextline=y
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
echo                                Do you want to make the video into a bouncing WebM? [Y/N]
choice /n
:: warn of incompatabilities
if %spoofduration% == y echo                       [91mThis setting does not work with duration spoofing (which you have enabled).[0m
:: set variable to y if yes, exit the function if no
if %errorlevel% == 1 (
    set "bouncy=y"
) else (
    set bouncy=n
    call :clearlastprompt
    goto :eof
)
:: detailed questions
echo                                                      Bouncing speed:
set /p "incrementbounce="
echo                                   Minimum scale relative to original from 0.0 to 1.0:
set /p "minimumbounce="
echo                                          Stretch [W]idth, [H]eight, or [B]oth?
choice /c WHB /n
call :clearlastprompt
if %errorlevel% == 1 set bouncetype=width
if %errorlevel% == 2 set bouncetype=height
if %errorlevel% == 3 set bouncetype=both
goto :eof

:: encoding bouncy webm
:encodebouncy
:: remencode to webm so the codecs can be copied
ffmpeg -hide_banner -stats_period 0.05 -loglevel warning -stats -i %outputvar% -c:a libopus -b:a %badaudiobitrate%k -c:v libvpx "%temp%\%filename% webmifed.webm" && echo FFmpeg call 7 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 7 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: get the frame count so we know how many times to loop
ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -i "%temp%\%filename% webmifed.webm" -of csv=p=0 > "%temp%\framecount.txt"
set /p framecount=<"%temp%\framecount.txt"
set /a framecount=%framecount%
del "%temp%\framecount.txt"
:: remove old directory just in case
rmdir "%temp%\qmframes" /s /q > nul 2> nul
:: make the directory
mkdir "%temp%\qmframes"
:: looping through all of the frames
echo Encoding WebM Frame 0 of %framecount%
:loopframes
set /a "loopcount+=1"
echo [1A[2KEncoding WebM Frame %loopcount% of %framecount%
set /a "frametograb=%loopcount%-1"
if %bouncetype% == width (
    ffmpeg -hide_banner -loglevel error -vsync drop -i "%temp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2)):%desiredheight%" -an "%temp%\qmframes\framenum%loopcount%.webm" && echo FFmpeg call 8 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 8 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
) else (
    if %bouncetype% == height (
    ffmpeg -hide_banner -loglevel error -vsync drop -i "%temp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%:%desiredheight%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2))" -an "%temp%\qmframes\framenum%loopcount%.webm" && echo FFmpeg call 9 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 9 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    ) else (
        ffmpeg -hide_banner -loglevel error -vsync drop -i "%temp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2)):%desiredheight%*(((cos(%loopcount%*(%incrementbounce%/12)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2))" -an "%temp%\qmframes\framenum%loopcount%.webm" && echo FFmpeg call 10 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 10 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    )
)
echo file '%temp%\qmframes\framenum%loopcount%.webm' >> "%temp%\qmframes\filelist.txt"
if %loopcount% lss %framecount% goto loopframes
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel warning -stats -f concat -safe 0 -i %temp%\qmframes\filelist.txt -i "%temp%\%filename% webmifed.webm" -map 1:a -map 0:v -c copy "%filename%.webm" && echo FFmpeg call 11 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 11 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
del "%temp%\%filename% webmifed.webm"
set container=.webm
del %outputvar%
set outputvar="%cd%\%filename%.webm"
rmdir "%temp%\qmframes" /s /q
goto :eof
:: speed settings/questions
:: collect the inputs needed to change video and audio speeds (if the user wants to do so)
:speedquestions
:: if there's no video, skip this question
if not %hasvideo% == n (
    echo                     What should the video speed be? [93m^(must be a positive number between 0.5 and 100^)[0m
    echo                                                     ^(Current value: %speedq%^)
    set /p "speedq="
)
set "audiopromptfill=(leave blank to match the video)"
:: if there's no video, this is the first time being asked, so tell the users of the parameters needed, otherwise just tell them how to match it
if %hasvideo% == n (
    set "audiopromptfill=^(must be a positive number between 0.5 and 100^)"
    set "afiller=                    "
) else (
    set "audiopromptfill=^(leave blank to match the video^)"
    set "afiller=                            "
)
echo %afiller%What should the audio speed be? [93m%audiopromptfill%[0m
echo                                                    (Current value: %audiospeedq%)
set /p "audiospeedq="
:: if no input, match audio speed with video speed
if "%audiospeedq%1" == "1" set audiospeedq=%speedq%
:: set the speed filter using the reciprocal
set "speedfilter=setpts=(1/%speedq%)*PTS,"
call :clearlastprompt
goto :eof

:addtext
:: asks if they want to add text
echo                                       Do you want to add text to the video? [Y/N]
choice /c YN /n
:: if yes, set the variable, if no, skip
if %errorlevel% == 1 (
    set addedtextq=y
) else (
    set addedtextq=n
    call :clearlastprompt
    goto :eof
)
:: first text size
set tsize=1
echo                         What size should text one be? [B]ig, [M]edium, [S]mall, or [V]ery small?
choice /c BMSV /n
set tsize=%errorlevel%
:: if very small, set it to half the size of small
if %tsize% == 4 set tsize=6
:: top text
set "toptext= "
echo                                             Enter your text for text one now:
set /p "toptext="
:: ask the user where the font should go on the video
call :screenlocation "text one" textonepos
:: THE NEXT LINES UNTIL setting the text filter IS THE SAME AS THE TOP TEXT, BUT WITH DIFFERENT VARIABLE NAMES
set tsize2=1
echo                         What size should text two be? [B]ig, [M]edium, [S]mall, or [V]ery small?
choice /c BMSV /n
set tsize2=%errorlevel%
if %tsize2% == 4 set tsize2=6
:: secoond text
set "bottomtext= "
echo                                             Enter your text for text two now:
set /p "bottomtext="
call :screenlocation "text two" texttwopos
:: setting text filter
call :clearlastprompt
goto :eof

:textmath
echo Doing text math>>"%temp%\qualitymuncherdebuglog.txt"
:: remove spaces and count the characters in the text
set toptextnospace=%toptext: =_%
echo "%toptextnospace%" > %temp%\toptext.txt
for %%? in (%temp%\toptext.txt) do ( set /a strlength=%%~z? - 2 )
if exist "%temp%\toptext.txt" (del "%temp%\toptext.txt")
:: if below 16 characters, set it to 16 (essentially caps the font size)
if %strlength% LSS 16 set strlength=16
:: bottom text
set bottomtextnospace=%bottomtext: =_%
echo "%bottomtextnospace%" > %temp%\bottomtext.txt
for %%? in (%temp%\bottomtext.txt) do ( set /a strlengthb=%%~z? - 2 )
if exist "%temp%\bottomtext.txt" (del "%temp%\bottomtext.txt")
if %strlengthb% LSS 16 set strlengthb=16
:: use width and size of the text, and the user's inputted text size to determine font size
set /a fontsize=(%desiredwidth%/%strlength%)*2
set /a fontsize=(%fontsize%)/%tsize%
set /a fontsizebottom=(%desiredwidth%/%strlengthb%)*2
set /a fontsizebottom=(%fontsizebottom%)/%tsize2%
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
echo                                              .---------------------------.
echo                                              ^| [1]        [2]        [3] ^|
echo                                              ^|                           ^|
echo                                              ^| [4]        [5]        [6] ^|
echo                                              ^|                           ^|
echo                                              ^| [7]        [8]        [9] ^|
echo                                              ^'---------------------------^'
echo                                             Where should %item% be placed?
choice /n /c 123456789
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
call :clearlastprompt
:: questions about modifying video color
echo                           Do you want to customize saturation, contrast, and brightness? [Y/N]
choice /c YN /n
if %errorlevel% == 1 (
    set colorq=y
) else (
    set colorq=n
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
call :clearlastprompt
:: asks about the video's aspect ratio
echo                                         Do you want to stretch the video? [Y/N]
choice /n
if %errorlevel% == 1 (
    set stretchres=y
) else (
    set stretchres=n
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

:savetoconfigquestion
choice /m "Do you want to save these settings to a config file?"
call :clearlastprompt
if %errorlevel% == 2 goto :eof
:savetoconfig
call :clearlastprompt
echo                                            Enter a name for the config file:
set /p "configname="
:savetoconfigbypassname
if "%~1" == "temp" (set "configname=%temp%\qualitymuncherconfig_autosave")
:: have to escape parentheses because they're nested and this is how i have to do it
if defined textonepos set textoneposesc=%textonepos:(=^^^^^^^^^^(%
if defined textonepos set textoneposesc=%textoneposesc:)=^^^^^^)%
if defined texttwopos set texttwoposesc=%texttwopos:(=^^^^^^^^^^(%
if defined texttwopos set texttwoposesc=%texttwoposesc:)=^^^^^^)%
if defined audiofilters set audiofiltersesc=%audiofilters:(=^^^^^^^^^^(%
if defined audiofilters set audiofiltersesc=%audiofiltersesc:)=^^^^^^)%
echo Saving settings to a config file>>"%temp%\qualitymuncherdebuglog.txt"
echo :: Configuration file for Quality Muncher v%version% > "%configname%.bat"
echo :: Created at %time% on %date% >> "%configname%.bat"
(
    echo set endingmsg=%endingmsg%
    echo set outputfps=%outputfps%
    echo set videobr=%videobr%
    echo set audiobr=%audiobr%
    echo set /a badaudiobitrate=80/%audiobr%
    echo set scaleq=%scaleq%

    echo set novideo=%novideo%
    echo set noaudio=%noaudio%

    echo set trimmed=%trimmed%
    echo set starttime=%starttime%
    echo set vidtime=%vidtime%

    echo set speedq=%speedq%
    echo set "speedfilter=setpts=(1/%speedq%)*PTS,"
    echo set audiospeedq=%audiospeedq%

    echo set addedtextq=%addedtextq%
    echo set tsize=%tsize%
    echo set toptext=%toptext%
    echo set textonepos=%textoneposesc%
    echo set tsize2=%tsize2%
    echo set bottomtext=%bottomtext%
    echo set texttwopos=%texttwoposesc%

    echo set colorq=%colorq%
    echo set colorfilter=%colorfilter%

    echo set stretchres=%stretchres%
    echo set widthratio=%widthratio%
    echo set heightratio=%heightratio%
    echo set "aspectratio=%widthratio%/%heightratio%"

    echo set corrupt=%corrupt%
    echo set corruptsev=%corruptsev%

    echo set spoofduration=%spoofduration%
    echo set durationtype=%durationtype%

    echo set bouncy=%bouncy%
    echo set incrementbounce=%incrementbounce%
    echo set minimumbounce=%minimumbounce%
    echo set bouncetype=%bouncetype%

    echo set resample=%resample%

    echo set frying=%frying%
    echo set levelcolor=%levelcolor%

    echo set stutter=%stutter%
    echo set stutteramount=%stutteramount%

    echo set filtercl=%filtercl%

    echo set audiofilters=%audiofiltersesc%

    echo set tts=%tts%
    echo set ttstext=%ttstext%
    echo set volume=%volume%

    echo set replaceaudio=%replaceaudio%
    echo set lowqualmusic=%lowqualmusic%

    echo set loopn=%loopn%
    echo set qv=%qv%
    echo set imagesc=%imagesc%

    echo exit /b
) >> "%configname%.bat"
echo Saved settings to "%configname%.bat">>"%temp%\qualitymuncherdebuglog.txt"
if "%~1" == "temp" goto :eof
echo You config file is located at "%cd%\%configname%.bat"
pause
call :clearlastprompt
goto :eof

:: asks if they want music and if so, the file to get it from and the start time
:replaceaudioquestion
echo                                         Do you want to replace the audio? [Y/N]                                        
choice /n
if %errorlevel% == 2 (
    set replaceaudio=n
    call :clearlastprompt
    goto :eof
)
:addingthemusic
:: asks for a specific file to get music from
set replaceaudio=y
echo                            Please drag the desired file here, [93mit must be an audio/video file[0m:
set /p lowqualmusic=
:: if it's not a valid file send the user back to input a valid file
if not exist %lowqualmusic% (
    call :clearlastprompt
    echo [91mInvalid file^^! Please drag an existing file from your computer^^![0m
    goto addingthemusic
)
:: asks the user when the music should start
echo                                  Enter a specific start time of the music [93min seconds[0m:
set /p "musicstarttime="
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

:qualityselect
set "dc_s="
set "bc_s="
set "tc_s="
set "uc_s="
set "cc_s="
set "rc_s="
if %videocustom% == y (
    set cc_s=[92m
) else (
    if %videobr% == 3 (
        set dc_s=[92m
    ) else (
        if %videobr% == 5 (
            set bc_s=[92m
        ) else (
            if %videobr% == 8 (
                set tc_s=[92m
            ) else (
                if %videobr% == 9 (
                    set uc_s=[92m
                ) else (
                    if %videorandom% == y (
                        set rc_s=[92m
                    ) else (
                        set cc_s=[92m
                    )
                )
            )
        )
    )
)
echo Selecting video quality>>"%temp%\qualitymuncherdebuglog.txt"
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
echo      %dc_s%[1] Decent[0m           %bc_s%[2] Bad[0m           %tc_s%[3] Terrible[0m       %uc_s%[4] Unbearable[0m        %cc_s%[C] Custom[0m          %rc_s%[R] Random[0m
choice /n /c 1234CRB
:: set quality
set "customizationquestion=%errorlevel%"
if %customizationquestion% == 7 goto :eof
echo Quality Selected: %customizationquestion%>>"%temp%\qualitymuncherdebuglog.txt"
:: custom quality
if %customizationquestion% == 5 set customizationquestion=c
:: random quality
if %customizationquestion% == 6 (
    set videorandom=y
    set customizationquestion=r
    call :randomvideoquality
    goto :eof
) else (
    set videorandom=n
)
:: defines a few variables that will be replaced later; used to check for valid user inputs
set outputfps=24
set videobr=3
set audiobr=3
set scaleq=2
:: sets the quality based on customizationquestion
:: endingmsg is added to the end of the video for the output name
if "%customizationquestion%" == "c" (
    set videocustom=y
    call :clearlastprompt
    echo                                                 Custom %qs%
    echo.
) else (
    set videocustom=n
)
:customquestioncheckpoint
:: custom quality
if "%customizationquestion%" == "c" (
    echo                                        What fps do you want it to be rendered at:
    set /p "outputfps="
    echo                   [93mOn a scale from 1 to 10[0m, how bad should the video bitrate be? 1 bad, 10 very very bad:
    set /p "videobr="
    echo                   [93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad:
    set /p "audiobr="
    echo                     [93mOn a scale from 1 to 10[0m, how much should the video be shrunk by? 1 none, 10 a lot:
    set /p "scaleq="
    echo Custom selected, chose !outputfps! outputfps, !videobr! videobr, %audiobr% audiobr, %scaleq% scaleq>>"%temp%\qualitymuncherdebuglog.txt"
    set endingmsg=Custom Quality
)
:: decent quality
if %customizationquestion% == 1 (
    echo [96mDecent %qs%[0m
    set outputfps=24
    set videobr=3
    set scaleq=2
    set audiobr=3
    set endingmsg=Decent Quality
)
:: bad quality
if %customizationquestion% == 2 (
    echo [96mBad %qs%[0m
    set outputfps=12
    set videobr=5
    set scaleq=4
    set audiobr=5
    set endingmsg=Bad Quality
)
:: terrible quality
if %customizationquestion% == 3 (
    echo [96mTerrible %qs%[0m
    set outputfps=6
    set videobr=8
    set scaleq=8
    set audiobr=8
    set endingmsg=Terrible Quality
)
:: unbearable quality
if %customizationquestion% == 4 (
    echo [96mUnbearable %qs%[0m
    set outputfps=1
    set videobr=16
    set scaleq=12
    set audiobr=9
    set endingmsg=Unbearable Quality
)
:: if custom quality is selected, check if the variables are all whole numbers
:: if they aren't it'll ask again for their values
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
goto :eof

:: the start of advanced mode
:durationquestions
call :clearlastprompt
:: asks if the user wants to trim
choice /m "Do you want to trim the video?"
if %errorlevel% == 1 (
    set trimmed=y
) else (
    set trimmed=n
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
echo Start time %starttime%, Duration %vidtime%>>"%temp%\qualitymuncherdebuglog.txt"
call :clearlastprompt
goto :eof

:: text to speech
:: asks if the user wants to use text to speech and gets the text to be spoken and volume
:voicesynth
choice /m "Do you want to add text-to-speech?"
if %errorlevel% == 1 set tts=y
if %errorlevel% == 2 (
    set tts=n
    call :clearlastprompt
    goto :eof
)
:: verify that the ffmpeg build contains flite by saving the output of ffmpeg to a file and searching for libflite
ffmpeg > nul 2>>"%temp%\ffmpegQM.txt"
> nul find "libflite" "%temp%\ffmpegQM.txt" || (
    echo USER DOES NOT HAVE FLITE INSTALLED>>"%temp%\qualitymuncherdebuglog.txt"
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
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%container%" -movflags +use_metadata_tags -map_metadata 1 -c:v copy -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename%%ttsuffix%%container%" && echo FFmpeg call 12 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 12 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
if exist "%filename%%container%" (del "%filename%%container%")
set outputvar="%cd%\%filename%%ttsuffix%%container%"
set "filename=%filename%%ttsuffix%"
goto :eof

:: miscillaneous filters that are too small to be their own options
:: all of the "toggletc(x)" labels are a part of this, used to toggle the colors
:filterlist
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
:filterlistloop
if "%tcly%" == "n" (
    if %errorlevel% == 2 (
        echo Misc. Filters selected: %filtercl%>>"%temp%\qualitymuncherdebuglog.txt"
        call :clearlastprompt
        goto :eof
    )
)
echo [92mGreen[0m items are selected, [90mgray[0m items are unselected[90m
echo  %tcl1% [1] Erosion - makes the edges of objects appear darker[90m
echo  %tcl2% [2] Lagfun - makes darker pixels update slower[90m
echo  %tcl3% [3] Negate - inverts colors[90m
echo  %tcl4% [4] Interlace - combines frames together using interlacing[90m
echo  %tcl5% [5] Edgedetect - detect and draw edges[90m
echo  %tcl6% [6] Shufflepixels - reorder pixels in video frames[90m
echo  %tcl7% [7] Guided - apply guided filter for edge-preserving smoothing, dehazing, etc[0m
choice /c 1234567B /n /m "Select one or more options: "
if %errorlevel% == 8 (
    call :titledisplay
    goto :eof
)
call :toggletcl%errorlevel%
echo [10A
goto :filterlistloop

:: what all of the toglectl(x) functions do is:
:: - confirm that an option has been made (setting tcly to y)
:: - if the option was previously set to disabled, enable it and add the filter to the filters, highlight the selection, then exit the function
:: - if the option was previously set to enabled, disable it and remove the filter from the filters, remove the highlight, and exit the function

:toggletcl1
    set tcly=y
    if "%tcl1%2" == "[92m2" (
        set "tcl1= "
        set "filtercl=%filtercl:,erosion=%"
        goto :eof
    )
    set "filtercl=%filtercl%,erosion"
    set "tcl1=[92m"
goto :eof

:toggletcl2
    set tcly=y
    if "%tcl2%2" == "[92m2" (
        set "tcl2= "
        set "filtercl=%filtercl:,lagfun=%"
        goto :eof
    )
    set "filtercl=%filtercl%,lagfun"
    set "tcl2=[92m"
goto :eof

:toggletcl3
    set tcly=y
    if "%tcl3%2" == "[92m2" (
        set "tcl3= "
        set "filtercl=%filtercl:,negate=%"
        goto :eof
    )
    set "filtercl=%filtercl%,negate"
    set "tcl3=[92m"
goto :eof

:toggletcl4
    set tcly=y
    if "%tcl4%2" == "[92m2" (
        set "tcl4= "
        set "filtercl=%filtercl:,interlace=%"
        goto :eof
    )
    set "filtercl=%filtercl%,interlace"
    set "tcl4=[92m"
goto :eof

:toggletcl5
    set tcly=y
    if "%tcl5%2" == "[92m2" (
        set "tcl5= "
        set "filtercl=%filtercl:,edgedetect=%"
        goto :eof
    )
    set "filtercl=%filtercl%,edgedetect"
    set "tcl5=[92m"
goto :eof

:toggletcl6
    set tcly=y
    if "%tcl6%2" == "[92m2" (
        set "tcl6= "
        set "filtercl=%filtercl:,shufflepixels=%"
        goto :eof
    )
    set "filtercl=%filtercl%,shufflepixels"
    set "tcl6=[92m"
goto :eof

:toggletcl7
    set tcly=y
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
goto :eof

:: if the website is selected from the menu, it sends the user to the website, clears the console, and goes back to start
:website
echo [96mSending to website^^![0m
start "" https://qualitymuncher.lgbt/
call :clearlastprompt
goto :eof

:: suggestions
:suggestion
set /a wb9=3428*12/5234*32-453+54+(8234*2+(300-3)*2)/3*7/2-3053
:: checks for a connection to discord since you need that to send a message to a webhook
call :clearlastprompt
ping /n 1 discord.com  | find "Reply" > nul
if %errorlevel% == 1 (
    set internet=n
    echo [91mSorry, either discord is down or you're not connected to the internet. Please try again later.[0m
    echo.
    pause
    call :clearlastprompt
    goto :eof
)
:: asks information about the suggestion for details
choice /c SB /m "Would you like to make a suggestion or report a bug?"
if %errorlevel% == 2 goto bugreport
:suggestionactual
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
    goto :eof
)
:continuesuggest
:: please do not abuse this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New suggestion^^!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/webhooks/100557400%wb9%2094%wb6%4/an%wb11%Px9R%wbh4%4tV%wb19%
call :clearlastprompt
echo [92mYour suggestion has been successfully sent to the developers^^![0m
echo.
pause
call :clearlastprompt
goto :eof

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
    echo [91mOkay, your bug report has been cancelled.[0m
    echo.
    pause
    call :clearlastprompt
    goto :eof
)
:: sends the bug report to the webhook
:: please do not abuse this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New bug report^^!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/we^bhooks/100%wbh17%557%mathvar4%400%wb9%2094%wb6%4/an%wb11%Px9R%wbh4%4tV%wb19%
call :clearlastprompt
echo [92mYour bug report has been successfully sent to the developers^^![0m
echo.
pause
call :clearlastprompt
goto :eof

:: where most things direct to when the program is done - plays a nice sound if possible, pauses, then prompts the user for some input
:exiting
echo Made it to exit>>"%temp%\qualitymuncherdebuglog.txt"
echo.
where /q ffplay.exe || goto aftersound
if %done% == y start /min cmd /c ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound
if not b%2 == b goto nopipingforyou
echo Press [C] to close, [O] to open the output, [F] to open the file path, or [P] to pipe the output to another script.
choice /n /c COFPLX /m "You can also press [X] to make a config file, or [L] to generate a debugging log for errors."
if %errorlevel% == 5 (
    call :makelog
    goto closingbar
)
if %errorlevel% == 4 goto piped
if %errorlevel% == 2 %outputvar%
if %errorlevel% == 3 explorer /select, %outputvar%
if %errorlevel% == 6 (
    call :titledisplay
    call :savetoconfig
)
goto closingbar

:nopipingforyou
choice /n /c CLX /m "Press [C] to close, [X] to make a config file, or [L] to generate a debugging log for errors."
if %errorlevel% == 2 (
    call :makelog
    goto closingbar
)
if %errorlevel% == 3 call :savetoconfig
goto closingbar

:: makes a log for when a user might encounter an error
:makelog
call :clearlastprompt
:: go to the logs directory, if it exists
set pastdir=%cd%
if not 1%loggingdir% == 1 cd /d %loggingdir%
:: delete old log
if exist "Quality Muncher Log.txt" del "Quality Muncher Log.txt"
:: stuff to log (anything and everything possible for batch to get that might be responsible for issues)
:: filename and outputvar are seperate from the rest because filesnames can have weird characters that might cause the entire log to fail if it's not seperated
echo Making log...>>"%temp%\qualitymuncherdebuglog.txt"
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
    echo     audiospeedq: %audiospeedq%
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
    echo     frying: %frying%
    echo     tts: %tts%
    echo         ttstext: %ttstext%
    echo         volume: %volume%
    echo     extra effects
    echo         filtercl: %filtercl%
    echo         tcly {at least one effect is enabled}: %tcly%
    echo     stutter: %stutter%
    echo         stutteramount: %stutteramount%
    echo     novideo: %novideo%
    echo     noaudio: %noaudio%
    echo.
    echo USER OPTIONS
    echo     autoupdatecheck: %autoupdatecheck%
    echo     stayopen: %stayopen%
    echo     showtitle: %showtitle%
    echo     animate: %animate%
    echo     animatespeed: %animatespeed%
    echo     encodingspeed: %encodingspeed%
    echo     updatespeed: %updatespeed%
    echo     container: %container%
    echo     audiocontainer: %audiocontainer%
    echo     imagecontainer: %imagecontainer%
    echo FFMPEG DETAILS
)>>"Quality Muncher Log.txt"
echo Log made>>"%temp%\qualitymuncherdebuglog.txt"
:: add ffmpeg to the log
ffmpeg > nul 2>>"Quality Muncher Log.txt"
if %fromrender% == y goto :eof
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
    set internet=n
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
echo Piping output>>"%temp%\qualitymuncherdebuglog.txt"
call :titledisplay
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
echo Piping to FFmpeg>>"%temp%\qualitymuncherdebuglog.txt"
set /p "ffmpeginput=ffmpeg -i %outputvar% "
echo.
echo [38;2;254;165;0mEncoding...[0m
echo.
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %outputvar% %ffmpeginput% && echo FFmpeg call 13 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 13 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
set done=y
echo.
echo [92mDone^^![0m
echo.
where /q ffplay.exe || goto aftersound2
if %done% == y start /min cmd /c ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound2
pause
goto :eof

:customscript
call :clearlastprompt
set /p "customscript=Enter the path to the script you want to pipe to: "
cls
cmd /k call %customscript% %outputvar%
goto closingbar

:: if the user inputs a file manually instead of with send to or drag and drop
:manualfile
set /p file=Please drag your input here: 
echo User is using %file% as a manual file input>>"%temp%\qualitymuncherdebuglog.txt"
cls
call %0 %file%
exit

:: checks for updates - done automatically unless disabled in options
:updatecheck
if exist "%temp%\QMnewversion.txt" del "%temp%\QMnewversion.txt"
:: checks if github is able to be accessed
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 (
    echo Pinging GitHub failed>>"%temp%\qualitymuncherdebuglog.txt"
    call :nointernet
    goto :eof
)
set internet=y
:: grabs the version of the latest public release from the github
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/version.txt" --output %temp%\QMnewversion.txt
set /p newversion=<%temp%\QMnewversion.txt
if exist "%temp%\QMnewversion.txt" (del "%temp%\QMnewversion.txt")
:: if the new version is the same as the current one, go to the start
:: however, if the user choose to update from the main menu, give the option for the user to force an update
if "%version%" == "%newversion%" (
    set isupdate=n
    if %forceupdate% == n (
        goto :eof
    ) else (
        echo Your version of Quality Muncher is up to date^^! Press [C] to continue.
        choice /c CF /n /m "Alternatively, you can forcibly update/repair Quality Muncher by pressing [F]."
        if %errorlevel% == 1 (
            goto :eof
        ) else (
            goto updatescript
        )
    )
) else (
    set isupdate=y
)
:: tells the user a new update is out and asks if they want to update
echo New version found during update check (%newversion%)>>"%temp%\qualitymuncherdebuglog.txt"
echo [96mThere is a new version (%newversion%) of Quality Muncher available^^!
echo Press [U] to update or [S] to skip.
echo [90mTo hide this message in the future, set the variable "autoupdatecheck" in the script options to n.[0m
choice /c US /n
echo.
set isupdate=n
if %errorlevel% == 2 (
    call :clearlastprompt
    goto :eof
)
:updatescript
:: gives the user some choices when updating
echo Are you sure you want to update? This will overwrite the current file^^!
echo [92m[Y] Yes, update and overwrite.[0m [93m[C] Yes, BUT save a copy of the current file.[0m [91m[N] No, take me back.[0m
choice /c YCN /n
if %errorlevel% == 2 (
    copy %me% "Quality Muncher (OLD).bat" || (
        echo [91mError copying the file^^! Updating has been aborted.[0m
        echo Press any key to go to the menu
        pause > nul
        call :titledisplay
        goto :eof
    )
    echo Okay, this file has been saved as a copy in the same directory. Press any key to continue updating.
    pause > nul
)
if %errorlevel% == 3 (
    call :titledisplay
    goto :eof
)
echo.
:: installs the latest public version, overwriting the current one, and running it using this input as a parameter so you don't have to run send to again
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/Quality%%20Muncher.bat" --output %me% || (
    echo Error whe downloading the update, trying fallback>>"%temp%\qualitymuncherdebuglog.txt"
    echo [38;2;254;165;0mPrimary update method failed. Trying fallback script now.[0m
    echo When prompted, please press O, then press enter to update the script.
    powershell -noprofile "iex(iwr -useb install.qualitymuncher.lgbt)"
    echo Exiting in 10 seconds...
    timeout /t 10
    exit
)
cls
:: runs the (updated) script
echo %me%
pause
%me% %*
exit

:: runs if there isn't internet (comes from update check)
:nointernet
set internet=n
echo [91mUpdate check failed, skipping.[0m
echo.
goto :eof

:: random quality
:randomvideoquality
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

:: runs at the start of the script if animate is y (disabled by default)
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

:: essentially the opposite of loadingbar (but exits if animate is n)
:closingbar
if %animate% == n exit
:closingloop
mode con: cols=%cols% lines=%lines%
set /a cols=%cols%-5
set /a lines=%lines%-1
if not %cols% == 14 goto closingloop
endlocal
exit

:: asks if the user wants a custom output name
:outputquestion
choice /m "Would you like a custom output name?"
if %errorlevel% == 2 (
    echo.
    call :clearlastprompt
    goto :eof
)
echo                                         Enter your output name [93mwith no extension[0m:
set /p "filenametemp="
set "filename=%filenametemp%"
call :clearlastprompt
goto :eof

:: audio questions - ran when the user uses an audio file as an input
:novideostream
if %audiocontainer% == .mp3 (
    set audioencoder=libmp3lame
) else (
    set audioencoder=aac
)
goto guimenurefresh

:encodeaudiomultiqueue
set totalfiles=0
for %%x in (%*) do set /a totalfiles+=1
set filesdone=1
for %%a in (%*) do (
    title [!filesdone!/%totalfiles%] Quality Muncher v%version%
    set filesdoneold=!filesdone!
    echo Rendering audio !filesdone!/%totalfiles%>>"%temp%\qualitymuncherdebuglog.txt"
    set /a filesdone=!filesdone!+1
    call :audioencode %%a
)
title [Done] Quality Muncher v%version%
goto end

:audioencode
set "filename=%~n1 (Quality Munched)"
if exist "%filename%%audiocontainer%" call :renamefile
if %ismultiqueue% == y (
    if not %filesdone% == 1 echo.
    echo [38;2;254;165;0m[%filesdoneold%/%totalfiles%] Encoding %1[0m
) else (
    echo [38;2;254;165;0mEncoding...[0m
)
echo.
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% -i %1 ^
-vn %metadata% -preset %encodingspeed% ^
-c:a %audioencoder% -b:a %badaudiobitrate%000 -shortest ^
%audiofilters% ^
-vsync vfr -movflags +use_metadata_tags+faststart "%filename%%audiocontainer%" && echo FFmpeg call 14 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 14 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
set outputvar="%cd%\%filename%%audiocontainer%
if %tts% == y call :encodevoiceNV
goto :eof

:: text-to-speech encoding for no video stream
:: seperate from the video one since it has some options that aren't the same
:encodevoiceNV
set "af2="
if not "%audiofilters%e" == "e" set "af2=,%audiofilters:-af =%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i anullsrc -filter_complex "flite=text='%ttstext%':voice=kal16%af2%,volume=%volume%dB" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%audiocontainer%" -movflags +use_metadata_tags -map_metadata 1 -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename% tts%audiocontainer%" && echo FFmpeg call 14 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 14 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
if exist "%filename%%audiocontainer%" (del "%filename%%audiocontainer%")
set outputvar="%cd%\%filename% tts%audiocontainer%"
goto :eof

:: checks if a file with the same name as the output already exists, if so, appends a (1) to the name, then (2) if that also exists, then (3), etc
:: used to stop ffmpeg from overwriting files
:renamefile
:: start of the repeat until loop (repeats until the file doesn't exist)
:renamefileloop
if %isimage% == y set container=%imagecontainer%
if %hasvideo% == n set "container=%audiocontainer%"
set /a "i+=1"
if exist "%filename% (%i%)%container%" goto renamefileloop
set "filename=%filename% (%i%)"
goto :eof

:imagecheck
echo First file extension is "%~x1">>"%temp%\qualitymuncherdebuglog.txt"
if "%~x1" == ".png" set isimage=y
if "%~x1" == ".jpg" set isimage=y
if "%~x1" == ".jpeg" set isimage=y
if "%~x1" == ".jfif" set isimage=y
if "%~x1" == ".jpe" set isimage=y
if "%~x1" == ".jif" set isimage=y
if "%~x1" == ".jfi" set isimage=y
if "%~x1" == ".pjpeg" set isimage=y
if "%~x1" == ".bmp" set isimage=y
if "%~x1" == ".tiff" set isimage=y
if "%~x1" == ".tif" set isimage=y
if "%~x1" == ".raw" set isimage=y
if "%~x1" == ".heif" set isimage=y
if "%~x1" == ".heic" set isimage=y
if "%~x1" == ".webp" set isimage=y
if "%~x1" == ".jp2" set isimage=y
if "%~x1" == ".j2k" set isimage=y
if "%~x1" == ".jpx" set isimage=y
if "%~x1" == ".jpm" set isimage=y
if "%~x1" == ".jpm" set isimage=y
if "%~x1" == ".mj2" set isimage=y
if "%~x1" == ".gif" set isimage=y
if "%~x1" == ".PNG" set isimage=y
if "%~x1" == ".JPG" set isimage=y
if "%~x1" == ".JPEG" set isimage=y
if "%~x1" == ".JFIF" set isimage=y
if "%~x1" == ".JPE" set isimage=y
if "%~x1" == ".JIF" set isimage=y
if "%~x1" == ".JFI" set isimage=y
if "%~x1" == ".PJPEG" set isimage=y
if "%~x1" == ".BMP" set isimage=y
if "%~x1" == ".TIFF" set isimage=y
if "%~x1" == ".TIF" set isimage=y
if "%~x1" == ".RAW" set isimage=y
if "%~x1" == ".HEIF" set isimage=y
if "%~x1" == ".HEIC" set isimage=y
if "%~x1" == ".WEBP" set isimage=y
if "%~x1" == ".JP2" set isimage=y
if "%~x1" == ".J2K" set isimage=y
if "%~x1" == ".JPX" set isimage=y
if "%~x1" == ".JPM" set isimage=y
if "%~x1" == ".JPM" set isimage=y
if "%~x1" == ".MJ2" set isimage=y
if "%~x1" == ".GIF" set isimage=y
echo Image check succeded, image status: %isimage%>>"%temp%\qualitymuncherdebuglog.txt"
goto :eof

:: asks if user wants to fry the video
:videofrying
choice /m "Do you want to fry the video? (will cause extreme distortion)"
if %errorlevel% == 2 (
    set frying=n
    call :clearlastprompt
    goto :eof
)
set frying=y
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
echo Encoding fried video>>"%temp%\qualitymuncherdebuglog.txt"
echo Frying video...
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=%duration%:r=%outputfps% -vf "noise=allf=t:alls=%level%*10:all_seed=%random%,eq=contrast=%level%*2" -f h264 pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -vf scale=%desiredwidth%:%desiredheight%:flags=%scalingalg% "%temp%\noisemapscaled%container%" && echo FFmpeg call 15 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 15 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %videoinp% -vf "fps=%outputfps%,scale=%desiredwidth%:%desiredheight%:flags=%scalingalg%" -c:a copy "%temp%\scaledinput%container%" && echo FFmpeg call 16 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 16 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i "%temp%\scaledinput%container%" -i "%temp%\noisemapscaled%container%" -i "%temp%\noisemapscaled%container%" -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -c:a copy -filter_complex "split,displace=edge=wrap,fps=%outputfps%,scale=%desiredwidth%x%desiredheight%:flags=%scalingalg%,%fryfilter%" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -c:a copy -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -vf "fps=%outputfps%,rgbashift=rh=%shifth%:rv=%shiftv%:bh=%shifth%:bv=%shiftv%:gh=%shifth%:gv=%shiftv%:ah=%shifth%:av=%shiftv%:edge=wrap" "%temp%\scaledandfriedvideotempfix%container%" && echo FFmpeg call 17 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 17 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: use the output of the 5th ffmpeg call as the input for the final encoding
set "videoinp=%temp%\scaledandfriedvideotempfix%container%"
if exist "%temp%\noisemapscaled%container%" (del "%temp%\noisemapscaled%container%")
if exist "%temp%\scaledinput%container%" (del "%temp%\scaledinput%container%")
echo Done frying video>>"%temp%\qualitymuncherdebuglog.txt"
goto :eof

:: clears the screen up until the title, preventing flashing but keeping the terminal clean
:clearlastprompt
:: move cursor to saved point, then clear any text after the cursor
echo [H[u[0J
goto :eof

:: provides the user a list of recent announcements from the devs
:announcement
:: checks if github is able to be accessed
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 goto fetchannouncementfail
set internet=y
:: grabs the announcements from github
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/bat/announce.txt" --output %temp%\anouncementQM.txt || (
    echo [91mecho Downloading the announcements failed^^! Please try again later.[0m
    echo Press any key to go to the menu
    pause > nul
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
goto :eof

:: fails to access github
:fetchannouncementfail
set internet=n
echo Failed to fetch announcements>>"%temp%\qualitymuncherdebuglog.txt"
echo [91mAnnouncements were not able to be accessed. Either you are not connected to the internet or GitHub is offline.[0m
pause
echo [H[u[0J
goto :eof

:: asks if user wants to stutter the video
:stutter
:: setting the default amount in case the user doesn't enter a value
set stutteramount=2
choice /m "Do you want to add stutter to the video?"
:: if no, exit the function, if yes, set the variable to y (the variable is only used for error logs)
if %errorlevel% == 2 (
    set stutter=n
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

:newmunchmultiq
set originalimagecontainer=%imagecontainer%
set totalfiles=0
for %%x in (%*) do set /a totalfiles+=1
set filesdone=1
for %%a in (%*) do (
    title [!filesdone!/%totalfiles%] Quality Muncher v%version%
    set filesdoneold=!filesdone!
    echo Rendering image !filesdone!/%totalfiles%>>"%temp%\qualitymuncherdebuglog.txt"
    set /a filesdone=!filesdone!+1
    call :newmunchworking %%a %loopn% %qvnew% %imagesc%
)
title [Done] Quality Muncher v%version%
echo.
echo [92mDone^^![0m
set done=y
goto exiting

:newmunchworking
if "%~x1" == ".gif" (
    set imagecontainer=.gif
) else (
    set imagecontainer=%originalimagecontainer%
)
call :clearlastprompt
if %ismultiqueue% == y (
    if not %filesdone% == 1 echo.
    echo [38;2;254;165;0m[%filesdoneold%/%totalfiles%] Encoding %1[0m
) else (
    echo [38;2;254;165;0mEncoding...[0m
)
set loopn=%2
set imagequal=%3
:: imagequal*3 is used for webp/vp9, imagequal is used for -q:v in mjpeg
set /a imagequal3=%imagequal%*3
set /a imagesc=%4
set "tempfolder=%temp%\processingvideo"
if exist "%tempfolder%" (rmdir "%tempfolder%" /q /s)
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
echo Beginning image munch loop>>"%temp%\qualitymuncherdebuglog.txt"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i %1 -preset ultrafast -vf scale=%width%x%height%:flags=%scalingalg% -c:v mjpeg -q:v %imagequal% -f mjpeg "%tempfolder%\%~n11%imagecontainer%"
set /a loopnreal=%loopn%-1
:: loop through a few encoders until the loop is over
echo 0/%loopn%
set /a i=0
:startmunch
set /a i+=1
set /a i1=%i%+1
echo [1A[0J%i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt yuv410p -c:v libx264 -crf %imagequal% -f h264 "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto endmunch
del "%tempfolder%\%~n1%i%%imagecontainer%"
set /a i+=1
set /a i1=%i%+1
echo [1A[0J%i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%widthalt%x%heightalt%:flags=%scalingalg% -preset ultrafast -pix_fmt yuv422p -c:v mjpeg -q:v %imagequal% -f mjpeg "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto endmunch
del "%tempfolder%\%~n1%i%%imagecontainer%"
set /a i+=1
set /a i1=%i%+1
echo [1A[0J%i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=%scalingalg% -c:v %weblib% -pix_fmt yuv411p -compression_level 0 -quality %imagequal3% -f %webp% "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto endmunch
del "%tempfolder%\%~n1%i%%imagecontainer%"
goto startmunch
:endmunch
set /a i2=%i1%+1
echo [1A[0J%loopn%/%loopn%
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
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt rgb24 -c:v libx264 -vf "scale=%width%x%height%:flags=%scalingalg%" -crf %imagequal% -f h264 "%tempfolder%\%~n1%i%final%imagecontainer%" && echo FFmpeg call 18 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 18 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%final%imagecontainer%" -f gif "%filename%%imagecontainerbackup%" && echo FFmpeg call 19 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 19 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
) else (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=%scalingalg% -preset ultrafast -pix_fmt yuv410p -c:v mjpeg -q:v %imagequal% -f mjpeg "%filename%%imagecontainerbackup%" && echo FFmpeg call 20 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 20 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
)
rmdir "%tempfolder%" /q /s
set outputvar="%filename%%imagecontainerbackup%"
goto :eof

:setdefaults
:: default values for variables
call :setquotes
set videocustom=n
set audiocustom=n
set videorandom=n
set audiorandom=n
set outputasgif=n
set novideo=n
set noaudio=n
set fromrender=n
set guimenutitleisshowing=y
set guivideotitleisshowing=y
set guiaudiotitleisshowing=y
set guiimagetitleisshowing=y
set guiextratitleisshowing=y
set complexity=a
set gui_video_quality=[1] Quality
set gui_video_starttimeandduration=[2] Start Time and Duration
set gui_video_speed=[3] Speed
set gui_video_text=[4] Text
set gui_video_color=[5] Color
set gui_video_stretch=[6] Stretch
set gui_video_corruption=[7] Corruption
set gui_video_durationspoof=[8] Duration Spoof
set gui_video_bouncywebm=[9] Bouncy WebM
set gui_video_resamplinginterpolation=[R] Resampling/Interpolation
set gui_video_frying=[F] Frying
set gui_video_framestutter=[S] Frame Stutter
set gui_video_outputasgif=[G] Output as GIF
set gui_video_miscillaneousfilters=[M] Miscillaneous Filters
set gui_video_novideo=[N] No Video
set gui_audio_quality=[1] Quality
set gui_audio_starttimeandduration=[2] Start Time and Duration
set gui_audio_speed=[3] Speed
set gui_audio_distortion=[4] Distortion
set gui_audio_texttospeech=[5] Text to Speech
set gui_audio_replacing=[6] Replacing
set gui_audio_noaudio=[N] No Audio
set "errormsg=[91mOne or more of your inputs for custom quality was invalid^^! Please use only numbers^^![0m"
set qv=5
set loopn=25
set imagesc=2
set isupdate=n
set cols=15
set lines=8
set replaceaudio=n
set done=n
set hasvideo=n
set hasaudio=n
set isimage=n
set distortaudio=n
set tts=n
set frying=n
set stretchres=n
set colorq=n
set addedtextq=n
set resample=n
set stutter=n
set tcly=n
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
set forceupdate=n
set spoofduration=n
set durationtype=superlong
set bouncy=n
set "audiofilters="
set "tcl1= "
set "tcl2= "
set "tcl3= "
set "tcl4= "
set "tcl5= "
set "tcl6= "
set "tcl7= "
set outputfps=24
set videobr=3
set audiobr=3
set scaleq=2
set "qs=Quality Selected^^^^^!"
set "colorfilter="
set method=classic
goto :eof

:: first step to rendering - checks the audio filters, makes sure variables are set correctly, adds things to a log and then calls the right render function (video, audio, or image/gif)
:render
echo Rendering process started on %date% at %time%>>"%temp%\qualitymuncherdebuglog.txt"
if not %isimage% == y (
    set /a badaudiobitrate=80/%audiobr%
    :: set audio filters (since sometimes they won't be set correctly, depending on the order things were enabled)
    if %distortaudio% == n (
        if not %audiospeedq% == 1 (
                set "audiofilters=-af atempo=%audiospeedq%"
            ) else (
                set "audiofilters="
            )
    ) else (
        if %method% == classic (
            set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
            if not %audiospeedq% == 1 (
                set "audiofilters=-af atempo=%audiospeedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)',adelay=%bb1%^|%bb2%^|%bb3%,channelmap=1^|0,aecho=0.8:0.3:%distsev%*2:0.9"
            )
        ) else (
            set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
            if not %audiospeedq% == 1 (
                set "audiofilters=-af atempo=%audiospeedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
            )
        )
    )
)
set fromrender=y
call :makelog
set fromrender=n
echo -----------------LOG----------------->>"%temp%\qualitymuncherdebuglog.txt"
type "Quality Muncher Log.txt">>"%temp%\qualitymuncherdebuglog.txt"
if exist "Quality Muncher Log.txt" del "Quality Muncher Log.txt"
echo ------------------------------------->>"%temp%\qualitymuncherdebuglog.txt"
echo ----------------CONFIG--------------->>"%temp%\qualitymuncherdebuglog.txt"
call :savetoconfigbypassname temp
type "%temp%\qualitymuncherconfig_autosave.bat">>"%temp%\qualitymuncherdebuglog.txt"
echo ------------------------------------->>"%temp%\qualitymuncherdebuglog.txt"
if %hasvideo% == y (
    if %isimage% == y (
        set /a qvnew=^(%qv%*3^)+1
        echo Going to image rendering>>"%temp%\qualitymuncherdebuglog.txt"
        goto newmunchmultiq
    ) else (
        echo Going to video rendering>>"%temp%\qualitymuncherdebuglog.txt"
        goto encodevideomultiq
    )
) else (
    echo Going to audio only rendering>>"%temp%\qualitymuncherdebuglog.txt"
    goto encodeaudiomultiqueue
)
goto guimenu

:audioqualityselect
set "dc_sa="
set "bc_sa="
set "tc_sa="
set "uc_sa="
set "cc_sa="
set "rc_sa="
if %audiocustom% == y (
    set cc_sa=[92m
) else (
    if %audiobr% == 3 (
        set dc_sa=[92m
    ) else (
        if %audiobr% == 5 (
            set bc_sa=[92m
        ) else (
            if %audiobr% == 8 (
                set tc_sa=[92m
            ) else (
                if %audiobr% == 9 (
                    set uc_sa=[92m
                ) else (
                    if %audiorandom% == y (
                        set rc_sa=[92m
                    ) else (
                        set cc_sa=[92m
                    )
                )
            )
        )
    )
)
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
echo      %dc_sa%[1] Decent[0m           %bc_sa%[2] Bad[0m           %tc_sa%[3] Terrible[0m       %uc_sa%[4] Unbearable[0m        %cc_sa%[C] Custom[0m          %rc_sa%[R] Random[0m
choice /n /c 1234CRB
:: set quality
set "audiocustomizationquestion=%errorlevel%"
:: custom quality
if %audiocustomizationquestion% == 7 goto :eof
if %audiocustomizationquestion% == 5 set audiocustomizationquestion=c
:: random quality
if %audiocustomizationquestion% == 6 (
    set audiorandom=y
    set audiocustomizationquestion=r
    set /a audiobr=%random% * 15 / 32768 + 1
    goto :eof
) else (
    set audiorandom=n
)
:: defines a few variables that will be replaced later; used to check for valid user inputs
set audiobr=a
:: sets the quality based on audiocustomizationquestion
:: endingmsg is added to the end of the video for the output name
:customquestioncheckpoint
:: custom quality
if "%audiocustomizationquestion%" == "c" (
    set audiocustom=y
    call :clearlastprompt
    echo                                                 Custom %qs%
    echo.
    echo                  [93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad:
    set /p "audiobr="
) else (
    set audiocustom=n
)
:: decent quality
if %audiocustomizationquestion% == 1 (
    set audiobr=3
)
:: bad quality
if %audiocustomizationquestion% == 2 (
    set audiobr=5
)
:: terrible quality
if %audiocustomizationquestion% == 3 (
    set audiobr=8
)
:: unbearable quality
if %audiocustomizationquestion% == 4 (
    set audiobr=9
)
:: if custom quality is selected, check if the variables are all whole numbers
:: if they aren't it'll ask again for their values
set /a "testforfps=%outputfps%"
set /a "testforvideobr=%videobr%"
set /a "testforaudiobr=%audiobr%"
set /a "testforscaleq=%scaleq%"
if %audiocustomizationquestion% == c (
    if not "%audiobr%"=="%audiobr: =%" (echo %errormsg% & goto customquestioncheckpoint)
    if not %testforaudiobr% == %audiobr% (echo %errormsg% & goto customquestioncheckpoint)
)
goto :eof

:: makes the video options in the GUI either white or green (off and on respectively)
:checktogglesvideo
if not %outputfps% == a (
    call :togglethis gui_video_quality on
) else (
    call :togglethis gui_video_quality off
)
if %trimmed% == y (
    call :togglethis gui_video_starttimeandduration on
) else (
    call :togglethis gui_video_starttimeandduration off
)
if not %speedq% == 1 (
    call :togglethis gui_video_speed on
) else (
    call :togglethis gui_video_speed off
)
if %addedtextq% == y (
    call :togglethis gui_video_text on
) else (
    call :togglethis gui_video_text off
)
if not "a%colorfilter%" == "a" (
    call :togglethis gui_video_color on
) else (
    call :togglethis gui_video_color off
)
if %stretchres% == y (
    call :togglethis gui_video_stretch on
) else (
    call :togglethis gui_video_stretch off
)
if %corrupt% == y (
    call :togglethis gui_video_corruption on
) else (
    call :togglethis gui_video_corruption off
)
if %spoofduration% == y (
    call :togglethis gui_video_durationspoof on
) else (
    call :togglethis gui_video_durationspoof off
)
if %bouncy% == y (
    call :togglethis gui_video_bouncywebm on
) else (
    call :togglethis gui_video_bouncywebm off
)
if %resample% == y (
    call :togglethis gui_video_resamplinginterpolation on
) else (
    call :togglethis gui_video_resamplinginterpolation off
)
if %frying% == y (
    call :togglethis gui_video_frying on
) else (
    call :togglethis gui_video_frying off
)
if %stutter% == y (
    call :togglethis gui_video_framestutter on
) else (
    call :togglethis gui_video_framestutter off
)
if %outputasgif% == y (
    call :togglethis gui_video_outputasgif on
) else (
    call :togglethis gui_video_outputasgif off
)
if not "a%filtercl%" == "a" (
    call :togglethis gui_video_miscillaneousfilters on
) else (
    call :togglethis gui_video_miscillaneousfilters off
)
if %novideo% == y (
    call :togglethis gui_video_novideo on
) else (
    call :togglethis gui_video_novideo off
)
call :autosaveconfig
goto :eof

:: makes the audio options in the GUI either white or green (off and on respectively)
:checktogglesaudio
if not %audiobr% == a (
    call :togglethis gui_audio_quality on
) else (
    call :togglethis gui_audio_quality off
)
if %trimmed% == y (
    call :togglethis gui_audio_starttimeandduration on
) else (
    call :togglethis gui_audio_starttimeandduration off
)
if not %audiospeedq% == 1 (
    call :togglethis gui_audio_speed on
) else (
    call :togglethis gui_audio_speed off
)
if %distortaudio% == y (
    call :togglethis gui_audio_distortion on
) else (
    call :togglethis gui_audio_distortion off
)
if %tts% == y (
    call :togglethis gui_audio_texttospeech on
) else (
    call :togglethis gui_audio_texttospeech off
)
if %replaceaudio% == y (
    call :togglethis gui_audio_replacing on
) else (
    call :togglethis gui_audio_replacing off
)
if %noaudio% == y (
    call :togglethis gui_audio_noaudio on
) else (
    call :togglethis gui_audio_noaudio off
)
call :autosaveconfig
goto :eof

:togglethis
set "temptogglevar=!%1!"
if a%2 == aon (
    set "%1=[92m%temptogglevar:[0m=%[0m"
    goto :eof
)
if a%2 == aoff (
    set "%1=[0m%temptogglevar:[92m=%"
    goto :eof
)
if "%temptogglevar:~0,5%" == "[92m" (
    set %1=[0m%temptogglevar:[92m=%
) else (
    set %1=[92m%temptogglevar%[0m
)
set "temptogglevar"
goto :eof

:setquotes
set quotecount=26
set quoteindex=0
:: quotes and sayings
set messages1=                                       There is something addictive about secrets.
set messages2=                                               The stereo sounds strange.
set messages3=                                                   .bind flight none
set messages4=                                          +5 extra gigashits compared to vegas^^^!
set messages5=                                     The power of the sun... in the palm of my hand.
set messages6=                                         Sometimes the silence guides our minds.
set messages7=                     I am not the villain in this story. I do what I do because there is no choice.
set messages8=                        Don't call it a god complex, there's nothing complex about it. I am God.
set messages9=                                     I was a god, Valeria. I found it... beneath me.
set messages10=                                       Madness to magnet keeps attracting me, me.
set messages11=                                     Heart plays in ways the mind can't figure out.
set messages12=                                   The laws of the land or the heart, what's greater?
set messages13=                                                      Full of soup.
set messages14=                        I once broke the entire script for almost a month and didn't realize it.
set messages15=                                                   There is no spork.
set messages16=                               The eyes see only what the mind is prepared to comprehend.
set messages17=                          If I have seen further, it is by standing on the shoulders of giants.
set messages18=  [38;2;24;24;24mWake up. [38;2;36;36;36mWake up. [38;2;48;48;48mWake up. [38;2;60;60;60mWake up. [38;2;72;72;72mWake up. [38;2;84;84;84mWake up. [38;2;96;96;96mWake up. [38;2;84;84;84mWake up. [38;2;72;72;72mWake up. [38;2;60;60;60mWake up. [38;2;48;48;48mWake up. [38;2;36;36;36mWake up. [38;2;24;24;24mWake up. [0m
set messages19=                       The mystery of life isn't a problem to solve, but a reality to experience.
set messages20=                                           Simulating hone renders since 2022.
set messages21=                                               Sanity check not mandatory.
set messages22=                                           Fatal error occurred. Just kidding.
set messages23=                                                    Missing Operand.
set messages24=                                     Statements dreamed up by the utterly deranged.
set messages25=                                                Hold gently like burger.
set messages26=                                                          Meow
goto :eof

:messagedisplay
if %displaymessages% == n goto :eof
set /a "quoteindex=%random% * %quotecount% / 32768 + 1"
set /a "quoteindex=%random% * %quotecount% / 32768 + 1"
echo.
echo [38;2;123;169;181m!messages%quoteindex%![0m
echo.
goto :eof

:ending
if %animate% == y goto closingbar