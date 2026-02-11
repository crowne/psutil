# Introduction 
This project provides a place to store useful powershell scripts.

## Profile
To install the profile run the following commands:
```powershell
> .\install.ps1
```

## OMP Theme
Ensure this env var is set
$Env:POSH_THEMES_PATH = $LOCALAPPDATA\Programs\oh-my-posh\themes\

Then `./ps/oh-my-posh/git-on-up.omp.json` will be copied there.

## Font Notes
See https://ohmyposh.dev/docs/installation/fonts

I've used  FantasqueSansM 
Download the zip, unzip into a directory , select the ttf files and install

[FantasqueSansM](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FantasqueSansMono.zip)

### Windows Terminal font setting
```json
    "profiles": 
    {
        "defaults": {
            "font": 
            {
                "face": "FantasqueSansM Nerd Font"
            }
        },
        // ...
    }

```