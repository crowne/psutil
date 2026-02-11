If (Test-Path Alias:ktl) {Remove-Item Alias:ktl}
New-Alias ktl kubectl

If (Test-Path Alias:np) {Remove-Item Alias:np}
New-Alias np C:\"Program Files"\Notepad++\notepad++.exe

function Is-Command([string]$Command) {
    if (Get-Command $Command -ErrorAction SilentlyContinue)
    {
        return $true
    }
    return $false
}

function printenv() {
    Write-Host "> dir Env:"
    dir Env:
}

function azacr() {
    Write-Host "> az acr login --name myorg.azurecr.io"
    az acr login --name myorg.azurecr.io
}

function NoLock {
    param (
        $minutes = 60 #//Duration. Until 60 mins below script will run
    )

    #The below script will trigger dot key every 60 secs

    $myshell = New-Object -com "Wscript.Shell"

    for ($i = 0; $i -lt $minutes; $i++) {
        Start-Sleep -Seconds 60 #//every 60 secs dot key press
        $myshell.sendkeys("{NUMLOCK}")
    }
}

# Docker helpers
function alpine() {
    Write-Host "> docker run -it --rm alpine"
    Write-Host "> curl can be installed with: apk --update add curl"
    docker run -it --rm alpine
}

function busybox() {
    Write-Host "> docker run -it --rm busybox"
    docker run -it --rm busybox
}

function dosh() {
    param (
        [Parameter(Mandatory=$true)]
        [string] $ImageName
    )

    Write-Host "> docker run -it --rm --entrypoint /bin/sh $ImageName"
    docker run -it --rm --entrypoint /bin/sh $ImageName
}

function dcom() {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Action,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]] $AdditionalArgs
    )

    $allArgs = @($Action) + $AdditionalArgs
    Write-Host "> docker compose $($allArgs -join ' ')"
    docker compose @allArgs
}

function pgrun() {
    Write-Host "> docker run --name pg -e POSTGRES_PASSWORD=Password123 -d -p 5432:5432 postgres"
    docker run --name pg -e POSTGRES_PASSWORD=Password123 -d -p 5432:5432 postgres
}

function pgterm([string]$UserName) {
    Write-Host "> psql --host=localhost --port=32345 --username=$UserName"
    psql --host=localhost --port=32345 --username=$UserName
}

# Git Helpers
function gtags() {
    git tag -n5
}

# Kubernetes helpers
function kctx() {
    param (
        [Parameter(Mandatory=$false)]
        [string] $ContextName
    )

    if ( $PSBoundParameters.ContainsKey('ContextName') ) {
        $ctx = $ContextName
        switch ($ContextName)
        {
            'dd'     {$ctx = "docker-desktop"; Break}
            'dev'    {$ctx = "dev-cluster"; Break}
            'prod'   {$ctx = "prod-cluster"; Break}
        }
        Write-Host "> kubectl config use-context $ctx"
        kubectl config use-context $ctx
    } else {
        Write-Host "> kubectl config get-contexts"
        kubectl config get-contexts
    }
}

function ktns {
    param (
        [Parameter(Mandatory=$false)]
        [string] $NameSpace
    )
    
    if ( $PSBoundParameters.ContainsKey('NameSpace') ) {
        Write-Host "> kubectl config set-context --current --namespace=$NameSpace"
        kubectl config set-context --current --namespace=$NameSpace
    } else {
        Write-Host "> kubectl get ns"
        kubectl get ns
    }
    
}

function ktsh {
    Param(
        [Parameter(Mandatory=$true)]
        [string] $PodName,

        [Parameter()]
        [string] $ContainerName,

        [Parameter()]
        [string] $ContextName
    )

    if ( -not $PSBoundParameters.ContainsKey('PodName') ) {
        Write-Host "PodName parameter is mandatory"
        return
    }
    if ( $PSBoundParameters.ContainsKey('ContextName') ) {
        if ( $PSBoundParameters.ContainsKey('ContainerName') ) {
            Write-Host "> kubectl exec -n $ContextName -c $ContainerName --stdin --tty $PodName -- /bin/sh"
            kubectl exec -n $ContextName -c $ContainerName --stdin --tty $PodName -- /bin/sh
        } else {
            Write-Host "> kubectl exec -n $ContextName --stdin --tty $PodName -- /bin/sh"
            kubectl exec -n $ContextName --stdin --tty $PodName -- /bin/sh
        }
    } else {
        if ( $PSBoundParameters.ContainsKey('ContainerName') ) {
            Write-Host "> kubectl exec -c $ContainerName --stdin --tty $PodName -- /bin/sh"
            kubectl exec -c $ContainerName --stdin --tty $PodName -- /bin/sh
        } else {
            Write-Host "> kubectl exec --stdin --tty $PodName -- /bin/sh"
            kubectl exec --stdin --tty $PodName -- /bin/sh
        }
    }
}

function kpod() {
    Write-Host "Once the shell starts install tools as follows:"
    Write-Host "> apt-get update -y; apt-get install dnsutils curl telnet netcat-traditional net-tools -y;"
    kubectl run -it --rm aks-ssh --image=debian:stable
}

