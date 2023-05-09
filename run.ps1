[CmdletBinding()]
param (    
    [Parameter(ParameterSetName="pipe", ValueFromPipeline=$true)][string]$image,
    [Parameter()]$entrypoint,
    [Parameter()]$env,
    [Parameter()]$mount,
    [Parameter()]$as,
    [Parameter()]$port,
    [Parameter(ValueFromRemainingArguments=$true)]$args_app
)
Push-Location $PSScriptRoot

if ($mount) {
    $dm = (vmrun list | Select-String docker).Line
    Write-Verbose "vmware $dm"
    $share = (Split-Path $mount -LeafBase)
    $folder = (Get-Item $mount).FullName
    Write-Verbose "mounting $folder -> $share"
    vmrun -T ws removeSharedFolder $dm $share
    vmrun -T ws addSharedFolder $dm $share $folder
    $target = $(if ($as) { $as } else { $share })
    $mnt = "type=bind,source=/mnt/hgfs/$share,target=$target,consistency=cached"
    Write-Verbose "mount $mnt"
}

$allports = @()
if ( -not $port ) { $allports += @( '--publish-all' ) }

$args_docker = @()
if ( $entrypoint ) { $args_docker += @( '--entrypoint', $entrypoint ) }
if ( $env ) { $args_docker += ( $env | ForEach-Object { @( '--env', $_ ) } ) }
if ( $mnt ) { $args_docker += @( '--mount', $mnt ) }
if ( $port ) { $args_docker += @( '--publish', "$($port):$($port)" ) }
Write-Verbose "docker args: $args_docker"

if ( -not $image ) { $image = "debian-python-gradio:latest" }
Write-Verbose "image: $image"

Write-Verbose "app args: $args_app"

docker run --rm -it @allports @args_docker $image @args_app

Pop-Location
