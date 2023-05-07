[CmdletBinding()]
param (    
    [Parameter()]$docker_registry_user = $null
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

        docker build . --tag "$imagename-base" --target base | Write-Information
        docker build . --tag "$imagename" | Write-Information
        
        if ($docker_registry_user -ne $null) {
            docker tag "$($imagename):latest" $tag | Write-Information
            docker push $tag | Write-Information
        } else {
            $tag = "$($imagename):latest"
        }

        Write-Output ([PSCustomObject]@{
            tag = $tag
            digest = docker inspect --format='{{json .Config.Image}}' $tag | ConvertFrom-Json
        })

    }
    finally {
        Remove-Item -Recurse './scripts'
        if (-not $has_docker) { Remove-Item './Dockerfile' }
        Pop-Location
    }
}

Pop-Location
