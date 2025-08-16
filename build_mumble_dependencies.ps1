param (
	[string]$TRIPLET = "x64-windows-static-md",
	[string]$XCOMPILE_TRIPLET = "x86-windows-static-md",
	[switch]$AUTO = $False
)

if (! $AUTO) {
	# Make sure command-prompt stays open if an error is encountered
	trap { Read-Host "ERROR encountered... Press Enter to exit" }
}

$OVERLAY_TRIPLETS = "$PSScriptRoot/mumble_triplets/"

$MUMBLE_DEPS = Get-Content -Path "$PSScriptRoot\mumble_dependencies.txt"
# Windows-specific dependencies
$MUMBLE_DEPS += "mdnsresponder"
$MUMBLE_DEPS += "icu"

# Always bootstrap vcpkg to ensure we got the latest one
Start-Process -FilePath "$PSScriptRoot\bootstrap-vcpkg.bat" -ArgumentList @( "-disableMetrics" ) -Wait

$EXPORTED_NAME = "mumble_env.$TRIPLET.$( git -C "$PSScriptRoot" rev-parse --short --verify HEAD )"
$ALL_DEPS = @()

if ("$TRIPLET" -ne "$XCOMPILE_TRIPLET") {
	Write-Host "Building xcompile dependencies..."
	& "$PSScriptRoot/vcpkg.exe" install --overlay-triplets "$OVERLAY_TRIPLETS" --triplet "$XCOMPILE_TRIPLET" --host-triplet "$TRIPLET" boost-optional --clean-after-build --recurse
	& "$PSScriptRoot/vcpkg.exe" upgrade --overlay-triplets "$OVERLAY_TRIPLETS" --triplet "$XCOMPILE_TRIPLET" --host-triplet "$TRIPLET" boost-optional --no-dry-run
	$ALL_DEPS += "boost-optional:$XCOMPILE_TRIPLET"
}

foreach ($dep in $MUMBLE_DEPS) {
	Write-Host "Building dependency $dep"
	& "$PSScriptRoot/vcpkg.exe" install --overlay-triplets "$OVERLAY_TRIPLETS" --triplet "$TRIPLET" --host-triplet "$TRIPLET" "$dep" --clean-after-build --recurse
	# In case the dependency is already installed, but not up-to-date
	# Unfortunately there is no clean-after-build for this one
	$dep = $dep -replace '\[.*\]'
	& "$PSScriptRoot/vcpkg.exe" upgrade --overlay-triplets "$OVERLAY_TRIPLETS" --triplet "$TRIPLET" --host-triplet "$TRIPLET" "$dep" --no-dry-run
	$ALL_DEPS += "${dep}:$TRIPLET"
}

& "$PSScriptRoot/vcpkg.exe" export --raw --output "$EXPORTED_NAME" --output-dir "$PSScriptRoot" @ALL_DEPS

# Get rid of spurious PDB files
# From https://stackoverflow.com/a/23768332
Get-ChildItem "$PSScriptRoot/$EXPORTED_NAME" -Recurse | Where{$_.Name -Match ".*\.pdb" -and !$_.PSIsContainer} | Remove-Item
