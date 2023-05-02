Push-Location $PSScriptRoot

docker run --name ssh-key --entrypoint /bin/bash python311:ssh-key -c 'ls -l /root'
docker container cp 'ssh-key:/root/id_rsa' .
docker container cp 'ssh-key:/root/id_rsa.pub' .
docker container rm ssh-key

$c = docker container ls --format "{{json .}}" | ConvertFrom-Json
$c | Where-Object { $_.Image -eq 'python311:ssh' }
$net = docker inspect --format '{{json .NetworkSettings}}' $c.Names | ConvertFrom-Json
$ip = docker-machine ip #$net.Gateway
$port = $net.Ports.'2222/tcp'.HostPort

Write-Host -ForegroundColor Cyan "connecting to $ip : $port"
ssh -v $ip -p $port -i id_rsa -l root

Pop-Location
