#!/bin/bash

# On failed command (error code) exit the whole script
set -e
# Treat using unset variables as errors
set -u
# For piped commands on command failure fail entire pipe instead of only the last command being significant
set -o pipefail

function error_msg {
	>&2 echo "[ERROR] $@"
}

SCRIPT_DIR="$( dirname "$0" )"
TRIPLET=""
AUTO=false

while [[ -n "${1-}" ]]; do
	case "$1" in
		-t|--triplet)    shift; TRIPLET="$1" ;;
		--auto)          AUTO=true ;;
		--)              shift; break ;;
		*)               error_msg "Invalid argument '$1'" ;;
	esac
	shift
done

if [[ "$AUTO" = "false" ]]; then
	# Make sure the command-prompt stays open if an error is encountered so that the user can read
	# the error message before the console closes.
	# If you run call this script as part of some automation, you'll want to pass --auto
	# to make sure you don't get stuck.
	trap "printf '\n\n'; read -p 'ERROR encountered... Press Enter to exit'" ERR
fi


# Note: We can't use readarray as that doesn't work on macOS
# Taken from https://unix.stackexchange.com/a/628576
DEPS_CONTENT="$(cat "$SCRIPT_DIR/mumble_dependencies.txt" )"
set -o noglob
IFS=$'\n' MUMBLE_DEPS=($DEPS_CONTENT)
set +o noglob

if [[ -z "$TRIPLET" ]]; then
	# Determine vcpkg triplet from OS
	# Available triplets can be printed with `vcpkg help triplet`
	case "$OSTYPE" in
		msys*)      TRIPLET="x64-windows-static-md"; XCOMPILE_TRIPLET="x86-windows-static-md" ;;
		linux-gnu*) TRIPLET="x64-linux";;
		darwin*)
				if [[ "$( uname -m )" = "x86_64" ]]; then
					TRIPLET="x64-osx"
				else
					TRIPLET="arm64-osx"
				fi
			;;
		*) error_msg "The OSTYPE is either not defined or unsupported. Aborting..."; exit 1;;
	esac
fi

if [[ ! -x "$SCRIPT_DIR/vcpkg" ]]; then
	case "$OSTYPE" in
	    msys*) "$SCRIPT_DIR/bootstrap-vcpkg.bat" -disableMetrics ;;
	    *)      bash "$SCRIPT_DIR/bootstrap-vcpkg.sh" -disableMetrics ;;
	esac
fi

echo "Building for triplet $TRIPLET"

if [[ -z "$TRIPLET" ]]; then
    error_msg "Triplet type is not defined! Aborting..."
	exit 2
else
    if [[ $OSTYPE == msys ]]; then
	    # install dns-sd provider
		MUMBLE_DEPS+=("mdnsresponder")
		MUMBLE_DEPS+=("icu")

		echo "Building xcompile dependencies..."
	    "$SCRIPT_DIR/vcpkg" install --triplet "$XCOMPILE_TRIPLET" boost-optional --clean-after-build --recurse
    fi

    for dep in "${MUMBLE_DEPS[@]}"; do
		echo "Building dependency '$dep'..."
		"$SCRIPT_DIR/vcpkg" install --triplet "$TRIPLET" "$dep" --clean-after-build --recurse
		# In case the dependency is already installed, but not up-to-date
		# Unfortunately there is no clean-after-build for this one
		"$SCRIPT_DIR/vcpkg" upgrade --triplet "$TRIPLET" "$( echo "$dep" | sed 's/\[.*\]//g' )" --no-dry-run
    done
fi
