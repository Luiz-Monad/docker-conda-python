[CmdletBinding()]
param (    
    [Parameter(ParameterSetName="pipe", ValueFromPipeline=$true)][string]$image,
    [Parameter()]$entrypoint,
    [Parameter()]$env,
    [Parameter()]$mount,
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
    $mnt = "type=bind,source=/mnt/hgfs/$share/,target=/$share/,consistency=cached"
    Write-Verbose "mount $mnt"
}

$args_docker = @()
if ( $entrypoint ) { $args_docker += @( '--entrypoint', $entrypoint ) }
if ( $env ) { $args_docker += ( $env | ForEach-Object { @( '--env', $_ ) } ) }
Write-Verbose "docker args: $args_docker"

if ( -not $image ) { $image = "debian-python-gradio:latest" }
Write-Verbose "image: $image"

Write-Verbose "app args: $args_app"

docker run --rm -it -P @args_docker $image @args_app

Pop-Location
