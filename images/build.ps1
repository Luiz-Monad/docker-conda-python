[CmdletBinding()]
param (    
    [Parameter()]$docker_registry_user
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
        $imagename = $name.Replace('+', '-')
        $version = Get-Content 'version'
        if ($name.Contains('+')) {
            $name = $name.Split('+')[0]
        }
        $tag = "$docker_registry_user/$($name):$version"
        Write-Host -ForegroundColor Cyan "Creating image $($name):$version..."

        $ErrorActionPreference = 'Stop'

        docker build . --tag "$imagename-base" --target base | Out-Host
        docker build . --tag "$imagename" | Out-Host
        docker tag "$($imagename):latest" $tag | Out-Host
        docker push $tag | Out-Host

        Write-Output @{
            tag = $tag
            digest = docker inspect --format='{{json .Config.Image}}' $tag | convertfrom-json
        }

    }
    finally {
        Remove-Item -Recurse './scripts'
        if (-not $has_docker) { Remove-Item './Dockerfile' }
        Pop-Location
    }
}

Pop-Location
