# Quality Muncher

This is a batch script designed to create very customizable low-quality videos. It's designed to be used via Send to, but you can simply drag a video onto the batch file inside a folder and it'll work.\
Please note that it's still in development, so please message me (Frost#5872) if you have any bugs, issues, questions, or suggestions, or join my discord server: https://discord.gg/9tRZ6C7tYz

# Features
 - compatible with images, videos, gifs, and audios
 - replacing audio
 - chosing playback speed
 - embeds nicely in discord
 - low file size
 - interpolation
 - adding text to video
 - multiqueue when used with the multiqueue script
 - custom start and duration times
 - active development
 - presets and custom options
 - video frying
 - automatic update checking
 - setting custom output framerate, audio bitrate, video bitrate, scale, and more
 - mostly bug-free
 - two different methods for audio distortion (earrape)
 - stretched resolution output
 - custom saturation, contrast, and brightness values
 - frame blending/resampling (aka motion blur)
 - and more!

# How to Install
Video Guide: https://youtu.be/VBxPHoUQDzo

Paste the following command into WIN + R:\
``powershell "iex(iwr -useb install.qualitymuncher.lgbt)"``

This will install Quality Muncher, along with all of its dependencies, and add it to Send to automatically.

# Usage
Right click on your video, hover over "Send to" and select Quality Muncher. After that, follow the prompts it gives you. If you have any issues or questions, message me on discord or join the server.

Please answer the prompts correctly and read carefully, as answering incorrectly may cause errors or crashes.

# Multiqueue
The normal Quality Muncher batch file does not support multiqueue. However, with the "!!qualitymuncher multiqueue.bat" file, it does. To use this, select as many videos as you'd like, then send them to the multiqueue file. Then enter in the preset and watch as your videos are processed. For this to work, both the multiqueue file and Quality Muncher MUST be in the same directory.

# Automatic Updates
This feature checks for updates by comparing the version of the current file with the version on this GitHub. You can disable it by changing the variable "autoupdatecheck" in the options of the code to false.

# Examples

Before: https://youtu.be/CKkuxUq6WQw

After: https://youtu.be/MxctZRHzquE