[CmdletBinding()]
param (    
    [Parameter()]$docker_io_user
)
Push-Location $PSScriptRoot

$images = Get-ChildItem . -Directory | Select-Object -exp FullName
$images | ForEach-Object {
    Push-Location $_
    try {
        Copy-Item '../../Dockerfile' '.'
        Copy-Item '../../scripts' -Recurse -Destination '.'

        $name = Split-Path -LeafBase $_
        $version = Get-Content 'version'
        Write-Host -ForegroundColor Cyan "Creating image $($name):$version..."

        $ErrorActionPreference = 'Stop'
        
        docker build . --tag "$name-base" --target base
        docker build . --tag "$name"
        docker tag "$($name):latest" --tag "/$docker_io_user/$($name):$version"

    }
    finally {
        Remove-Item -Recurse './scripts'
        Remove-Item './Dockerfile'
        Pop-Location
    }
}

Pop-Location
