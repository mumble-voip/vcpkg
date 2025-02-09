#!/bin/bash

set -e

if [ -z "$1" ]; then
	1>&2 echo "No input directory given"
	exit 1
fi

if [ -n "$2" ]; then
	1>&2 echo "Too many arguments - expected only a single directory"
	exit 2
fi

echo "Archiving $1 ..."
tar -cf "$1.tar" "$1"
echo "Compressing $1.tar ..."
xz -9e "$1.tar"
