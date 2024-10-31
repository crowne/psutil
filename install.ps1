Write-Output "Installing profile ..."

$profileDir = Split-Path -Path $profile
if ( !( Test-Path $profileDir -PathType Container ) ) {
    Write-Host "Creating $profileDir"
    $dir = mkdir $profileDir
}

Copy-Item .\ps\profile\profile.ps1 "${profileDir}\Microsoft.PowerShell_profile.ps1"
Copy-Item .\ps\profile\profile.ps1 "${profileDir}\Microsoft.VSCode_profile.ps1"

# If (Test-Path Alias:ktl) {Remove-Item Alias:ktl}
# & $profile
# . $profile
Write-Output "Now please run :>. `$profile"
