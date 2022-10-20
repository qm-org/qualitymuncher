:: This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
:: This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
:: You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

:: made by Frost#5872
:: https://github.com/qm-org/qualitymuncher

@echo off
echo Log has been started>"%temp%\qualitymuncherdebuglog.txt"
setlocal enabledelayedexpansion
set me=%0

:: OPTIONS - THESE RESET AFTER UPDATING SO KEEP A COPY SOMEWHERE (unless you use the defaults)
    :: clear the screen when each render finishes
    set clearaftereachrender=y
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
    :: spinning loading bar
    set loadingbar=y
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
    :: progress bar options
    :: enable or disable progress bar
    set progressbar=y
    :: character to represent amount completed (MUST BE A SINGLE CHARACTER, NO MORE, NO LESS)
    set "progressbar_donechar= "
    :: prefix of all the characters (a color code is useful here)
    set "progressbar_donecharprefix=[48;2;49;191;204m"
    :: suffix of all the characters (again, a color code or something similar is useful here)
    set "progressbar_donecharsuffix=[48;2;71;71;71m"
    :: character to represent amount not yet completed
    set "progressbar_unfinishedchar= "
    :: length of progress bar
    set progressbar_size=120
    :: progress bar animation speed
    set progressbaranimated_speed=3
:: END OF OPTIONS
:: ################################################################################################################################
:: #########################    WARNING: modifying any lines beyond this point could break the script!    #########################
:: ################################################################################################################################

:: ========================================
:: startup
:: ========================================

