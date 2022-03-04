Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

# scoop check
if (!(Get-Command scoop -ea ignore)) {
    Write-Host "    Installing Scoop...`r`n" -f yellow
    iex(irm get.scoop.sh)
    Write-Host "Scoop installed successfully!" -f green
}
else {
    Write-Host "Scoop is already installed!" -f green
}

"`r`n"

# git check
if (!(Get-Command git -ea Ignore)) {
    Write-Host "    Installing Git...`r`n" -f yellow
    scoop install git
    cls
    Write-Host "Git installed successfully!" -f green
}

else {
    Write-Host "Git is already installed!" -f green
    scoop update git
}

"`r`n"

# ffmpeg check
if (!(Get-Command ffmpeg -ea Ignore)) {
    Write-Host "    Installing FFmpeg...`r`n" -f yellow
    scoop install ffmpeg
    Write-Host "FFmpeg has been installed successfully!" -f green
}

else {
    Write-Host "FFmpeg is already installed!" -f green
    scoop update ffmpeg
}

"`r`n"

# download QualityMuncher and direct to the SendTo folder
Write-Host "Sending HTTPS request to the QualityMuncher API..." -f yellow
Start-Sleep -Seconds 3 # https requests probably take 3 seconds
irm https://raw.githubusercontent.com/Thqrn/qualitymuncher/main/Quality%20Muncher.bat | out-file "$env:appdata\Microsoft\Windows\SendTo\QualityMuncher.bat" -encoding ascii
Write-Host "Success!" -f green

"`r`n"

# none of this does anything just looks cool
Write-Host "Adding QualityMuncher to SendTo..." -f yellow
Start-Sleep -Seconds 1
Write-Host "Quality Muncher has been succesfully installed and added to SendTo!" -f green

pause
exit