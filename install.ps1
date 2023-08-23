[string]$target

function helpinfo
{
    Write-Output "Help:"
    Write-Output "Expected usage:   .\install.ps1 target"
    Write-Output "  target            Required: profile"
    Write-Output ""
}

function installProfile
{
    $profileDir = Split-Path -Path $profile
    Copy-Item .\ps\profile\profile.ps1 "${profileDir}\Microsoft.PowerShell_profile.ps1"
    Copy-Item .\ps\profile\profile.ps1 "${profileDir}\Microsoft.VSCode_profile.ps1"

    # If (Test-Path Alias:ktl) {Remove-Item Alias:ktl}
    # & $profile
    # . $profile
    Write-Output "Next please run :>. `$profile"
}

if ( $($args.Count) -gt 0) {
    $target    = $args[0].ToLower()
}

#Check that the target is not null
if ([string]::IsNullOrEmpty($target)) {
    helpinfo
    throw "target is mandatory"
}

if ($target -eq "profile") {
    installProfile
}
