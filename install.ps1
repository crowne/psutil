Write-Output "Installing profile ..."

$profileDir = Split-Path -Path $profile
if ( !( Test-Path $profileDir -PathType Container ) ) {
    Write-Host "Creating $profileDir"
    $dir = mkdir $profileDir
}

Copy-Item .\ps\profile\profile.ps1 "${profileDir}\Microsoft.PowerShell_profile.ps1"
Copy-Item .\ps\profile\profile.ps1 "${profileDir}\Microsoft.VSCode_profile.ps1"

if ( ( Test-Path $Env:POSH_THEMES_PATH -PathType Container ) ) {
    Copy-Item -Force ./ps/oh-my-posh/git-on-up.omp.json $Env:POSH_THEMES_PATH
}

Write-Output "Now please run :>. `$profile"
