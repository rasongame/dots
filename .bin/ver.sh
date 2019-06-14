#!/usr/bin/sh
# GET VERSION

pacman -Q $1 | awk '{print $2}'
