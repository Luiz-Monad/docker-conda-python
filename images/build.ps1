[CmdletBinding()]
param (    
    [Parameter()]$docker_io_user
)
Push-Location $PSScriptRoot

$images = Get-ChildItem . -Directory | Select-Object -exp FullName
$images | ForEach-Object {
    Push-Location $_
    try {
        $has_docker = Test-Path './Dockerfile'
        if (-not $has_docker) { Copy-Item '../../Dockerfile' '.' }
        Copy-Item '../../scripts' -Recurse -Destination '.'

        $name = Split-Path -LeafBase $_
        if ($name.Contains('--')) {
            $name = $name.Split('--')[0]
        }
        $version = Get-Content 'version'
        Write-Host -ForegroundColor Cyan "Creating image $($name):$version..."

        $ErrorActionPreference = 'Stop'

        docker build . --tag "$name-base" --target base
        docker build . --tag "$name"
        docker tag "$($name):latest" --tag "/$docker_io_user/$($name):$version"

    }
    finally {
        Remove-Item -Recurse './scripts'
        if (-not $has_docker) { Remove-Item './Dockerfile' }
        Pop-Location
    }
}

Pop-Location
