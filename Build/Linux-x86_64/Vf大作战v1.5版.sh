#!/bin/sh
echo -ne '\033c\033]0;MyFirstGame\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Vf大作战v1.5版.x86_64" "$@"
