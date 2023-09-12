[CmdletBinding()]
param (    
    [Parameter()]$docker_registry_user = $null,
    [Parameter()][switch]$use_buildx
)
Push-Location $PSScriptRoot

$images = Get-ChildItem . -Directory | Select-Object -exp FullName
$images | ForEach-Object {
    Push-Location $_
    try {
        Copy-Item '../../scripts' -Recurse -Destination '.'

        $name = Split-Path -LeafBase $_
        $imagename = $name.Replace('+', '-')
        $version = Get-Content 'version'
        if ($name.Contains('+')) {
            $name = $name.Split('+')[0]
        }
        $tag = "$docker_registry_user/$($name):$version"
        $build_tag = "$($imagename):latest"
        Write-Host -ForegroundColor Cyan "Creating image $($name):$version..."

        $ErrorActionPreference = 'Stop'

        if ($use_buildx) {
            function docker-build { docker buildx build --cache-from=type=gha --cache-to=type=gha,mode=max @args }
        } else {
            function docker-build { docker build @args }
        }

        docker-build . --tag "$imagename-base" --target base | Write-Information
        docker-build . --tag "$imagename" | Write-Information
        
        if ($docker_registry_user -ne $null) {
            docker tag $build_tag $tag | Write-Information
            docker push $tag | Write-Information
        } else {
            $tag = $build_tag
        }

        Write-Output ([PSCustomObject]@{
            tag = $tag
            digest = docker inspect --format='{{json .Config.Image}}' $tag | ConvertFrom-Json
        })

    }
    finally {
        Remove-Item -Recurse './scripts'
        Pop-Location
    }
}

Pop-Location
