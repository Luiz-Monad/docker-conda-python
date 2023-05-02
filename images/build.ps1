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

        $imagename = Split-Path -LeafBase $_
        $name = $imagename
        $version = Get-Content 'version'
        if ($name.Contains('+')) {
            $name = $name.Split('+')[0]
        }
        Write-Host -ForegroundColor Cyan "Creating image $($name):$version..."

        $ErrorActionPreference = 'Stop'

        docker build . --tag "$imagename-base" --target base
        docker build . --tag "$imagename"
        docker tag "$($imagename):latest" "$docker_io_user/$($name):$version"
        docker push "$docker_io_user/$($name):$version"

    }
    finally {
        Remove-Item -Recurse './scripts'
        if (-not $has_docker) { Remove-Item './Dockerfile' }
        Pop-Location
    }
}

Pop-Location
