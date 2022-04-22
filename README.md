# Quality Muncher

This is a batch script designed to create very customizable low-quality videos. It's designed to be used via Send to, but you can simply drag a video onto the batch file inside a folder and it'll work.\
Please note that it's still in development, so please message me (Frost#5872) if you have any bugs, issues, questions, or suggestions, or join my discord server: https://discord.gg/9tRZ6C7tYz

# Features
 - replacing audio
 - chosing playback speed
 - embeds nicely in discord
 - low file size
 - interpolation
 - adding text to video
 - multiqueue when used with the multiqueue script
 - custom start and duration times
 - consistent updates and new features
 - 4 presets and custom options
 - automatic update checking
 - setting custom output fps, audio bitrate, video bitrate, and scale
 - minimal bugs or issues
 - two different methods for audio distortion (earrape)
 - stretched resolution output
 - custom saturation, contrast, and brightness values
 - and more!

# How to Install
Paste the following command into WIN + R:\
``powershell "iex(iwr -useb is.gd/qlmunch)"``

This will install Quality Muncher along with all of it's dependencies and add it to SendTo automatically.

# Usage
Right click on your video, hover over "Send to" and select QualityMuncher.bat 

After that, follow the prompts it gives you. If you have any issues or questions, message me on discord or join the server.

Please answer the prompts correctly and read carefully, as answering incorrectly may cause errors or crashes.

If you want specific features of QM without having to go through the entire process, check out https://github.com/Thqrn/batchscripts.

# Multiqueue
The normal Quality Muncher batch file does not support multiqueue. However, with the "!!qualitymuncher multiqueue.bat" file, it does. To use this, select as many videos as you'd like, then send them to the multiqueue file. Then enter in the preset and watch as your videos are processed. For this to work, your both the multiqueue file and quality muncher MUST be in the same directory.

# Automatic Updates
This feature checks for updates by comparing the version of the current file with the version on this GitHub. You can disable it by changing the variable "autoupdatecheck" on line 6 of the script to false.

# Examples

Before: https://youtu.be/CKkuxUq6WQw

After: https://youtu.be/MxctZRHzquE