:: default values for variables
call :setdefaults
echo Default variables set>>"%temp%\qualitymuncherdebuglog.txt"
if "%animate%" == "y" call :loadingbar
:: code page for proper character display
chcp 437 > nul
:: resetting quality muncher's temp folder
set "qmtemp=%temp%\qualitymunchertemp"
rmdir "%qmtemp%" > nul
mkdir "%qmtemp%" > nul
set version=1.5.3
:: start of the debug log
echo Quality Muncher v%version% successfully started on %date% at "%time%">>"%temp%\qualitymuncherdebuglog.txt"
echo ---------------INPUTS---------------->>"%temp%\qualitymuncherdebuglog.txt"
echo %*>>"%temp%\qualitymuncherdebuglog.txt"
echo ------------------------------------->>"%temp%\qualitymuncherdebuglog.txt"
set ismultiqueue=n
:: if the file is ran with a parameter:
::  - check if it matches any standard help args
::  - check the current directory and fix it if needed
if not "%~1%" == "" (
    if "%~1" == "-h" goto arghelp
    if "%~1" == "--h" goto arghelp
    if "%~1" == "-help" goto arghelp
    if "%~1" == "--help" goto arghelp
    if "%~1" == "-?" goto arghelp
    if "%~1" == "--?" goto arghelp
    if "%~1" == "?" goto arghelp
    if "%~1" == "/?" goto arghelp
    if "%~1" == "/h" goto arghelp
    if "%~1" == "/help" goto arghelp
)
:: if there is at least one parameter, check all parameters for config files (anything with a .bat extension)
if not "%~1" == "" (
    set extensioncounter=0
    for %%a in (%*) do (
        call :extensioncheck "%%~a" .bat
    )
)
call :loadinganimation
:: check if multiqueue is being used (since we don't need to display some information if it isn't)
if not "%~2" == "" (
    set ismultiqueue=y
    echo More than one parameter is being used to run the file>>"%temp%\qualitymuncherdebuglog.txt"
)
title Quality Muncher v%version%
:: checks if ffmpeg is installed, and if it isn't, it'll send a tutorial to install it. 
where /q ffmpeg.exe || (
    echo FFmpeg not found, sending error, pausing, then exiting>>"%temp%\qualitymuncherdebuglog.txt"
    echo [91mERROR: You either don't have ffmpeg installed or don't have it in PATH.[0m
    echo Please install it as it's needed for this script to work.
    choice /n /c gc /m "Press [G] for a guide on installing it, or [C] to close the script."
    if %errorlevel% == 1 start "" https://www.youtube.com/watch?v=WwWITnuWQW4
    goto closingbar
)
call :loadinganimation
:: checks for inputs, if no input tell them and send to a secondary main menu
set /a wb5=7+1-4+5/6+11-5+1*51/7*2-4+94*14/(14+22)*3/57-6
set wbh2=Zh9-TL8nNTP%wb5%c1PwW
set wbh4=2YDHasv4%wb1%GPzEtpWFb3E7zi%wbh2%qnyk7B
if "%showtitle%" == "y" (
    echo [0;0H                 [38;2;39;55;210m____                 _  _  _              __  __                      _
    echo                 [38;2;0;87;228m/ __ \               ^| ^|^(_^)^| ^|            ^|  \/  ^|                    ^| ^|
    echo                [38;2;0;111;235m^| ^|  ^| ^| _   _   __ _ ^| ^| _ ^| ^|_  _   _    ^| \  / ^| _   _  _ __    ___ ^| ^|__    ___  _ __
    echo                [38;2;0;130;235m^| ^|  ^| ^|^| ^| ^| ^| / _` ^|^| ^|^| ^|^| __^|^| ^| ^| ^|   ^| ^|\/^| ^|^| ^| ^| ^|^| '_ \  / __^|^| '_ \  / _ \^| '__^|
    echo                [38;2;0;148;230m^| ^|__^| ^|^| ^|_^| ^|^| {_^| ^|^| ^|^| ^|^| ^|_ ^| ^|_^| ^|   ^| ^|  ^| ^|^| ^|_^| ^|^| ^| ^| ^|^| {__ ^| ^| ^| ^|^|  __/^| ^|
    echo                 [38;2;0;163;221m\___\_\ \__,_^| \__,_^|^|_^|^|_^| \__^| \__, ^|   ^|_^|  ^|_^| \__,_^|^|_^| ^|_^| \___^|^|_^| ^|_^| \___^|^|_^|
    echo                                                   [38;2;0;178;211m__/ ^|
    echo                                                  [38;2;49;191;204m^|___/[0m
    call :splashtext
    echo.[s
)
call :loadinganimation
:: checks for updates
if %autoupdatecheck% == y (
    if %hasbatch% == n call :updatecheck
)
if "%~1%" == "" (
    echo File was ran without parameters ^(no input^)>>"%temp%\qualitymuncherdebuglog.txt"
    goto guimenurefresh
)
call :loadinganimation
:: checks if the input has a video stream (i.e. if the input is an audio file)
:: and if there isn't a video stream, ask audio questions instead
if not %numthathasbatch% == 1 (
    call :imagecheck %1
) else (
    if exist "%~2" (
        call :imagecheck %2
    ) else (
        set noinput=y
        goto guimenurefresh
    )
)
if not exist "%~1" (
    goto guimenurefresh
    echo File parameter does not exist>>"%temp%\qualitymuncherdebuglog.txt"
)
call :loadinganimation
:: get the audio stream and set it to a variable
if not %numthathasbatch% == 1 (
    set inputvideo="%~1"
) else (
    set inputvideo="%~2"
)
echo Input video for testing is !inputvideo!>>"%temp%\qualitymuncherdebuglog.txt"
ffprobe -i %inputvideo% -show_streams -select_streams a -loglevel error > %qmtemp%\astream.txt
set /p astream=<%qmtemp%\astream.txt
if exist "%qmtemp%\astream.txt" (del "%qmtemp%\astream.txt")
if not defined astream (
    echo Input does not have an audio stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasaudio=n
) else (
    echo Input has an audio stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasaudio=y
)
call :loadinganimation
:: get the video stream and set it to a variable, then 
ffprobe -i %inputvideo% -show_streams -select_streams v -loglevel error > %qmtemp%\vstream.txt
set /p vstream=<%qmtemp%\vstream.txt
if exist "%qmtemp%\vstream.txt" (del "%qmtemp%\vstream.txt")
call :loadinganimation
if 1%vstream% == 1 (
    echo Input does not have a video stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasvideo=n
    if %hasaudio% == y (
        :: if the input has an audio stream, set the audio encoder based on the input's container
        :: then go to the menu
        if %audiocontainer% == .mp3 (
            set audioencoder=libmp3lame
        ) else (
            set audioencoder=aac
        )
        if %hasbatch% == y goto render
        goto guimenurefresh
    ) else (
        :: if the video has no video nor audio streams, set noinput to y and go to the menu
        echo Video has neither audio nor video streams, assumed to be an invalid input and going to noinput in the TUI>>"%temp%\qualitymuncherdebuglog.txt"
        set noinput=y
        goto guimenurefresh
    )
) else (
    echo Input has a video stream>>"%temp%\qualitymuncherdebuglog.txt"
    set hasvideo=y
)
if %hasbatch% == y goto render
goto guimenurefresh

:: ========================================
:: startup functions
:: ========================================

:: display a message if ran with a help argument
:arghelp
echo.
echo Quality Muncher v%version%
echo Usage    -  [Path to Quality Muncher] [Path to input files]
echo Example  -  "Quality Muncher" C:\desktop\video_no_spaces.mp4 "D:\drive\video with spaces.mkv"
echo Important:
echo  - don't use inputs of different media types together (such as an image and a video)
echo  - remember to quote any file paths with spaces
endlocal
exit /b 0

:: check if the extension of a file matches the second parameter
:extensioncheck
set /a extensioncounter+=1
set "extensioncheck_param=NO EXTENSION"
set extensioncheck_param=%~x1
if "a%~x1" == "a%~2%" (
    set hasbatch=y
    set showtitle=n
    set progressbar=n
    set clearaftereachrender=n
    set loadingbar=n
    set /a numthathasbatch=%extensioncounter%
    call %1
)
set "extensioncheck_param="
goto :eof

:: displays the title
:titledisplay
cls
if "%showtitle%" == "n" (
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
call :splashtext
echo.[s
goto :eof

:: sets default values for variables
:setdefaults
:: splash texts
call :setquotes
set numthathasbatch=0
set hasbatch=n
set progressbar_charisdefined=n
set endingmsg=Decent Quality
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
set gui_video_miscellaneousfilters=[M] Miscellaneous Filters
set gui_video_novideo=[N] No Video
set gui_video_visualnoise=[V] Visual Noise
set gui_video_constantquantizer=[Q] Constant Quantizer
set gui_video_vignette=[I] Vignette
set gui_video_zoom=[Z] Zoom
set gui_video_fadein=[P] Fade In
set gui_video_fadeout=[O] Fade Out
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
set textmode=s
set resample=n
set stutter=n
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
set visualnoise=n
set constantquantizer=n
set vignette=n
set zoom=n
set fadein=n
set fadeout=n
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
set method=simple
goto :eof

:: splash texts
:setquotes
set quotecount=26
set quoteindex=0
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
set messages21=                                                Sanity check not mandatory.
set messages22=                                           Fatal error occurred^^^! Just kidding.
set messages23=                                                    Missing Operand.
set messages24=                                     Statements dreamed up by the utterly deranged.
set messages25=                                                Hold gently like burger.
set messages26=                                                          Meow
set messages27=                                            One must imagine Sisyphus happy.
set messages27=                                           What is a rebel? A man who says no.
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
if %animate% == n endlocal & exit /b 0
:closingloop
mode con: cols=%cols% lines=%lines%
set /a cols=%cols%-5
set /a lines=%lines%-1
if not %cols% == 14 goto closingloop
endlocal
exit /b 0

:: checks for updates - done automatically unless disabled in options
:updatecheck
call :loadinganimation
if exist "%qmtemp%\QMnewversion.txt" del "%qmtemp%\QMnewversion.txt"
:: checks if github is able to be accessed
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 (
    echo Pinging GitHub failed>>"%temp%\qualitymuncherdebuglog.txt"
    set internet=n
    echo [91mUpdate check failed, skipping.[0m
    echo.
    goto :eof
)
call :loadinganimation
set internet=y
:: grabs the version of the latest public release from the github
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/main/version.txt" --output %qmtemp%\QMnewversion.txt
set /p newversion=<%qmtemp%\QMnewversion.txt
if exist "%qmtemp%\QMnewversion.txt" (del "%qmtemp%\QMnewversion.txt")
call :loadinganimation
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
call :clearlastprompt
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
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/main/Quality%%20Muncher.bat" --output %me% || (
    echo Error whe downloading the update, trying fallback>>"%temp%\qualitymuncherdebuglog.txt"
    echo [38;2;254;165;0mPrimary update method failed. Trying fallback script now.[0m
    echo When prompted, please press O, then press enter to update the script.
    powershell -noprofile "iex(iwr -useb install.qualitymuncher.lgbt)"
    echo Exiting in 10 seconds...
    timeout /t 10
    endlocal
    exit /b 0
)
cls
:: runs the (updated) script
%me% %*
endlocal
exit /b 0

:: checks if the input is an image
:: assumes the first parameter it was ran with is a file
:imagecheck
echo First file extension is "%~x1">>"%temp%\qualitymuncherdebuglog.txt"
:: make a variable with the first file extension in lowercase
set "firstex=%~x1"
set "_UCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "_LCASE=abcdefghijklmnopqrstuvwxyz"
for /l %%a in (0,1,25) do (
    call :makelowercase %%a
)
echo Lowercase first file extension is "%firstex%">>"%temp%\qualitymuncherdebuglog.txt"
if "%firstex%" == ".png" set isimage=y
if "%firstex%" == ".jpg" set isimage=y
if "%firstex%" == ".jpeg" set isimage=y
if "%firstex%" == ".jfif" set isimage=y
if "%firstex%" == ".jpe" set isimage=y
if "%firstex%" == ".jif" set isimage=y
if "%firstex%" == ".jfi" set isimage=y
if "%firstex%" == ".pjpeg" set isimage=y
if "%firstex%" == ".bmp" set isimage=y
if "%firstex%" == ".tiff" set isimage=y
if "%firstex%" == ".tif" set isimage=y
if "%firstex%" == ".raw" set isimage=y
if "%firstex%" == ".heif" set isimage=y
if "%firstex%" == ".heic" set isimage=y
if "%firstex%" == ".webp" set isimage=y
if "%firstex%" == ".jp2" set isimage=y
if "%firstex%" == ".j2k" set isimage=y
if "%firstex%" == ".jpx" set isimage=y
if "%firstex%" == ".jpm" set isimage=y
if "%firstex%" == ".jpm" set isimage=y
if "%firstex%" == ".mj2" set isimage=y
if "%firstex%" == ".gif" set isimage=y
echo Image check succeded, image status: "%isimage%">>"%temp%\qualitymuncherdebuglog.txt"
goto :eof

:: makes the first file extension lowercase, letter by letter
:: assumes the first parameter it was ran with is a string
:makelowercase
set counterex=%1
set _FROM=!_UCASE:~%counterex%,1!!
set _TO=!_LCASE:~%counterex%,1!
set firstex=!firstex:%_FROM%=%_TO%!
goto :eof










:: ################################################################################################################################################################
:: ################################################################################################################################################################
:: main menu and main menu functions
:: ################################################################################################################################################################
:: ################################################################################################################################################################

:guimenu
set guimenutitleisshowing=y
:guimenurefresh
:: display [I]mage for images and [V]ideo for videos
:: gray out video options if there's no video stream
if %hasvideo% == y (
    set videogui=[V]ideo
    if %isimage% == y set videogui=[I]mage
) else (
    set videogui=[38;2;100;100;100m[V]ideo[0m
    if %isimage% == y set videogui=[38;2;100;100;100m[I]mage[0m
)
:: gray out audio options if there's no audio stream
if %hasaudio% == y (
    set audiogui=[A]udio
) else (
    set audiogui=[38;2;100;100;100m[A]udio[0m
)
:: if the title is already showing, just clear the options
:: if the title isn't showing, clear the console and display the title
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
    echo Main GUI choices: VALSCEIR>>"%temp%\qualitymuncherdebuglog.txt"
    echo                                                         [92m[R]ender[0m
    echo.
    choice /c VALSCEIR /n
) else (
    if %hasaudio% == y (
        echo Main GUI choices: VALSCEIR>>"%temp%\qualitymuncherdebuglog.txt"
        echo                                                         [92m[R]ender[0m
        echo.
        choice /c VALSCEIR /n
    ) else (
        :: if there's no audio or video, tell the user they can't render and gray out the option
        echo Main GUI choices: VALSCEI>>"%temp%\qualitymuncherdebuglog.txt"
        echo                                                         [38;2;100;100;100m[R]ender[0m
        echo                                             You must have an input to render.
        choice /c VALSCEI /n
    )
)
echo Main GUI option is %errorlevel%  >>"%temp%\qualitymuncherdebuglog.txt"
:: echo a bell if a user tried to do something like opening video settings with no video stream or image settings with a video
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
:: audio options
if %errorlevel% == 2 (
    if %hasaudio% == y (
        goto guiaudiooptions
    ) else (
        echo 
    )
)
:: load a custom config
if %errorlevel% == 3 (
    call :clearlastprompt
    call :loadcustomconfig
    goto guimenurefresh
)
:: save a custom config
if %errorlevel% == 4 (
    call :savetoconfig
    goto guimenurefresh
)
:: exit and exit confirmation
if %errorlevel% == 5 (
    echo                                              [31mAre you sure you want to exit?[0m
    choice /n
    if !errorlevel! == 1 (
        endlocal
        exit /b 0
    ) else (
        goto guimenurefresh
    )
)
:: extra menu
if %errorlevel% == 6 (
    goto guiextra
)
:: image options
if %errorlevel% == 7 (
    if %isimage% == y (
        goto guiimageoptions
    ) else (
        echo 
    )
)
:: rendering
if %errorlevel% == 8 (
    goto render
)
goto guimenurefresh

:: loads a custom config from the user
:loadcustomconfig
echo Please enter either:
echo  - the path of your config file
echo  - [38;2;254;165;0mB[0m to go back
echo  - or [38;2;254;165;0mR[0m to use your last used settings
set /p "configfile="
if %configfile% == b goto :eof
if %configfile% == B goto :eof
if %configfile% == R (
    :: if the file doesn't exist, tell the user and go back
    if not exist "%temp%\qualitymuncherconfig_autosave.bat" (
        echo [91mMost recent settings were unable to be found.[0m
        pause
        goto :eof
    )
    call "%temp%\qualitymuncherconfig_autosave.bat"
    goto :eof
)
if %configfile% == r (
    :: if the file doesn't exist, tell the user and go back
    if not exist "%temp%\qualitymuncherconfig_autosave.bat" (
        echo [91mMost recent settings were unable to be found.[0m
        pause
        goto :eof
    )
    call "%temp%\qualitymuncherconfig_autosave.bat"
    goto :eof
)
:: if the file doesn't exist, tell the user and go back
if not exist %configfile% (
    call :clearlastprompt
    echo [91mFile not found.[0m
    goto :loadcustomconfig
)
:: call the config file to load the settings
call %configfile%
goto :eof

:: saves the current settings to a config file
:savetoconfig
call :clearlastprompt
echo                                            Enter a name for the config file:
set /p "configname="
:savetoconfigbypassname
:: if it is being saved automatically, and not manually, save it to temp
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

    echo set outputasgif=%outputasgif%

    echo set trimmed=%trimmed%
    echo set starttime=%starttime%
    echo set vidtime=%vidtime%

    echo set speedq=%speedq%
    echo set "speedfilter=setpts=(1/%speedq%)*PTS,"
    echo set audiospeedq=%audiospeedq%

    echo set addedtextq=%addedtextq%

    echo set colorq=%colorq%
    echo set colorfilter=%colorfilter%

    echo set visualnoise=%visualnoise%
    echo set "visualnoisefilter=%visualnoisefilter%"

    echo set constantquantizer=%constantquantizer%
    echo set "constantquantizerfilter=%constantquantizerfilter%"

    echo set vignette=%vignette%
    echo set "vignettefilter=%vignettefilter%"

    echo set zoom=%zoom%
    echo set "zoomfilter=%zoomfilter%"

    echo set fadein=%fadein%
    echo set "fadeinfilter=%fadeinfilter%"

    echo set fadeout=%fadeout%
    echo set fadeoutduration=%fadeoutduration%

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
    echo set level=%level%

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
) >> "%configname%.bat"
if %addedtextq% == y call :addtologtextadditions
echo exit /b 0 >> "%configname%.bat"
echo Saved settings to "%configname%.bat">>"%temp%\qualitymuncherdebuglog.txt"
:: skip the message and pausing if it is being saved automatically
if "%~1" == "temp" goto :eof
echo You config file is located at "%cd%\%configname%.bat"
pause
call :clearlastprompt
goto :eof

:: add text settings to the config file
:addtologtextadditions
set makelogcounter=0
:addtologtextadditionsloop
set /a makelogcounter+=1
echo set "textamount=%textamount%">>"%configname%.bat"
echo set tsize!makelogcounter!=!tsize%makelogcounter%!>>"%configname%.bat"
echo set text!makelogcounter!=!text%makelogcounter%!>>"%configname%.bat"
echo set texthpos!makelogcounter!=!texthpos%makelogcounter%!>>"%configname%.bat"
echo set textcolor!makelogcounter!=!textcolor%makelogcounter%!>>"%configname%.bat"
if not %makelogcounter% == %textamount% goto addtologtextadditionsloop
goto :eof

:: first step to rendering - checks the audio filters, makes sure variables are set correctly, adds things to a log and then calls the right render function (video, audio, or image/gif)
:render
echo Rendering process started on %date% at "%time%">>"%temp%\qualitymuncherdebuglog.txt"
if not "%isimage%" == "y" (
    set /a badaudiobitrate=80/%audiobr%
    :: set audio filters (since sometimes they won't be set correctly, depending on the order things were enabled)
    if %distortaudio% == n (
        if not %audiospeedq% == 1 (
                set "audiofilters=-af atempo=%audiospeedq%"
            ) else (
                set "audiofilters="
            )
    ) else (
        if %method% == simple (
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
:: saves the final config and a log to the debug logs
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
:: encode using the right encoding function
if "%hasvideo%" == "y" (
    if %isimage% == y (
        set /a qvnew=^(%qv%*3^)+1
        echo Going to image rendering>>"%temp%\qualitymuncherdebuglog.txt"
        goto encodeimagemultiqueue
    ) else (
        echo Going to video rendering>>"%temp%\qualitymuncherdebuglog.txt"
        goto encodevideomultiq
    )
) else (
    echo Going to audio only rendering>>"%temp%\qualitymuncherdebuglog.txt"
    goto encodeaudiomultiqueue
)
goto guimenu

:: where most things direct to when the script is done - plays a nice sound if possible, pauses, then prompts the user for some input
:exiting
echo Made it to exit>>"%temp%\qualitymuncherdebuglog.txt"
echo.
where /q ffplay.exe || goto aftersound
if %done% == y start /min cmd /c ffplay "C:\Windows\Media\notify.wav" -volume 50 -autoexit -showmode 0 -loglevel quiet
:aftersound
:: go to nopipingforyou if the user is using more than one input
if not "%~2" == "" goto nopipingforyou
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

:: where the script goes if the user is using multiqueue
:nopipingforyou
choice /n /c CLX /m "Press [C] to close, [X] to make a config file, or [L] to generate a debugging log for errors."
if %errorlevel% == 2 (
    call :makelog
    goto closingbar
)
if %errorlevel% == 3 call :savetoconfig
goto closingbar

:: pipes the output to another script of the user's choosing
:piped
echo Piping output>>"%temp%\qualitymuncherdebuglog.txt"
call :titledisplay
echo Scripts found:
:: add scripts here, if you want
echo [S] Custom Script
echo [1] FFmpeg
echo.
:: selecting and piping
choice /n /c S1C /m "Select a script to pipe to, or press [C] to close: "
if %errorlevel% == 1 goto customscript
cls
if %errorlevel% == 3 endlocal & exit /b 0
if %errorlevel% == 2 call :ffmpegpipe
goto closingbar

:: piping the output to ffmpeg
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

:: piping to a custom script provided by the user
:customscript
call :clearlastprompt
set /p "customscript=Enter the path to the script you want to pipe to: "
cls
cmd /k call %customscript% %outputvar%
goto closingbar

:: makes a log for when a user might encounter an error
:makelog
call :clearlastprompt
:: go to the logs directory, if it exists
set pastdir=%cd%
if defined loggingdir cd /d %loggingdir%
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
    echo         textamount: %textamount%
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
echo ==================>>"Quality Muncher Log.txt"
echo BEGIN FULL DEBUG LOG>>"Quality Muncher Log.txt"
echo ==================>>"Quality Muncher Log.txt"
type "%temp%\qualitymuncherdebuglog.txt">>"Quality Muncher Log.txt"
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
curl -s --upload-file "Quality Muncher Log.txt" https://transfer.sh > "%qmtemp%\curlurl.txt"
set /p curlurl=<"%qmtemp%\curlurl.txt"
if exist "%qmtemp%\curlurl.txt" (del "%qmtemp%\curlurl.txt")
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










:: ################################################################################################################################################################
:: ################################################################################################################################################################
:: video options and video option functions
:: ################################################################################################################################################################
:: ################################################################################################################################################################

:: display the title for the video options
:titledisplayvideo
cls
if "%showtitle%" == "n" (
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
call :splashtext
echo.[s
goto :eof

:: video options
:guivideooptions
set guivideotitleisshowing=y
:guivideooptionsrefresh
:: save the config, then make sure any enabled options are green and disabled options are gray
call :autosaveconfig
call :checktogglesvideo
:: display the title if it isn't already showing
if %guivideotitleisshowing% == y (
    call :titledisplayvideo
) else (
    call :clearlastprompt
)
set guivideotitleisshowing=n
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
echo               %gui_video_quality%                     %gui_video_starttimeandduration%                     %gui_video_speed%
echo.
echo                %gui_video_text%                                %gui_video_color%                             %gui_video_stretch%
echo.
echo             %gui_video_corruption%                        %gui_video_durationspoof%                       %gui_video_bouncywebm%
echo.
echo        %gui_video_resamplinginterpolation%                   %gui_video_frying%                          %gui_video_framestutter%
echo.
echo            %gui_video_outputasgif%                   %gui_video_miscellaneousfilters%                     %gui_video_novideo%
echo.
echo         %gui_video_constantquantizer%                     %gui_video_visualnoise%                          %gui_video_vignette%
echo.
echo                %gui_video_zoom%                              %gui_video_fadein%                             %gui_video_fadeout%
choice /c 123456789RFSGMBNVQIZPO /n
call :clearlastprompt
echo Video GUI option is %errorlevel% >>"%temp%\qualitymuncherdebuglog.txt"
set /a gui_video_var=%errorlevel%
if %gui_video_var% == 1 call :qualityselect
if %gui_video_var% == 2 call :durationquestions
if %gui_video_var% == 3 call :speedquestions
if %gui_video_var% == 4 call :addtext
if %gui_video_var% == 5 call :colorquestions
if %gui_video_var% == 6 call :stretch
if %gui_video_var% == 7 call :corruption
if %gui_video_var% == 8 call :durationspoof
if %gui_video_var% == 9 call :webmstretch
if %gui_video_var% == 10 if %resample% == y (
    set resample=n
) else (
    set resample=y
)
if %gui_video_var% == 11 call :videofrying
if %gui_video_var% == 12 call :stutter
if %gui_video_var% == 13 if %outputasgif% == y (
    set outputasgif=n
) else (
    set outputasgif=y
)
if %gui_video_var% == 14 call :filterlist
if %gui_video_var% == 15 goto guimenu
if %gui_video_var% == 16 if %novideo% == y (
    set novideo=n
) else (
    set novideo=y
)
if %gui_video_var% == 17 call :visualnoise
if %gui_video_var% == 18 call :constantquantizer
if %gui_video_var% == 19 call :vignette
if %gui_video_var% == 20 call :zoom
if %gui_video_var% == 21 call :fadein
if %gui_video_var% == 22 call :fadeout
goto guivideooptionsrefresh

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
    call :togglethis gui_video_miscellaneousfilters on
) else (
    call :togglethis gui_video_miscellaneousfilters off
)
if %novideo% == y (
    call :togglethis gui_video_novideo on
) else (
    call :togglethis gui_video_novideo off
)
if %visualnoise% == y (
    call :togglethis gui_video_visualnoise on
) else (
    call :togglethis gui_video_visualnoise off
)
if %constantquantizer% == y (
    call :togglethis gui_video_constantquantizer on
) else (
    call :togglethis gui_video_constantquantizer off
)
if %vignette% == y (
    call :togglethis gui_video_vignette on
) else (
    call :togglethis gui_video_vignette off
)
if %zoom% == y (
    call :togglethis gui_video_zoom on
) else (
    call :togglethis gui_video_vignette off
)
if %fadein% == y (
    call :togglethis gui_video_fadein on
) else (
    call :togglethis gui_video_fadein off
)
if %fadeout% == y (
    call :togglethis gui_video_fadeout on
) else (
    call :togglethis gui_video_fadeout off
)
call :autosaveconfig
goto :eof

:: ========================================
:: video option questions
:: ========================================

:: select the video quality
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
echo Quality Selected: "%customizationquestion%">>"%temp%\qualitymuncherdebuglog.txt"
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

:: random quality
:randomvideoquality
:: max and minimum for the random values
set min=1
set max=15
echo.
:: says "Random Quality Selected^^!" with "Random" in rainbow text color color
echo [91mR[93ma[92mn[96md[94mo[95mm[0m %qs%
:: gets random values
set /a outputfps=%random% %% 30
set /a videobr=%random% * %max% / 32768 + %min%
set /a scaleq=%random% * %max% / 32768 + %min%
set /a audiobr=%random% * %max% / 32768 + %min%
set endingmsg=Random Quality
goto :eof

:: asks for start time and duration of video
:durationquestions
call :clearlastprompt
:: asks if the user wants to trim
choice /m "Do you want to trim the video?"
if %errorlevel% == 1 (
    set trimmed=y
) else (
    set vidtime=262144
    set starttime=0
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
echo Start time %starttime%, Duration "%vidtime%">>"%temp%\qualitymuncherdebuglog.txt"
call :clearlastprompt
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
choice /n
:: if yes, set the variable, if no, skip
if %errorlevel% == 1 (
    set addedtextq=y
) else (
    set addedtextq=n
    call :clearlastprompt
    goto :eof
)
echo                                            [A]dvanced text or [S]imple text?
choice /c AS /n
:: if yes, set the variable, if no, skip
if %errorlevel% == 1 (
    set textmode=a
) else (
    set textmode=s
)
echo                                          How many text boxes do you want to add?
set /p "textamount="
echo "%textamount%" textamount>>"%temp%\qualitymuncherdebuglog.txt"
set textcounter=0
call :clearlastprompt
if %textmode% == a (
    echo doing advanced text>>"%temp%\qualitymuncherdebuglog.txt"
    goto :textloopingadvanced
) else (
    echo doing simple text>>"%temp%\qualitymuncherdebuglog.txt"
    goto :textloopingsimple
)

:textloopingsimple
set /a textcounter+=1
set tsize!textcounter!=1
echo                         What size should text !textcounter! be? [B]ig, [M]edium, [S]mall, or [V]ery small?
choice /c BMSV /n
set tsize!textcounter!=%errorlevel%
if "!tsize%textcounter%!" == "4" set tsize!textcounter!=6
set "text!textcounter!= "
echo                                             Enter your text for text !textcounter! now:
set /p "text!textcounter!="
set "textcolor!textcounter!=white"
call :screenlocation "text !textcounter!" texthpos!textcounter!
call :titledisplay
if not %textcounter% == %textamount% goto textloopingsimple
echo "going done with text">>"%temp%\qualitymuncherdebuglog.txt"
goto :eof

:textloopingadvanced
set /a textcounter+=1
set tsize!textcounter!=1
echo                         What size should text !textcounter! be? [B]ig, [M]edium, [S]mall, or [V]ery small?
choice /c BMSV /n
set tsize!textcounter!=%errorlevel%
if "!tsize%textcounter%!" == "4" set tsize!textcounter!=6
set "text!textcounter!= "
echo                                             Enter your text for text !textcounter! now:
set /p "text!textcounter!="
echo                                              What color should the text be?
echo   This can be in one of two formats, either the name (like White or Brown), or the hexadecmial value with 0x in front
echo                                                (like 0xFFFFFF or 0x964B00)
set /p "textcolor!textcounter!="
echo     From 0 to 100, where should the text be placed horizontally? (0 is the furthest left, 100 is the furthest right)
set /p "texthposh="
echo        From 0 to 100, where should the text be placed vertically? (0 is the furthest up, 100 is the furthest down)
set /p "texthposv="
set texthpos!textcounter!=x=(w-(tw))*(%texthposh%/100):y=(h-(th))*(%texthposv%/100)
call :titledisplay
if not %textcounter% == %textamount% goto textloopingadvanced
echo "going done with text">>"%temp%\qualitymuncherdebuglog.txt"
goto :eof

:: prompts the user of where to place an item
:: first parameter - item to be asked about
:: second parameter - variable to set the position to
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
    set "colorfilter="
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

:: asks about the video's aspect ratio
:stretch
call :clearlastprompt
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

:: asks the user if they want to spoof the video duration
:durationspoof
echo                                      Do you want to spoof the duration of the video?
echo                    [91mWarning^^! This is an EXTREMELY expiramental feature and might not work as intended^^![0m
if %corrupt% == y echo                    [91mThis setting may cause issues when used with corruption (which you have enabled).[0m
choice /n
if %errorlevel% == 1 (
    set spoofduration=y
) else (
    set spoofduration=n
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

:: miscellaneous filters that are too small to be their own options
:: all of the "toggletc(x)" labels are a part of this, used to toggle the colors
:filterlist
echo                                                          [38;2;254;165;0m[B]ack[0m
echo.
:filterlistloop
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
    echo Misc. Filters selected: %filtercl% - blank means none>>"%temp%\qualitymuncherdebuglog.txt"
    call :titledisplay
    goto :eof
)
call :toggletcl%errorlevel%
echo [10A
goto :filterlistloop

:: what all of the toglectl(x) functions do is:
:: - if the option was previously set to disabled, enable it and add the filter to the filters, highlight the selection, then exit the function
:: - if the option was previously set to enabled, disable it and remove the filter from the filters, remove the highlight, and exit the function

:toggletcl1
    if "%tcl1%2" == "[92m2" (
        set "tcl1= "
        set "filtercl=%filtercl:,erosion=%"
        goto :eof
    )
    set "filtercl=%filtercl%,erosion"
    set "tcl1=[92m"
goto :eof

:toggletcl2
    if "%tcl2%2" == "[92m2" (
        set "tcl2= "
        set "filtercl=%filtercl:,lagfun=%"
        goto :eof
    )
    set "filtercl=%filtercl%,lagfun"
    set "tcl2=[92m"
goto :eof

:toggletcl3
    if "%tcl3%2" == "[92m2" (
        set "tcl3= "
        set "filtercl=%filtercl:,negate=%"
        goto :eof
    )
    set "filtercl=%filtercl%,negate"
    set "tcl3=[92m"
goto :eof

:toggletcl4
    if "%tcl4%2" == "[92m2" (
        set "tcl4= "
        set "filtercl=%filtercl:,interlace=%"
        goto :eof
    )
    set "filtercl=%filtercl%,interlace"
    set "tcl4=[92m"
goto :eof

:toggletcl5
    if "%tcl5%2" == "[92m2" (
        set "tcl5= "
        set "filtercl=%filtercl:,edgedetect=%"
        goto :eof
    )
    set "filtercl=%filtercl%,edgedetect"
    set "tcl5=[92m"
goto :eof

:toggletcl6
    if "%tcl6%2" == "[92m2" (
        set "tcl6= "
        set "filtercl=%filtercl:,shufflepixels=%"
        goto :eof
    )
    set "filtercl=%filtercl%,shufflepixels"
    set "tcl6=[92m"
goto :eof

:toggletcl7
    if "%tcl7%2" == "[92m2" (
        set "tcl7= "
        set "filtercl=%filtercl:,guided=%"
        goto :eof
    )
    set "filtercl=%filtercl%,guided"
    set "tcl7=[92m"
goto :eof

:: visual noise question
:visualnoise
echo                                             Do you want to add visual noise?
choice /n
if %errorlevel% == 1 set visualnoise=y
if %errorlevel% == 2 (
    set "visualnoisefilter="
    set visualnoise=n
    goto :eof
)
set visualnoiselevel=20
echo                        How much visual noise do you want to add? 1 is the least, 100 is the most.
set /p "visualnoiselevel="
set "visualnoisefilter=,noise=alls=%visualnoiselevel%:allf=t"
goto :eof

:: constant quantizer question
:constantquantizer
echo                                    Do you want to set a constant quantization level?
choice /n
if %errorlevel% == 1 set constantquantizer=y
if %errorlevel% == 2 (
    set "constantquantizerfilter="
    set constantquantizer=n
    goto :eof
)
set constantquantizerlevel=40
echo                       What CQP level do you want to use? 1 is the highest quality, 63 is the worst.
set /p "constantquantizerlevel="
set "constantquantizerfilter=-qp %constantquantizerlevel% "

goto :eof

:: vignette questions
:vignette
echo                                              Do you want to add a vignette?
choice /n
if %errorlevel% == 1 set vignette=y
if %errorlevel% == 2 (
    set "vignettefilter="
    set vignette=n
    goto :eof
)
echo                     How strong do you want the vignette to be? 1 is the weakest, 10 is the strongest.
set /p "vignettelevel="
set "vignettefilter=,vignette=PI/(5/(%vignettelevel%/2))"
goto :eof

:: zoom questions
:zoom
echo                                                  Do you want to zoom in?
choice /n
if %errorlevel% == 1 set zoom=y
if %errorlevel% == 2 (
    set "zoomfilter="
    set zoom=n
    goto :eof
)
set zoomlevel=1
echo                             How much do you want to zoom in? 1 is the least, 10 is the most.
set /p "zoomlevel="
set "zoomfilter=,zoompan=zoom=%zoomlevel%"
goto :eof

:: fade in questions
:fadein
echo                                                  Do you want to fade in?
choice /n
if %errorlevel% == 1 set fadein=y
if %errorlevel% == 2 (
    set "fadeinfilter="
    set fadein=n
    goto :eof
)
set fadeinduration=1
echo                                    [93mIn seconds[0m, how long do you want the fade in to be?
set /p "fadeinduration="
set "fadeinfilter=,fade=t=in:d=%fadeinduration%"
goto :eof

:: fade out questions
:fadeout
echo                                                 Do you want to fade out?
choice /n
if %errorlevel% == 1 set fadeout=y
if %errorlevel% == 2 (
    set "fadeoutfilter="
    set fadeout=n
    goto :eof
)
set fadeoutduration=1
echo                                   [93mIn seconds[0m, how long do you want the fade out to be?
set /p "fadeoutduration="
goto :eof

:: ========================================
:: everything needed for video rendering
:: ========================================

:: sends all video files to be encoded
:encodevideomultiq
:: set up a counter for the number of files encoded and the total
set totalfiles=0
for %%x in (%*) do set /a totalfiles+=1
if %hasbatch% == y set /a totalfiles-=1
set filenum=1
set filenumold=0
set indexoffilebeingencoded=0
:: for each file in the parameters, encode it, set the title to the current file number and total, and echo the file being rendered
for %%a in (%*) do (
    set /a indexoffilebeingencoded+=1
    if not !indexoffilebeingencoded! == %numthathasbatch% (
        set "filename="
        if %clearaftereachrender% == y (echo [10;1H)
        set videoinp=%%a
        title [!filenum!/%totalfiles%] Quality Muncher v%version%
        echo Encoding video !filenum!/%totalfiles%>>"%temp%\qualitymuncherdebuglog.txt"
        if %ismultiqueue% == y (
            echo.
            set /a progbarcall=!filenum!-1
            call :progressbaranimated !progbarcall! %totalfiles% !filenumold!
            echo "!filenumold! %totalfiles% !filenumold!">>"%temp%\qualitymuncherdebuglog.txt"
            echo [38;2;254;165;0m[!filenum!/%totalfiles%] Encoding "%%~nxa"[0m
            if !filenum! gtr 1 set /a filenumold+=1
            set /a filenum=!filenum!+1
            if %frying% == y (
                if %spoofduration% == y (
                    if %clearaftereachrender% == y call :titledisplay
                )
            )
        ) else (
            call :outputquestion
            echo [2A[0J[38;2;254;165;0mEncoding...[0m
            echo.
        )
        call :videospecificstuff %%a
        if exist "%qmtemp%\scaledandfriedvideotempfix!container!" (del "%qmtemp%\scaledandfriedvideotempfix!container!")
    )
)
title [Done] Quality Muncher v%version%
:end
if %clearaftereachrender% == y (
    if %ismultiqueue% == y (
        echo [10;1H
        echo.[0J
    ) else (
        echo.
    )
) else (
    echo.
)
if %ismultiqueue% == y call :progressbaranimated %totalfiles% %totalfiles% %filenumold%
echo [92mDone^^![0m
set done=y
if exist "%qmtemp%\scaledandfriedvideotempfix%container%" (del "%qmtemp%\scaledandfriedvideotempfix%container%")
:: delete temp files and show ending (unless stayopen is n)
if %stayopen% == n goto ending
goto exiting

:: encodes the video
:: also does a lot of stuff before encoding that needs to be set but has to be run for each video since it relies on things like the input's dimensions
:videospecificstuff
:: get duration
echo input is %1 >>"%temp%\qualitymuncherdebuglog.txt"
set inputvideo="%~1"
ffprobe -i %inputvideo% -show_entries format=duration -v quiet -of csv="p=0" > %qmtemp%\fileduration.txt
set /p duration=<%qmtemp%\fileduration.txt
echo %duration% file duration>>"%temp%\qualitymuncherdebuglog.txt"
:: if fade out is enabled, set duration and video time to integers, then calculate the file duration minus the fade out duration to find the start time for fading out
:: does not factor in speed since speed is applied after the fade out filter
if %fadeout% == y (
    set /a intduration=%duration%
    set /a intvidtime=%vidtime%
    if !intduration! gtr !intvidtime! (
        set /a fadeoutstart=!intvidtime!-%starttime%-%fadeoutduration%
    ) else (
        set /a fadeoutstart=!intduration!-%starttime%-%fadeoutduration%
    )
    echo "!fadeoutstart! is start and !intduration! is the video duration">>"%temp%\qualitymuncherdebuglog.txt"
    set "fadeoutfilter=fade=t=out:d=%fadeoutduration%:st=!fadeoutstart!,"
)
echo fadeout passed>>"%temp%\qualitymuncherdebuglog.txt"
:: make sure the variable is an integer
set /a "duration=%duration%" > nul 2> nul
if exist "%qmtemp%\fileduration.txt" (del "%qmtemp%\fileduration.txt")
echo duration to int passed>>"%temp%\qualitymuncherdebuglog.txt"
:: gets the input framerate, which is used in determining whether to ask about interpolation, frame resampling, or neither
ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -i %inputvideo% -of csv=p=0 > %qmtemp%\fps.txt
set /p inputfps=<%qmtemp%\fps.txt
if exist "%qmtemp%\fps.txt" (del "%qmtemp%\fps.txt")
:: sets the outputfps variable to an integer
set /a inputfps=%inputfps%
:: gets the resolution of the video
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %inputvideo% -of csv=p=0 > %qmtemp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %inputvideo% -of csv=p=0 > %qmtemp%\height.txt
set /p height=<%qmtemp%\height.txt
set /p width=<%qmtemp%\width.txt
if exist "%qmtemp%\height.txt" (del "%qmtemp%\height.txt")
if exist "%qmtemp%\width.txt" (del "%qmtemp%\width.txt")
echo got fps and res from ffprobe>>"%temp%\qualitymuncherdebuglog.txt"
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
echo passed most math>>"%temp%\qualitymuncherdebuglog.txt"
:: video bitrate
set /a badvideobitrate=(%desiredheight%/2*%desiredwidth%*%outputfps%/%videobr%)
if %badvideobitrate% lss 1000 set badvideobitrate=1000
:: actual video filters
set filters=-filter_complex "scale=%desiredwidth%x%desiredheight%:flags=%scalingalg%,setsar=1:1,%textfilter%%fpsfilter%%colorfilter%%fadeoutfilter%%speedfilter%format=yuv410p%stutterfilter%%filtercl%%visualnoisefilter%%vignettefilter%%fadeinfilter%"
:: add the suffix to the output name
if not defined filename set "filename=%~n1 (%endingmsg%)"
:: switch to the current input's directory, if not already in it
set inpath=%~dp1
set inpath=%inpath:~0,-1%
if not "%cd%" == "!inpath!" cd /d !inpath!
:: if the file already exists, append a (1), and if that exists, append a (2) instead, etc
:: this is to avoid duplicate files, conflicts, issues, and whatever else
if exist "%filename%%container%" call :renamefile
:: let the user know encoding is happening
if %ismultiqueue% == y echo.
if %novideo% == y (
    set filters=-vn
    set frying=n
)
set audiofiltersnormal=%audiofilters%
if %noaudio% == y (
    set audiofiltersnormal=-an
)
:: if the user selected to fry the video, encode all of the needed parts
if %frying% == y call :encodefried
:: goto the correct encoding option, based on whether or not audio is being replaced
if %replaceaudio% == n call :encodewithnormalaudio
if %replaceaudio% == y call :encodereplacedaudio
if %hasvideo% == y (
    :: if text to speech, encode the voice and merge outputs
    if %tts% == y call :encodevoice
    :: if duration is spoofed, spoof it
    if %spoofduration% == y call :outputdurationspoof
    :: if output is bouncy, uh... bounce it?
    if %bouncy% == y call :encodebouncy
    :: if the output is corrupted, corrupt it
    if "%corrupt%"=="y" call :corruptoutput
)
:: if the video is supposed to be a GIF, convert it to a GIF
if %outputasgif% == y (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel fatal -stats -i %outputvar% -f gif -an "%filename%.gif" && echo FFmpeg call 4 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 4 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    :: remove the old video and replace it with the gif
    del %outputvar%
    set outputvar="%cd%\%filename%.gif"
)
goto :eof

:: option one, audio is not replaced
:encodewithnormalaudio
:: print the ffmpeg call to the debug file
echo ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% ^
-i %videoinp% %constantquantizerfilter%^
%filters% %audiofiltersnormal% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-shortest -vsync vfr -movflags +use_metadata_tags+faststart ^
 "%filename%%container%">>"%temp%\qualitymuncherdebuglog.txt"
:: actual ffmpeg call
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% -i %videoinp% %constantquantizerfilter%^
%filters% %audiofiltersnormal% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-shortest -vsync vfr -movflags +use_metadata_tags+faststart ^
 "%filename%%container%" ^
 && echo FFmpeg call 1 succeded>>"%temp%\qualitymuncherdebuglog.txt" ^
 || echo FFmpeg call 1 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: set the output var for piping and whatnot
set outputvar="%cd%\%filename%%container%"
goto :eof

:: option two, audio is replaced
:encodereplacedaudio
:: print the ffmpeg call to the debug file
echo ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% ^
-i %videoinp% ^
-ss %musicstarttime% ^
-i %lowqualmusic% %constantquantizerfilter%^
%filters% %audiofiltersnormal% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 ^
-shortest -vsync vfr -movflags +use_metadata_tags+faststart ^
 "%filename%%container%">>"%temp%\qualitymuncherdebuglog.txt"
:: actual ffmpeg call
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats ^
-ss %starttime% -t %vidtime% ^
-i %videoinp% ^
-ss %musicstarttime% ^
-i %lowqualmusic% %constantquantizerfilter%^
%filters% %audiofiltersnormal% ^
-preset %encodingspeed% ^
-c:v libx264 %metadata% -b:v %badvideobitrate% ^
-c:a aac -b:a %badaudiobitrate%000 ^
-map 0:v:0 -map 1:a:0 ^
-shortest -vsync vfr -movflags +use_metadata_tags+faststart ^
 "%filename%%container%" ^
 && echo FFmpeg call 2 succeded>>"%temp%\qualitymuncherdebuglog.txt" ^
 || echo FFmpeg call 2 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: set the output var for piping and whatnot
set outputvar="%cd%\%filename%%container%"
goto :eof

:: spoofs the duration of the video
:outputdurationspoof
:: text to speech doesn't have duration in metadata or something so reencode it
if %tts% == y (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i %outputvar% -c:v libx264 -preset %encodingspeed% -b:v %badvideobitrate% -c:a copy -shortest ^-vsync vfr -movflags +use_metadata_tags+faststart "%filename%2.mp4" && echo FFmpeg call 6 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 6 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    del %outputvar%
    set outputvar="%cd%\%filename%2.mp4"
)
set nextline=n
:: encode the video to hex
certutil -encodehex %outputvar% "%qmtemp%\%filename% hexed.txt"
set theline=n
:: loop through the file's lines until the line containing duration is found and replacde
set linenum=0
for /f "usebackq tokens=*" %%a in ("%qmtemp%\%filename% hexed.txt") do (
    set /a linenum+=1
    set "linecontent=%%~a"
    if !nextline! == y (
        if %durationtype% == superlongnegative (
            set /a "theline=!linenum!+1"
        ) else (
            set /a "theline=!linenum!"
        )
        set /a numofloops+=1
        echo Powershell is working, please wait...
        if %durationtype% == superlong call :thelinesuperlong
        if %durationtype% == superlongnegative call :superlongnegative
        if %durationtype% == increasing call :thelineincreasing
        if !numofloops!1 == 11 set nextline=n
    )
    :: exit the for loop if the line is found and replaced
    if !linenum! gtr !theline! goto enddurationspoofloop
    if not %durationtype% == superlongnegative (
        if !nextline! == y (
            goto enddurationspoofloop
        )
    )
    if not "!linecontent!" == "!linecontent:mvhd=!" set nextline=y
)
:enddurationspoofloop
:: decode the hex back into a video, with the changed duration
certutil -decodehex "%qmtemp%\%filename% hexed.txt" "%filename% hexed.mp4"
del %outputvar%
ren "%filename% hexed.mp4" "%filename%.mp4"
del "%qmtemp%\%filename% hexed.txt"
set outputvar="%cd%\%filename%.mp4"
goto :eof

:: replace the information with super long duration
:thelinesuperlong
:: saving the old line content
set "linecontentog=%linecontent%"
:: replacing the line content with the super long duration
set /a lineloop=4
:loopsuperlongduration
if "!linecontent:~%lineloop%,1!" == " " (
    set "linecontentnew=!linecontent:~0,%lineloop%! 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01"
) else (
    set /a lineloop+=1
    goto loopsuperlongduration
)
:: making sure everything works okay-ish
set linecontentnew=%linecontentnew:00 00 00 00 00 00 00 00 01=00 00 00 00 00 00 00 01%
:: calling powershell to replace the line content
powershell -Command "(Get-Content '%qmtemp%\%filename% hexed.txt') -replace '%linecontentog%', '%linecontentnew%' | Out-File -encoding ASCII '%qmtemp%\myFile.txt'"
:: deleting the old file and renaming the new one
del "%qmtemp%\%filename% hexed.txt"
ren "%qmtemp%\myFile.txt" "%filename% hexed.txt"
goto :eof

:: replace the information with super long duration
:superlongnegative
:: saving the old line content
set "linecontentog=%linecontent%"
:: only use the parts with hex code because the rest had weird characters and caused issues
set linecontentog=%linecontentog:~0,55%
:: skip the first part if it's the second line
if %numofloops% == 2 goto secondlinething
:loopsuperlongnegativeduration
if "!linecontent:~%lineloop%,1!" == " " (
    set "linecontentnew=!linecontent:~0,%lineloop%! 00 00 00 00 00 00 00 01  00 00 00 00 00 00 00 01"
) else (
    set /a lineloop+=1
    goto loopsuperlongnegativeduration
)
:: skip the second part if it's the first line
goto :endsecondlinething
:secondlinething
set /a lineloop=4
:loopsuperlongnegativedurationtwo
if "!linecontent:~%lineloop%,1!" == " " (
    set "linecontentnew=!linecontent:~0,%lineloop%! FF 67 69 81 00 00 00 01  00 00 00 00 00 00 00 01"
) else (
    set /a lineloop+=1
    goto loopsuperlongnegativedurationtwo
)
:endsecondlinething
:: making sure everything works okay-ish (for some reason it kept an extra hex at the start of the line sometimes)
set linecontentnew=%linecontentnew:00 00 00 00 00 00 00 00 01=00 00 00 00 00 00 00 01%
set linecontentnew=%linecontentnew:00 FF 67 69 81 00 00 00 01=FF 67 69 81 00 00 00 01%
:: calling powershell to replace the line content
powershell -Command "(Get-Content '%qmtemp%\%filename% hexed.txt') -replace '%linecontentog%', '%linecontentnew%' | Out-File -encoding ASCII '%qmtemp%\myFile.txt'"
:: deleting the old file and renaming the new one
del "%qmtemp%\%filename% hexed.txt"
ren "%qmtemp%\myFile.txt" "%filename% hexed.txt"
if %numofloops% == 2 echo [93mWhile this video might crash some video players, it will embed perfectly fine in discord.[0m
goto :eof

:: replace the information with increasing duration
:thelineincreasing
:: saving the old line content
set "linecontentog=%linecontent%"
:: replacing the line content with the increasing duration
set /a lineloop=4
:loopincreasingduration
if "!linecontent:~%lineloop%,1!" == " " (
    set "linecontentnew=!linecontent:~0,%lineloop%! 00 00 00 00 00 00 ff ff  00 00 00 00 00 00 ff ff"
) else (
    set /a lineloop+=1
    goto loopincreasingduration
)
:: making sure everything works okay-ish
set linecontentnew=%linecontentnew:00 00 00 00 00 00 00 ff ff=00 00 00 00 00 00 ff ff%
:: calling powershell to replace the line content
powershell -Command "(Get-Content '%qmtemp%\%filename% hexed.txt') -replace '%linecontentog%', '%linecontentnew%' | Out-File -encoding ASCII '%qmtemp%\myFile.txt'"
:: deleting the old file and renaming the new one
del "%qmtemp%\%filename% hexed.txt"
ren "%qmtemp%\myFile.txt" "%filename% hexed.txt"
goto :eof

:: encoding bouncy webm
:encodebouncy
:: remencode to webm so the codecs can be copied
ffmpeg -hide_banner -stats_period 0.05 -loglevel warning -stats -i %outputvar% -c:a libopus -b:a %badaudiobitrate%k -c:v libvpx "%qmtemp%\%filename% webmifed.webm" && echo FFmpeg call 7 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 7 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: get the frame count so we know how many times to loop
ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -i "%qmtemp%\%filename% webmifed.webm" -of csv=p=0 > "%qmtemp%\framecount.txt"
set /p framecount=<"%qmtemp%\framecount.txt"
set /a framecount=%framecount%
del "%qmtemp%\framecount.txt"
:: remove old temporary frames folder just in case
rmdir "%qmtemp%\qmframes" /s /q > nul 2> nul
:: make the directory for the frames
mkdir "%qmtemp%\qmframes"
:: looping through all of the frames
echo Encoding WebM Frame 0 of %framecount%
:loopframes
set /a "loopcount+=1"
echo [1A[2KEncoding WebM Frame %loopcount% of %framecount%
set /a "frametograb=%loopcount%-1"
if %bouncetype% == width (
    ffmpeg -hide_banner -loglevel error -vsync drop -i "%qmtemp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2)):%desiredheight%" -an "%qmtemp%\qmframes\framenum%loopcount%.webm" && echo FFmpeg call 8 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 8 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
) else (
    if %bouncetype% == height (
    ffmpeg -hide_banner -loglevel error -vsync drop -i "%qmtemp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%x%desiredheight%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2))" -an "%qmtemp%\qmframes\framenum%loopcount%.webm" && echo FFmpeg call 9 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 9 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    ) else (
        ffmpeg -hide_banner -loglevel error -vsync drop -i "%qmtemp%\%filename% webmifed.webm" -vf "select=eq(n\,%frametograb%),scale=%desiredwidth%*(((cos(%loopcount%*(%incrementbounce%/10)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2)):%desiredheight%*(((cos(%loopcount%*(%incrementbounce%/12)))/2)*((1/%minimumbounce%-1)/(1/%minimumbounce%))+((1+%minimumbounce%)/2))" -an "%qmtemp%\qmframes\framenum%loopcount%.webm" && echo FFmpeg call 10 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 10 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    )
)
echo file '%qmtemp%\qmframes\framenum%loopcount%.webm' >> "%qmtemp%\qmframes\filelist.txt"
if %loopcount% lss %framecount% goto loopframes
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel warning -stats -f concat -safe 0 -i %qmtemp%\qmframes\filelist.txt -i "%qmtemp%\%filename% webmifed.webm" -map 1:a -map 0:v -c copy "%filename%.webm" && echo FFmpeg call 11 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 11 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
del "%qmtemp%\%filename% webmifed.webm"
set container=.webm
del %outputvar%
set outputvar="%cd%\%filename%.webm"
:: delete the file used for temp frames
rmdir "%qmtemp%\qmframes" /s /q
goto :eof

:: set the stretched width/height
:stretchmath
:: in the words of the great vladaad, "fucking batch doesn't know what a float is"
set /a "widthmod=(%desiredwidth%*%widthratio%) %% %heightratio%"
set /a "desiredwidth=((%desiredwidth%*%widthratio%)+%widthmod%)/%heightratio%"
set /a desiredwidth=(%desiredwidth%/2)*2
goto :eof

:: combines text to speech with output since the main encoders don't factor in text to speech
:encodevoice
set "audiofilterstts="
:: if no audio filters already exist, set them to -af (which is the audio filter flag)
if not "%audiofilters%e" == "e" set "audiofilterstts=,%audiofilters:-af =%"
:: makes sure that the file doesn't already exist
set "ttsuffix= tts"
:ttexist
set /a "q+=1"
if exist "%cd%\%filename% %ttsuffix%%container%" (
    set "ttsuffix= tts (%q%)"
    goto ttexist
)
:: encode and merge to output
echo Encoding and merging text-to-speech...
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i anullsrc -filter_complex "flite=text='%ttstext%':voice=kal16%audiofilterstts%,volume=%volume%dB"  -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%container%" -movflags +use_metadata_tags -map_metadata 1 -c:v copy -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename%%ttsuffix%%container%" && echo FFmpeg call 12 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 12 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: delete the old file and update the name
if exist "%filename%%container%" (del "%filename%%container%")
set outputvar="%cd%\%filename%%ttsuffix%%container%"
set "filename=%filename%%ttsuffix%"
goto :eof

:: does the math for the text that is dependant on video-specific variables such as resolution
:textmath
set textmathcounter=0
:textloopingmath
set /a textmathcounter+=1
echo "Doing text %textmathcounter% math">>"%temp%\qualitymuncherdebuglog.txt"
:: remove spaces and count the characters in the text
set text!textmathcounter!nospace=!text%textmathcounter%: =_!
echo "1">>"%temp%\qualitymuncherdebuglog.txt"
echo "!text%textmathcounter%nospace!" > %qmtemp%\text!textmathcounter!.txt
echo "2" %qmtemp%\text!textmathcounter!.txt>>"%temp%\qualitymuncherdebuglog.txt"
for %%? in (%qmtemp%\text!textmathcounter!.txt) do ( set /a strlength=%%~z? - 2 )
echo "3">>"%temp%\qualitymuncherdebuglog.txt"
if exist "%qmtemp%\text!textmathcounter!.txt" (del "%qmtemp%\text!textmathcounter!.txt")
echo "4">>"%temp%\qualitymuncherdebuglog.txt"
:: if below 16 characters, set it to 16 (essentially caps the font size)
echo %strlength% text !textmathcounter! a>>"%temp%\qualitymuncherdebuglog.txt"
if %strlength% LSS 16 set strlength=16
echo %strlength% text !textmathcounter! a>>"%temp%\qualitymuncherdebuglog.txt"
echo "5">>"%temp%\qualitymuncherdebuglog.txt"
set /a fontsize!textmathcounter!=(%desiredwidth%/%strlength%)*2
echo !fontsize%textmathcounter%! aaaaaa>>"%temp%\qualitymuncherdebuglog.txt"
echo "6">>"%temp%\qualitymuncherdebuglog.txt"
set /a fontsize!textmathcounter!=(!fontsize%textmathcounter%!)/!tsize%textmathcounter%!
echo fontsize!textmathcounter!=(!fontsize%textmathcounter%!)/!tsize%textmathcounter%! a>>"%temp%\qualitymuncherdebuglog.txt"
echo !fontsize%textmathcounter%! aaaaaa>>"%temp%\qualitymuncherdebuglog.txt"
echo "7">>"%temp%\qualitymuncherdebuglog.txt"
:fontcheck
set /a triplefontsize!textmathcounter!=!fontsize%textmathcounter%!*3
if !triplefontsize%textmathcounter%! gtr %desiredheight% (
    set /a fontsize!textmathcounter!=!fontsize%textmathcounter%!-5
    goto fontcheck
)
echo "8">>"%temp%\qualitymuncherdebuglog.txt"
set "textfilter=%textfilter%drawtext=borderw=(!fontsize%textmathcounter%!/12):fontfile=C\\:/Windows/Fonts/impact.ttf:text='!text%textmathcounter%!':fontcolor=!textcolor%textmathcounter%!:fontsize=!fontsize%textmathcounter%!:!texthpos%textmathcounter%!,"
echo %textfilter% AAAAAAAA>>"%temp%\qualitymuncherdebuglog.txt"
echo fontsize=!fontsize%textmathcounter%!:!texthpos%textmathcounter%! AAAAAAAAAAAA>>"%temp%\qualitymuncherdebuglog.txt"
echo "9">>"%temp%\qualitymuncherdebuglog.txt"
if not %textmathcounter% == %textamount% goto textloopingmath
echo done doing text math>>"%temp%\qualitymuncherdebuglog.txt"
goto :eof

:: asks if the user wants a custom output name
:outputquestion
echo                                           Would you like a custom output name?
choice
if %errorlevel% == 2 (
    call :clearlastprompt
    goto :eof
)
echo                                         Enter your output name [93mwith no extension[0m:
set /p "filenametemp="
set "filename=%filenametemp%"
call :clearlastprompt
goto :eof

:: determine if you should interpolate (input fps less than output fps), resample (input fps greater than output fps), or do nothing (input fps equal to output fps)
:resamplemath
:: do nothing if the input fps is equal to the output fps
if %outputfps% == %inputfps% goto :eof
:: interpolate if output fps is greater than input fps
if %outputfps% gtr %inputfps% (
    set "fpsfilter=minterpolate=fps=%outputfps%,"
    echo Interpolating>>"%temp%\qualitymuncherdebuglog.txt"
    echo !fpsfilter!>>"%temp%\qualitymuncherdebuglog.txt"
    goto :eof
)
echo Resampling>>"%temp%\qualitymuncherdebuglog.txt"
echo %fpsfilter%>>"%temp%\qualitymuncherdebuglog.txt"
:: resample if output fps is greater than input fps
:: determines the number of frames to blend together per frame (does not use decimals/floats because batch is like that)
set tmixframes=(%inputfps%/%outputfps%)
set /a tmixcheck=%tmixframes%
:: tmix breaks at >128 frames, so make sure it doesn't go above that
if %tmixcheck% gtr 128 set tmixframes=128
set "fpsfilter=tmix=frames=!tmixframes!:weights=1,fps=%outputfps%,"
goto :eof

:: video-specific math for frying
:fryingmath
:: sets the amount to shift the video back by, fixing some unwanted effects of displacement)
set /a shiftv=%desiredheight%/4
set /a shifth=%desiredwidth%/24
if %shifth% gtr 255 set shifth=255
if %shiftv% gtr 255 set shiftv=255
set shiftv=-%shiftv%
set shifth=-%shifth%
set /a duration=((%duration%/%speedq%)+5)
:: uses a smaller map for distortion (1/10 the size of the output video)
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
echo ffmpeg -hide_banner -stats_period %updatespeed% -loglevel fatal -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=%duration%:r=%outputfps% -vf "noise=allf=t:alls=%level%*10:all_seed=%random%,eq=contrast=%level%*2" -f avi>>"%temp%\qualitymuncherdebuglog.txt"
echo ffmpeg -hide_banner -stats_period %updatespeed% -loglevel fatal -stats -i pipe: -i %videoinp% -filter_complex "[0]scale=%desiredwidth%x%desiredheight%:flags=%scalingalg%[noise],[1]fps=%outputfps%[vid],[vid]scale=%desiredwidth%x%desiredheight%:flags=%scalingalg%[vidscale],[noise]split[noise1][noise2],[vidscale][noise1][noise2]displace=edge=wrap[a],[a]fps=%outputfps%[c],[c]eq=saturation=(%levelcolor%+24)/25:contrast=%levelcolor%[e],[e]noise=alls=%level%[f],[f]rgbashift=rh=%shifth%:rv=%shiftv%:bh=%shifth%:bv=%shiftv%:gh=%shifth%:gv=%shiftv%:ah=%shifth%:av=%shiftv%:edge=wrap" -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -c:a aac -b:a %badaudiobitrate%k "%qmtemp%\scaledandfriedvideotempfix%container%">>"%temp%\qualitymuncherdebuglog.txt"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel fatal -stats -f lavfi -i color=c=black:s=%smallwidth%x%smallheight%:d=%duration%:r=%outputfps% -filter_complex "noise=allf=t:alls=%level%*10:all_seed=%random%,eq=contrast=%level%*2" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel fatal -stats -i pipe: -i %videoinp% -filter_complex "[0]scale=%desiredwidth%x%desiredheight%:flags=%scalingalg%[noise],[1]fps=%outputfps%[vid],[vid]scale=%desiredwidth%x%desiredheight%:flags=%scalingalg%[vidscale],[noise]split[noise1][noise2],[vidscale][noise1][noise2]displace=edge=wrap[a],[a]fps=%outputfps%[c],[c]eq=saturation=(%levelcolor%+24)/25:contrast=%levelcolor%[e],[e]noise=alls=%level%[f],[f]rgbashift=rh=%shifth%:rv=%shiftv%:bh=%shifth%:bv=%shiftv%:gh=%shifth%:gv=%shiftv%:ah=%shifth%:av=%shiftv%:edge=wrap" -preset %encodingspeed% -c:v libx264 -b:v %badvideobitrate%*2 -c:a aac -b:a %badaudiobitrate%k "%qmtemp%\scaledandfriedvideotempfix%container%" && echo FFmpeg call 17 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 17 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
:: use the output of the 5th ffmpeg call as the input for the final encoding
set "videoinp=%qmtemp%\scaledandfriedvideotempfix%container%"
echo Done frying video>>"%temp%\qualitymuncherdebuglog.txt"
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










:: ################################################################################################################################################################
:: ################################################################################################################################################################
:: audio options and audio option functions
:: ################################################################################################################################################################
:: ################################################################################################################################################################

:: display the title for the audio options
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
call :splashtext
echo.[s
goto :eof

:guiaudiooptions
set guiaudiotitleisshowing=y
:guiaudiooptionsrefresh
:: save the config, then make sure any enabled options are green and disabled options are gray
call :autosaveconfig
call :checktogglesaudio
:: display the title if it isn't already showing
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
:: speed questions, but set set hasvideo to false temporarily so it doesn't ask about video speed
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

:: ========================================
:: audio option questions
:: ========================================

:: select a quality for audio
:audioqualityselect
:: resetting the highlighted value
set "dc_sa="
set "bc_sa="
set "tc_sa="
set "uc_sa="
set "cc_sa="
set "rc_sa="
:: highlights the selected value with green
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
    echo                  [93mOn a scale from 1 to 10[0m, how bad should the audio bitrate be? 1 bad, 10 very very bad.
    set /p "audiobr="
) else (
    set audiocustom=n
)
:: decent quality
if %audiocustomizationquestion% == 1 set audiobr=3
:: bad quality
if %audiocustomizationquestion% == 2 set audiobr=5
:: terrible quality
if %audiocustomizationquestion% == 3 set audiobr=8
:: unbearable quality
if %audiocustomizationquestion% == 4 set audiobr=9
:: if custom quality is selected, check if the variables are all whole numbers
:: if they aren't it'll ask again for their values
set /a "testforaudiobr=%audiobr%"
if %audiocustomizationquestion% == c (
    if not "%audiobr%"=="%audiobr: =%" (echo %errormsg% & goto customquestioncheckpoint)
    if not %testforaudiobr% == %audiobr% (echo %errormsg% & goto customquestioncheckpoint)
)
goto :eof

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
    set method=simple
    goto audiodistortionsim
) else (
    set method=advanced
    goto audiodistortionadv
)
goto :eof

:: advanced method - boosts frequencies, swaps channels, adds echo and delay
:audiodistortionadv
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

:: simple method - just boosts frequencies
:audiodistortionsim
set /p "distortionseverity=How distorted should the audio be, [93m1-10[0m: "
set /a distsev=%distortionseverity%*10
set "audiofilters=-af firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
:: if the audio speed isn't one, add it to the audio filters
if not %audiospeedq% == 1 (
    set "audiofilters=-af atempo=%audiospeedq%,firequalizer=gain_entry='entry(0,%distsev%);entry(600,%distsev%);entry(1500,%distsev%);entry(3000,%distsev%);entry(6000,%distsev%);entry(12000,%distsev%);entry(16000,%distsev%)'"
)
call :clearlastprompt
goto :eof

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
ffmpeg > nul 2>>"%qmtemp%\ffmpegQM.txt"
> nul find "libflite" "%qmtemp%\ffmpegQM.txt" || (
    echo USER DOES NOT HAVE FLITE INSTALLED>>"%temp%\qualitymuncherdebuglog.txt"
    del "%qmtemp%\ffmpegQM.txt"
    echo [91mError^^! Your installation of FFmpeg does not have libflite ^(the text to speech library^)^^![0m
    set tts=n
    pause
    call :clearlastprompt
    goto :eof
)
del "%qmtemp%\ffmpegQM.txt"
:: text to speech text and volume
echo What do you want the text-to-speech to say?
set /p "ttstext="
set volume=0
set /p "volume=How much should the volume of the text-to-speech be boosted by (in dB)? Default is 0: "
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

:: ========================================
:: everything needed for audio encoding
:: ========================================

:: sending each audio only input to be encoded
:encodeaudiomultiqueue
set totalfiles=0
:: gets the total num of files
for %%x in (%*) do set /a totalfiles+=1
if %hasbatch% == y set /a totalfiles-=1
set filenum=1
set filenumold=0
set indexoffilebeingencoded=0
:: runs for each file, counting which file number it is and calling the progress bar, setting the file name, changing the title, and calling the encoding label
for %%a in (%*) do (
    set /a indexoffilebeingencoded+=1
    if not !indexoffilebeingencoded! == %numthathasbatch% (
        set "filename="
        :: if the option is set to clear after each render, clear the last render from the screen
        if %clearaftereachrender% == y (echo [10;1H)
        title [!filenum!/%totalfiles%] Quality Muncher v%version%
        echo Encoding audio !filenum!/%totalfiles%>>"%temp%\qualitymuncherdebuglog.txt"
        :: if using multiqueue (has more than one input file), use a progress bar and actually do the math for the file index number
        :: otherwise just say "encoding" with some color
        if %ismultiqueue% == y (
            echo.
            set /a progbarcall=!filenum!-1
            call :progressbaranimated !progbarcall! %totalfiles% !filenumold!
            echo [38;2;254;165;0m[!filenum!/%totalfiles%] Encoding "%%~nxa"[0m
            if !filenum! gtr 1 set /a filenumold+=1
            set /a filenum=!filenum!+1
        ) else (
            echo [38;2;254;165;0mEncoding...[0m
        )
        :: if the current file index doesn't match the index of the batch file (if it exists) then call the encoding label with the file as input
        if not !indexoffilebeingencoded! == %numthathasbatch% call :audiospecificstuff %%a
    )
)
title [Done] Quality Muncher v%version%
if %clearaftereachrender% == y (echo [10;1H)
echo. [0J
if %ismultiqueue% == y call :progressbar %totalfiles% %totalfiles%
echo [92mDone^^![0m
set done=y
if %stayopen% == n goto ending
goto exiting

:: encoding audio only outputs
:audiospecificstuff
:: if the user didn't specify a custom filename, set it now
if not defined filename set "filename=%~n1 (%endingmsg%)"
:: switch to the current input's directory, if not already in it
set inpath=%~dp1
set inpath=%inpath:~0,-1%
if not "%cd%" == "!inpath!" cd /d !inpath!
if exist "%filename%%audiocontainer%" call :renamefile
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
:: if there are custom audio options, set them to a custom variable and apply it to the text to speech
set "audiofilterstts="
if not "%audiofilters%e" == "e" set "audiofilterstts=,%audiofilters:-af =%"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -f lavfi -i anullsrc -filter_complex "flite=text='%ttstext%':voice=kal16%audiofilterstts%,volume=%volume%dB" -f avi pipe: | ^
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -stats -i pipe: -i "%filename%%audiocontainer%" -movflags +use_metadata_tags -map_metadata 1 -filter_complex apad,amerge=inputs=2 -ac 1 -b:a %badaudiobitrate%000 "%filename% tts%audiocontainer%" && echo FFmpeg call 14 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 14 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
if exist "%filename%%audiocontainer%" (del "%filename%%audiocontainer%")
set outputvar="%cd%\%filename% tts%audiocontainer%"
goto :eof










:: ################################################################################################################################################################
:: ################################################################################################################################################################
:: extra menu and extra menu functions
:: ################################################################################################################################################################
:: ################################################################################################################################################################

:: display the title for the extra options
:titledisplayextra
cls
if "%showtitle%" == "n" (
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
call :splashtext
echo.[s
goto :eof

:guiextra
set guiextratitleisshowing=y
:guiextrarefresh
:: save the config, then make sure any enabled options are green and disabled options are gray
call :autosaveconfig
call :checktogglesaudio
:: display the title if it isn't already showing
if "%guiextratitleisshowing%" == "y" (
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
echo                                                      [I]nformation
echo.
echo.
choice /n /c BWARDUSI
echo Extra GUI option is %errorlevel% >>"%temp%\qualitymuncherdebuglog.txt"
set /a gui_extra_var=%errorlevel%
call :clearlastprompt
if %gui_extra_var% == 1 goto guimenu
if %gui_extra_var% == 2 call :website
if %gui_extra_var% == 3 call :announcement
if %gui_extra_var% == 4 call :bugreport
if %gui_extra_var% == 5 call :discord
if %gui_extra_var% == 6 set "forceupdate=y"&call :updatecheck
if %gui_extra_var% == 7 call :suggestion
if %gui_extra_var% == 8 call :information
goto guiextrarefresh

:: displays information about qm
:information
echo Quality Muncher is an open-source batch script developed with the purpose of making advanced low-quality videos, audios,
echo images, and GIFs easier to produce. Quality Muncher is developed by Frost, with the help of Atzur.
echo.
pause
goto :eof

:: if the website is selected from the menu, it sends the user to the website, clears the console, and goes back to start
:website
echo [96mSending to website^^![0m
start "" https://qualitymuncher.lgbt/
call :clearlastprompt
goto :eof

:: provides the user a list of recent announcements from the devs
:announcement
:: checks if github is able to be accessed
call :loadinganimation
ping /n 1 github.com  | find "Reply" > nul
if %errorlevel% == 1 goto fetchannouncementfail
set internet=y
call :loadinganimation
:: grabs the announcements from github
call :loadinganimation
curl -s "https://raw.githubusercontent.com/qm-org/qualitymuncher/main/announce.txt" --output %qmtemp%\anouncementQM.txt || (
    call :clearlastprompt
    echo [91mecho Downloading the announcements failed^^! Please try again later.[0m
    echo Press any key to go to the menu
    pause > nul
    goto :eof
)
call :clearlastprompt
set /p announce=<%qmtemp%\anouncementQM.txt
echo [38;2;255;190;0mAnnouncements:[0m
:: echo each announcement
for /f "tokens=*" %%s in (%qmtemp%\anouncementQM.txt) do (
    set /a "g+=1"
    echo [38;2;90;90;90m[!g!][0m %%s
)
if exist "%qmtemp%\anouncementQM.txt" del "%qmtemp%\anouncementQM.txt"
echo.
pause
goto :eof

:: fails to access github
:fetchannouncementfail
call :clearlastprompt
set internet=n
echo Failed to fetch announcements>>"%temp%\qualitymuncherdebuglog.txt"
echo [91mAnnouncements were not able to be accessed. Either you are not connected to the internet or GitHub is offline.[0m
pause
echo [H[u[0J
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
:: repeats the bug for the user to verify
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
:: please do not abuse this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New bug report^^!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/we^bhooks/100%wbh17%557%mathvar4%400%wb9%2094%wb6%4/an%wb11%Px9R%wbh4%4tV%wb19%
call :clearlastprompt
echo [92mYour bug report has been successfully sent to the developers^^![0m
echo.
pause
call :clearlastprompt
goto :eof

:: if discord is selected from the menu, it sends the user to discord, clears the console, and goes back to start
:discord
echo [96mSending to Discord^^![0m
start "" https://discord.com/invite/9tRZ6C7tYz
call :clearlastprompt
goto :eof

:: suggestions
:suggestion
set /p "mainsuggestion=What's your suggestion? "
set /p "suggestionbody=If needed, please elaborate further here: "
set "author=NO INPUT FOR AUTHOR"
set /p "author=What is your name on discord? [93mThis is optional[0m: "
echo.
call :clearlastprompt
:: repeats the suggestion for the user to verify
echo %author%'s suggestion:
echo %mainsuggestion%
echo %suggestionbody%
echo.
choice /m "Are you sure you would like to submit this suggestion?"
:: cancel if the user doesn't want to send the suggestion
if %errorlevel% == 2 (
    call :clearlastprompt
    echo [91mOkay, your suggestion has been cancelled.[0m
    echo.
    pause
    call :clearlastprompt
    goto :eof
)
:: please do not abuse this webhook it would make me very sad
curl -s --output nul -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"New suggestion^^!\", \"allowed_mentions\": {\"parse\":[]} , \"embeds\": [{\"title\": \"%mainsuggestion%\", \"description\": \"%suggestionbody%\", \"author\": {\"name\": \"%author%\"}}]}" https://discord.com/api/webhooks/100557400%wb9%2094%wb6%4/an%wb11%Px9R%wbh4%4tV%wb19%
call :clearlastprompt
echo [92mYour suggestion has been successfully sent to the developers^^![0m
echo.
pause
call :clearlastprompt
goto :eof










:: ################################################################################################################################################################
:: ################################################################################################################################################################
:: image options and image option functions
:: ################################################################################################################################################################
:: ################################################################################################################################################################

:: display the title for the image options
:titledisplayimage
cls
if "%showtitle%" == "n" (
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
call :splashtext
echo.[s
goto :eof

:guiimageoptions
set guivideotitleisshowing=y
:guiimageoptionsrefresh
:: save the config, then make sure any enabled options are green and disabled options are gray
call :autosaveconfig
call :checktogglesvideo
:: display the title if it isn't already showing
if "%guiimagetitleisshowing%" == "y" (
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

:: ========================================
:: everything needed for image encoding
:: ========================================

:: sends all images and/or GIFs to be encoded
:encodeimagemultiqueue
set originalimagecontainer=%imagecontainer%
:: set a counter for the number of images being encoded
set totalfiles=0
for %%x in (%*) do set /a totalfiles+=1
if %hasbatch% == y set /a totalfiles-=1
set filenum=1
set filenumold=0
set indexoffilebeingencoded=0
:: for each file in the parameters, encode it, set the title to the current file number and total, and echo the file being rendered
for %%a in (%*) do (
    set /a indexoffilebeingencoded+=1
    if not !indexoffilebeingencoded! == %numthathasbatch% (
        set "filename="
        if "%clearaftereachrender%" == "y" echo [10;1H
        title [!filenum!/%totalfiles%] Quality Muncher v%version%
        echo Encoding image !filenum!/%totalfiles%>>"%temp%\qualitymuncherdebuglog.txt"
        if "%ismultiqueue%" == "y" (
            echo.
            set /a progbarcall=!filenum!-1
            call :progressbaranimated !progbarcall! %totalfiles% !filenumold!
            echo "!filenumold! %totalfiles% !filenumold!">>"%temp%\qualitymuncherdebuglog.txt"
            echo [38;2;254;165;0m[!filenum!/%totalfiles%] Encoding "%%~nxa"[0m
            echo.
            if !filenum! gtr 1 set /a filenumold+=1
            set /a filenum=!filenum!+1
        ) else (
            echo [38;2;254;165;0mEncoding...[0m
            echo.
        )
        if not !indexoffilebeingencoded! == %numthathasbatch% call :imagespecificstuff %%a %loopn% %qvnew% %imagesc%
    )
)
title [Done] Quality Muncher v%version%
if "%clearaftereachrender%" == "y" (echo [10;1H)
echo.[0J
if "%ismultiqueue%" == "y" call :progressbar %totalfiles% %totalfiles%
echo [92mDone^^![0m
set done=y
goto exiting

:: encodes images and GIFs
:imagespecificstuff
:: switch to the current input's directory, if not already in it
set inpath=%~dp1
set inpath=%inpath:~0,-1%
if not "%cd%" == "!inpath!" cd /d !inpath!
if "%~x1" == ".gif" (
    set imagecontainer=.gif
) else (
    set imagecontainer=%originalimagecontainer%
)
set loopn=%2
set imagequal=%3
:: imagequal*3 is used for webp/vp9, imagequal is used for -q:v in mjpeg
set /a imagequal3=%imagequal%*3
set /a imagesc=%4
set "tempfolder=%qmtemp%\processingvideo"
if exist "%tempfolder%" (rmdir "%tempfolder%" /q /s)
mkdir "%tempfolder%"
:: grab width and height of the input video
ffprobe -v error -select_streams v:0 -show_entries stream=width -i %1 -of csv=p=0 > %qmtemp%\width.txt
ffprobe -v error -select_streams v:0 -show_entries stream=height -i %1 -of csv=p=0 > %qmtemp%\height.txt
set /p height=<%qmtemp%\height.txt
set /p width=<%qmtemp%\width.txt
if exist "%qmtemp%\height.txt" (del "%qmtemp%\height.txt")
if exist "%qmtemp%\width.txt" (del "%qmtemp%\width.txt")
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
if "%imagecontainer%" == ".gif" (
    set imagecontainer=.mkv
    set webp=webm
    set weblib=libvpx
)
echo Beginning image munch loop>>"%temp%\qualitymuncherdebuglog.txt"
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i %1 -preset ultrafast -vf scale=%width%x%height%:flags=%scalingalg% -c:v mjpeg -q:v %imagequal% -f mjpeg "%tempfolder%\%~n11%imagecontainer%"
set /a loopnreal=%loopn%-1
:: loop through a few encoders until the loop is over
call :progressbar 0 %loopn%
echo 0/%loopn%
set /a i=0
:imagemunchingloop
call :encodeimagelibx264 %1
call :encodeimagemjpeg %1
call :encodeimagewebp %1
if not %i% geq %loopnreal% goto imagemunchingloop
goto imagemunchingloop
set /a i2=%i1%+1
echo [3A[0J
call :progressbar %i% %loopn%
echo %i%/%loopn%
:: add the suffix to the output name
if not defined filename set "filename=%~n1 (%endingmsg%)"
:: skip the loop if the file already doesn't exist
if not exist "%filename%%imagecontainerbackup%" goto afterrenameimage
:: loop until the file doesn't exist
:renamefileimage
set /a "f+=1"
if exist "%filename% (%f%)%imagecontainerbackup%" goto renamefileimage
set "filename=%filename% (%f%)"
:afterrenameimage
:: if it's a gif, encode it as a video then reencode it to a gif
:: otherwisem encode it as a picture
if "%imagecontainerbackup%" == ".gif" (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt rgb24 -c:v libx264 -vf "scale=%width%x%height%:flags=%scalingalg%" -crf %imagequal% -f h264 "%tempfolder%\%~n1%i%final%imagecontainer%" && echo FFmpeg call 18 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 18 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%final%imagecontainer%" -f gif "%filename%%imagecontainerbackup%" && echo FFmpeg call 19 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 19 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
) else (
    ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=%scalingalg% -preset ultrafast -pix_fmt yuv410p -c:v mjpeg -q:v %imagequal% -f mjpeg "%filename%%imagecontainerbackup%" && echo FFmpeg call 20 succeded>>"%temp%\qualitymuncherdebuglog.txt" || echo FFmpeg call 20 failed with an errorlevel of !errorlevel!>>"%temp%\qualitymuncherdebuglog.txt"
)
rmdir "%tempfolder%" /q /s
set outputvar="%filename%%imagecontainerbackup%"
goto :eof

:: encodes images with libx264
:encodeimagelibx264
set /a i+=1
set /a i1=%i%+1
echo [3A[0J
call :progressbar %i% %loopn%
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -preset ultrafast -pix_fmt yuv410p -c:v libx264 -crf %imagequal% -f h264 "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto :eof
del "%tempfolder%\%~n1%i%%imagecontainer%"
goto :eof

:: encodes images with mjpeg
:encodeimagemjpeg
set /a i+=1
set /a i1=%i%+1
echo [3A[0J
call :progressbar %i% %loopn%
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%widthalt%x%heightalt%:flags=%scalingalg% -preset ultrafast -pix_fmt yuv422p -c:v mjpeg -q:v %imagequal% -f mjpeg "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto :eof
del "%tempfolder%\%~n1%i%%imagecontainer%"
goto :eof

:: encodes images with webp
:encodeimagewebp
set /a i+=1
set /a i1=%i%+1
echo [3A[0J
call :progressbar %i% %loopn%
echo %i%/%loopn%
ffmpeg -hide_banner -stats_period %updatespeed% -loglevel error -i "%tempfolder%\%~n1%i%%imagecontainer%" -vf scale=%width%x%height%:flags=%scalingalg% -c:v %weblib% -pix_fmt yuv411p -compression_level 0 -quality %imagequal3% -f %webp% "%tempfolder%\%~n1%i1%%imagecontainer%"
if %i% geq %loopnreal% goto :eof
del "%tempfolder%\%~n1%i%%imagecontainer%"
goto :eof








:: ################################################################################################################################################################
:: ################################################################################################################################################################
:: miscellaneous functions used by multiple parts of the script
:: ################################################################################################################################################################
:: ################################################################################################################################################################

:: simulates an animated progress bar by calling the progress bar function with increasing values until it reaches the desired amount
:: first parameter is the new amount (the amount to reach)
:: second parameter is the total amount (the total amount that CAN be reached)
:: third parameter is the old amount (the amount to start from)
:progressbaranimated
:: set variables using the parameters
set progressbaranimated_newamount=%~1
set progressbaranimated_total=%~2
set progressbaranimated_oldamount=%~3
echo %progressbaranimated_newamount% newamount>>"%temp%\qualitymuncherdebuglog.txt"
echo %progressbaranimated_total% total>>"%temp%\qualitymuncherdebuglog.txt"
echo %progressbaranimated_oldamount% oldamount>>"%temp%\qualitymuncherdebuglog.txt"
:: if anything is less than or equal to 0, set the values to 0 just to be safe, otherwise set them to percents of 100
if %progressbaranimated_oldamount% leq 0 (
    set /a progressbaranimated_oldpercentofhundred=0
) else (
    set /a progressbaranimated_oldpercentofhundred=^(%progressbaranimated_oldamount%*100/%progressbaranimated_total%*100^)/100
)
if %progressbaranimated_newamount% leq 0 (
    set /a progressbaranimated_newpercentofhundred=0
) else (
    set /a progressbaranimated_newpercentofhundred=^(%progressbaranimated_newamount%*100/%progressbaranimated_total%*100^)/100
)
echo %progressbaranimated_oldpercentofhundred% oldpercentofhundred>>"%temp%\qualitymuncherdebuglog.txt"
echo %progressbaranimated_newpercentofhundred% newpercentofhundred>>"%temp%\qualitymuncherdebuglog.txt"
set progressbaranimated_loop=0
:: call the progressbar with the old amount + the animation speed, then with old amount + (the animation speed * 2), then old amount + (the animation speed * 3), etc. until it reaches the new amount
:progressbaranimated_loop
set /a progressbaranimated_loop+=1
set /a progressbaranimated_oldpercentofhundred+=%progressbaranimated_speed%
if %progressbaranimated_oldpercentofhundred% gtr %progressbaranimated_newpercentofhundred% set /a progressbaranimated_oldpercentofhundred=%progressbaranimated_newpercentofhundred%
:: overwrite the old progress bar (if it exists)
if %progressbaranimated_loop% gtr 1 echo [2A
call :progressbar %progressbaranimated_oldpercentofhundred% 100
echo %progressbaranimated_oldpercentofhundred% 100 was call>>"%temp%\qualitymuncherdebuglog.txt"
if %progressbaranimated_oldpercentofhundred% lss %progressbaranimated_newpercentofhundred% goto progressbaranimated_loop
goto :eof

:: progress bar
:: first parameter is amount completed, second is total amount, for example "call :progressbar 5 8" would show 62.5% complete and a progress bar like ##########
:progressbar
if not "%progressbar%" == "y" (
    echo.
    goto :eof
)
:: reset the progress bar, set needed variables
set "progressbar_bar="
set /a progressbar_counter=0
set progressbar_donecharcounter=0
set /a progressbar_amount=%~1
set /a progressbar_total=%~2
:: sets two variables, one relative to the ratio of amount:done and 100, the other as a ratio between amount:done and the size of the progress bar
set /a progressbar_percentofhundred=(%progressbar_amount%*100/%progressbar_total%*100)/100
set /a progressbar_percentofdonechars=(%progressbar_amount%*%progressbar_size%/%progressbar_total%*%progressbar_size%)/%progressbar_size%
:: if they aren't already set, set a two variables, each consisting of the maximum number of done characters of the done character and not yet done character
if "%progressbar_charisdefined%" == "n" call :hashloop
:: set the amount of non-done characters needed to fill the progress bar
set /a progressbar_spaceamount=%progressbar_size%-%progressbar_percentofdonechars%
:: progress bar
set progressbar_bar=!progressbar_donechars:~0,%progressbar_percentofdonechars%!%progressbar_donecharsuffix%!progressbar_notdonechars:~0,%progressbar_spaceamount%![0m
:: find the number of characters that the percentage takes up (with a space on each end)
set "progressbar_charsofpercent=5"
if %progressbar_percentofhundred% lss 10 (
    set "progressbar_charsofpercent=4"
)
if %progressbar_percentofhundred% geq 100 (
    set "progressbar_charsofpercent=6"
)
:: find where to place the percentage by calculating the middle of the progress bar
set /a progressbar_half=(%progressbar_size%-%progressbar_charsofpercent%)/2
:: print the progress bar
echo %progressbar_donecharprefix%%progressbar_bar%[0J
:: print the percentage on top
echo [1A[%progressbar_half%C[0m %progressbar_percentofhundred%%% 
goto :eof

:: find the number of done and non-done characters needed
:hashloop
:: echo running hashloop>>"%temp%\qualitymuncherdebuglog.txt"
if %progressbar_donecharcounter% lss %progressbar_size% (
    set /a progressbar_donecharcounter+=1
    set progressbar_donechars=%progressbar_donechars%%progressbar_donechar%
    set "progressbar_notdonechars=%progressbar_notdonechars%%progressbar_unfinishedchar%"
    goto hashloop
)
set progressbar_charisdefined=y
goto :eof

:: clears the screen up until the title, preventing flashing while keeping the terminal clean
:clearlastprompt
:: move cursor to saved point, then clear any text after the cursor
echo [H[u[0J
goto :eof

:: checks if a file with the same name as the output already exists, if so, appends a (1) to the name, then (2) if that also exists, then (3), etc
:: used to stop ffmpeg from overwriting files
:: used for video and audio
:renamefile
:: start of the repeat until loop (repeats until the file doesn't exist)
:renamefileloop
if "%isimage%" == "y" set container=%imagecontainer%
if "%hasvideo%" == "n" set "container=%audiocontainer%"
set /a "i+=1"
if exist "%filename% (%i%)%container%" goto renamefileloop
set "filename=%filename% (%i%)"
goto :eof

:: automatically saves your current config to a file in temp for retrieval later
:autosaveconfig
call :savetoconfigbypassname temp
goto :eof

:: makes a variable display as either white or green, can be a toggle or implcitly set to on or off
:togglethis
set "temptogglevar=!%1!"
if "%~2" == "on" (
    set "%1=[92m%temptogglevar:[0m=%[0m"
    goto :eof
)
if "%~2" == "off" (
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

:: load a random message from a list of messages
:splashtext
if %displaymessages% == n goto :eof
set /a "quoteindex=%random% * %quotecount% / 32768 + 1"
set /a "quoteindex=%random% * %quotecount% / 32768 + 1"
echo.
echo [38;2;123;169;181m!messages%quoteindex%![0m
echo.
goto :eof

:: little spinning bar animation
:loadinganimation
if %loadingbar% == n goto :eof
set /a loadinganimation_counter+=1
if %loadinganimation_counter% gtr 4 set loadinganimation_counter=1
if %loadinganimation_counter% == 1 echo [14;60H[0J[14;60H\  [15;60H \ [16;60H  \
if %loadinganimation_counter% == 2 echo [14;60H[0J[14;60H ^| [15;60H ^| [16;60H ^| 
if %loadinganimation_counter% == 3 echo [14;60H[0J[14;60H  /[15;60H / [16;60H/  
if %loadinganimation_counter% == 4 echo [14;60H[0J[15;59H-----
goto :eof

:: leaves the script
:ending
if "%animate%" == "y" goto closingbar
endlocal
exit /b