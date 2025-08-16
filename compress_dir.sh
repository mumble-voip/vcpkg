#!/bin/bash

set -e

input_dir="$1"

if [[ -z "$input_dir" ]]; then
	1>&2 echo "No input directory given"
	exit 1
fi

if [[ -n "$2" ]]; then
	1>&2 echo "Too many arguments - expected only a single directory"
	exit 2
fi

if [[ "$input_dir" = */ ]]; then
	# Remove trailing slash
	input_dir="${input_dir%/}"
fi

echo "Archiving $input_dir ..."
tar -cf "$input_dir.tar" "$1"
echo "Compressing $input_dir.tar ..."
xz -9e "$input_dir.tar"