function ktop() {
    param (
        [Parameter(Mandatory=$false)]
        [string] $NodeName
    )

    Write-Host "> kubectl top nodes"
    kubectl top nodes

    $topnode = ( kubectl top nodes --no-headers | echo ) -replace '[ ]{2,}',',' |`
                    ConvertFrom-Csv -Header 'NODENAME','CPU','CPU-pc','MEMORY','MEM-pc' |`
                    Sort MEM-pc -Descending | Select-Object -First 1

    Write-Host "`ntopnode = $($topnode.NODENAME) `n`tCPU = $($topnode.CPU) `n`tMEM = $($topnode.MEMORY) `n`tMEM-pc = $($topnode.'MEM-pc')"

    $node_name = $topnode.NODENAME
    if ( $PSBoundParameters.ContainsKey('NodeName') ) {
        if ( $NodeName -eq 'all' ) {
            $node_name = ".*"
        } else {
            $node_name = $NodeName
        }
    }

    Write-Host "`nSelected node : $($node_name)`n"
    
    (kubectl get pods --all-namespaces --output wide | Select-String "$node_name" | Select-String "running" ) -replace '[ ]{2,}',',' |`
        ConvertFrom-Csv -Header 'NAMESPACE','NAME','READY','STATUS','RESTARTS','AGE','IP','NODE','NOMINATED NODE','READINESS GATES' |`
        ForEach-Object {
            $nm = $_.NAME
            $ns = $_.NAMESPACE
            ( kubectl top pods --namespace $ns $nm --containers --no-headers | echo ) -replace '(.*)(\d*)Mi','${1}${2}  Mi' -replace '[ ]{2,}',','
        } | ConvertFrom-Csv -Header 'Podname','Container','CPU','Memory','MemUnit' | Sort { [int]$_.Memory } -Descending | Format-Table -AutoSize
}

# certificate helpers
function split-certChain([string]$cert_file) {
    $cert_text = Get-Content -Path $cert_file
    $certs_count = ([regex]::Matches($cert_text, "BEGIN CERTIFICATE" )).count

    if ($certs_count -lt 1) {
        Write-Error "No certificates found in file $cert_file"
        return $null
    }

    # Inspired by https://www.powershellgallery.com/packages/Posh-ACME/1.1/Content/Private%5CSplit-CertChain.ps1

    $CERT_BEGIN = '-----BEGIN CERTIFICATE-----*'
    $CERT_END   = '-----END CERTIFICATE-----*'

    $cert_collection = @()
    $cert_lines = @()

    $part_count = 0

    $startCert = $false
    foreach ($line in $cert_text) {

        # skip whitespace
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        # find the first line of the cert
        if (!$startCert) {
            if ($line -like $CERT_BEGIN) {
                Write-Debug "found cert start : $($part_count + 1)"
                $startCert = $true
                $cert_lines = @()
                $cert_lines += $line
            }
            continue
        }

        # write the rest of the lines of the cert and watch for the end
        if ($startCert) {
            $cert_lines += $line
            if ($line -like $CERT_END) {
                Write-Debug "found cert end : $($part_count + 1)"
                $startCert = $false
                $cert_part = $cert_lines -join "`n"
                $cert_collection += $cert_part
                $part_count++
            }
            continue
        }
    }

    return ,$cert_collection
}

function showcert([string]$cert_file, [int]$part_no=1) {
    $DebugPreference = 'SilentlyContinue'
    # $DebugPreference = 'Continue'

    $cert_parts = split-certChain($cert_file)

    if ($null -eq $cert_parts) {
        Write-Host "Invalid cert file"
        return
    }

    Write-Host " Cert Parts in file : $($cert_parts.Length)`n"

    $index = 0
    if ($null -ne $part_no) {
        if ($part_no -gt $cert_parts.Length) {
            Write-Host " requested part_no too high, displaying part 1`n"
        } elseif ($part_no -lt 1) {
            Write-Host " requested part_no too low, displaying part 1`n"
        } else {
            $index = $part_no - 1
        }
    }
    
    Write-Host " Showing Part : $($index + 1)`n"

    $cert_bytes = [System.Text.Encoding]::UTF8.GetBytes($cert_parts[$index])
    Write-Debug "cert_bytes = $cert_bytes"
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($cert_bytes)

    # Write-Host $cert
    $cert | Select-Object Subject, Issuer, SerialNumber, NotBefore, NotAfter, Thumbprint
}

# omp Helpers
function ompTheme([string]$ThemeName) {
    if ( Is-Command("oh-my-posh.exe") )
    {
        $ThemePath = "$env:POSH_THEMES_PATH/$ThemeName.omp.json"
        if ( Test-Path $ThemePath -PathType Leaf )
        {
            Write-Host "> omp setting theme $ThemeName"
            oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/$ThemeName.omp.json" | Invoke-Expression    
        } else {
            Write-Host "> oh-my-posh theme not found"
        }
    } else {
        Write-Host "> oh-my-posh not installed :("
    }
    
}

# vscode devcontainer helpers
function hexify([string]$Text) {
    # from https://github.com/microsoft/vscode-remote-release/issues/2133#issuecomment-737200076
    $t = $Text.ToCharArray() | %{$h=''}{$h += ('{0:x}' -f [int]$_)}{$h}
    return $t
}

function devcon() {
    $hexpath = hexify($pwd)
    code --folder-uri "vscode-remote://dev-container+$hexpath/workspace"
}

if ( Is-Command("oh-my-posh.exe") )
{ 
    Write-Output "Configuring oh-my-posh..."
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    oh-my-posh init pwsh | Invoke-Expression

    if ( $env:OMP_THEME ) {
        ompTheme($env:OMP_THEME)
    } else {
        Write-Host "> No theme set using default, try set env OMP_THEME=git-on-up"
    }
}
