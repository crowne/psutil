# Dracula readline configuration. Requires version 2.0, if you have 1.2 convert to `Set-PSReadlineOption -TokenType`
Set-PSReadlineOption -Color @{
    "Command" = [ConsoleColor]::Green
    "Parameter" = [ConsoleColor]::Gray
    "Operator" = [ConsoleColor]::Magenta
    "Variable" = [ConsoleColor]::White
    "String" = [ConsoleColor]::Yellow
    "Number" = [ConsoleColor]::Blue
    "Type" = [ConsoleColor]::Cyan
    "Comment" = [ConsoleColor]::DarkCyan
}
# Dracula Prompt Configuration
Import-Module posh-git
$GitPromptSettings.DefaultPromptPrefix.Text = "$([char]0x2192) " # arrow unicode symbol
$GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Green
$GitPromptSettings.DefaultPromptPath.ForegroundColor =[ConsoleColor]::Cyan
$GitPromptSettings.DefaultPromptSuffix.Text = "$([char]0x203A) " # chevron unicode symbol
$GitPromptSettings.DefaultPromptSuffix.ForegroundColor = [ConsoleColor]::Magenta
# Dracula Git Status Configuration
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::Blue

If (Test-Path Alias:ktl) {Remove-Item Alias:ktl}
New-Alias ktl kubectl

If (Test-Path Alias:np) {Remove-Item Alias:np}
New-Alias np C:\"Program Files"\Notepad++\notepad++.exe

function printenv()
{
    Write-Host "> dir Env:"
	dir Env:
}

function tags()
{
    git tag -n5
}

function kctx()
{
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

function kctxu([string]$ContextName)
{
    Write-Host "> kubectl config use-context $ContextName"
	kubectl config use-context $ContextName
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

function ktsh
{
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

function ktop() {
    Write-Host "> kubectl top nodes"
    kubectl top nodes

    $topnode = ( kubectl top nodes --no-headers | echo ) -replace '[ ]{2,}',',' |`
                    ConvertFrom-Csv -Header 'NODENAME','CPU','CPU-pc','MEMORY','MEM-pc' |`
                    Sort MEM-pc -Descending | Select-Object -First 1

    Write-Host "`ntopnode = $($topnode.NODENAME) `n`tCPU = $($topnode.CPU) `n`tMEM = $($topnode.MEMORY) `n`tMEM-pc = $($topnode.'MEM-pc')"

    (kubectl get pods --all-namespaces --output wide | Select-String "$($topnode.NODENAME)" ) -replace '[ ]{2,}',',' |`
        ConvertFrom-Csv -Header 'NAMESPACE','NAME','READY','STATUS','RESTARTS','AGE','IP','NODE','NOMINATED NODE','READINESS GATES' |`
        ForEach-Object {
            $nm = $_.NAME
            $ns = $_.NAMESPACE
            ( kubectl top pods --namespace $ns $nm --containers --no-headers | echo ) -replace '(.*)(\d*)Mi','${1}${2}  Mi' -replace '[ ]{2,}',','
        } | ConvertFrom-Csv -Header 'Podname','Container','CPU','Memory','MemUnit' | Sort { [int]$_.Memory } -Descending | Format-Table -AutoSize
}

function azacr()
{
    Write-Host "> az acr login --name myorg.azurecr.io"
	az acr login --name myorg.azurecr.io
}

function busybox()
{
    Write-Host "> docker run -it --rm busybox"
	docker run -it --rm busybox
}

function pgrun()
{
    Write-Host "> docker run --name pg -e POSTGRES_PASSWORD=Password123 -d -p 5432:5432 postgres"
    docker run --name pg -e POSTGRES_PASSWORD=Password123 -d -p 5432:5432 postgres
}

function pgterm([string]$UserName)
{
    Write-Host "> psql --host=localhost --port=32345 --username=$UserName"
    psql --host=localhost --port=32345 --username=$UserName
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
