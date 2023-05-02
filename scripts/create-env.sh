#!/bin/bash
set -e

conda init
source ~/.bashrc

scan_channels=0
scan_dependencies=0
dependencies=""

while read -r line; do
  # Skip comments and empty lines
  if [[ "$line" =~ ^[[:space:]]*#|^$ ]]; then
    continue
  fi

  if [[ "$line" =~ ^channels[:] ]]; then
    scan_channels=1
    scan_dependencies=0
    continue
  elif [[ "$line" =~ ^dependencies[:] ]]; then
    scan_channels=0
    scan_dependencies=1
    continue
  elif [[ "$line" =~ ^[^:]+[:] ]]; then
    scan_channels=0
    scan_dependencies=0
    continue
  fi

  item="" && [[ "$line" =~ ^[-](.+)$ ]] && item="${BASH_REMATCH[1]}"
  if [[ 1 == $scan_channels ]]; then
    echo "channel $item"
    conda config --add channels $item
  fi
  if [[ 1 == $scan_dependencies ]]; then
    echo "dependency $item"
    dependencies="$dependencies $item"
  fi

done < "/scripts/environment.txt"

conda create --no-channel-priority --name py311 $dependencies
conda clean -ay
