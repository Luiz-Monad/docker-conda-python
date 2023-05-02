Push-Location $PSScriptRoot

$base = "c:/Users/"
$cwd = (Get-Item '../..').FullName
$share = "/mnt/hgfs/Users/" + [IO.Path]::GetRelativePath($base, $cwd).Replace('\', '/')
$mnt = "type=bind,source=$share,target=/app,consistency=cached"

docker run --rm -it -P --mount $mnt @args python311:ssh

Pop-Location
