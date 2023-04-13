#!/bin/sh

python3 ./config.py
cd src
python3 -m http.server 80