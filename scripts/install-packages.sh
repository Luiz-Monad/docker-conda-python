#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt_args='-o=Dpkg::Use-Pty=0 -qq -y'

apt-get update $apt_args

env_name=$1
pkgs=""

while read -r line; do
  # Skip comments and empty lines
  if [[ "$line" =~ ^[[:space:]]*#|^$ ]]; then
    continue
  fi

  # Check if the line is a source.list.d command
  if [[ "$line" =~ ^[[:space:]]*deb[[:space:]]+\[signed-by=(.*)\][[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)([[:space:]].+)* ]]; then
    signed_by_url="${BASH_REMATCH[1]}"
    deb_uri="${BASH_REMATCH[2]}"
    deb_suite="${BASH_REMATCH[3]}"
    deb_comp="${BASH_REMATCH[4]}"

    # base tools
    if [ -z "$tools" ]; then
        apt-get install $apt_args --no-install-recommends curl gpg ca-certificates
        tools=1
    fi

    # Download the signed-by file
    mkdir -p /etc/apt/keyrings/
    keyring="/etc/apt/keyrings/$deb_suite.gpg"
    curl -sS "$signed_by_url" | gpg --dearmor -o "$keyring"

    # Save the deb command to a source.list.d file with the signed-by file path
    source_list="/etc/apt/sources.list.d/$deb_suite.list"
    echo "deb [signed-by=$keyring] $deb_uri $deb_suite $deb_comp" > "$source_list"

  elif [[ "$line" =~ ^\s*deb\s+http.* ]]; then
    # Save the deb command to a sources.list file
    echo "$line" >> "/etc/apt/sources.list"

  else
    # Install the package using apt-get
    pkgs="$pkgs $line" 
    echo apt-get install "$line"

  fi

done < "/scripts/sys-packages-$env_name.txt"

# remove base tools
if ! [ -z "$tools" ]; then
    apt-get remove $apt_args curl gpg
    apt-get update $apt_args
fi

# now install everything and autoclean
apt-get install $apt_args --no-install-recommends $pkgs
apt-get upgrade $apt_args
apt-get autoremove $apt_args

# Remove unneeded files.
apt-get clean
rm /var/lib/apt/lists/*_*
