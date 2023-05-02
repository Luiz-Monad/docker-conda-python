[CmdletBinding()]
param (    
    [Parameter()]$name
)
Push-Location $PSScriptRoot

$ErrorActionPreference = 'Stop'

docker build . --tag "$name-base" --target base
docker build . --tag "$name"

Pop-Location
