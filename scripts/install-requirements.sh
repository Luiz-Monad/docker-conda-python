#!/bin/bash
set -e

source ~/.bashrc
conda activate py311
pip install --upgrade -r /scripts/requirements.txt
