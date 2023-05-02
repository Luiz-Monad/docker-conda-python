[CmdletBinding()]
param (    
    [Parameter(ParameterSetName="pipe", ValueFromPipeline=$true)][string]$image,
    [Parameter()]$entrypoint,
    [Parameter()]$env,
    [Parameter(ValueFromRemainingArguments=$true)]$args_app
)
Push-Location $PSScriptRoot

# $base = "c:/Users/"
# $cwd = (Get-Item '..').FullName
# $share = "/mnt/hgfs/Users/" + [IO.Path]::GetRelativePath($base, $cwd).Replace('\', '/')
# $mnt = "type=bind,source=$share,target=/app,consistency=cached"
# Write-Verbose "mount $mnt"

$args_docker = @()
if ( $entrypoint ) { $args_docker += @( '--entrypoint', $entrypoint ) }
if ( $env ) { $args_docker += ( $env | ForEach-Object { @( '--env', $_ ) } ) }
Write-Verbose "docker args: $args_docker"

if ( -not $image ) { $image = "python311:latest" }
Write-Verbose "image: $image"

Write-Verbose "app args: $args_app"

docker run --rm -it -P  @args_docker $image @args_app

Pop-Location
