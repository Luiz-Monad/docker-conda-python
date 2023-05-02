#!/bin/bash
set -e
uname -a
echo 'finding miniconda3'
wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p /opt/conda
rm /tmp/miniconda.sh
/opt/conda/bin/conda clean -ay
