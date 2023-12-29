param (
	[string]$TRIPLET = "x64-windows-static-md",
	[string]$XCOMPILE_TRIPLET = "x86-windows-static-md",
	[switch]$AUTO = $False
)

if (! $AUTO) {
	# Make sure command-prompt stays open if an error is encountered
	trap { Read-Host "ERROR encountered... Press Enter to exit" }
}

$MUMBLE_DEPS = Get-Content -Path "$PSScriptRoot\mumble_dependencies.txt"
# Windows-specific dependencies
$MUMBLE_DEPS += "mdnsresponder"
$MUMBLE_DEPS += "icu"

if (-Not [System.IO.File]::Exists("$PSScriptRoot\vcpkg.exe")) {
	Start-Process -FilePath "$PSScriptRoot\bootstrap-vcpkg.bat" -ArgumentList @( "-disableMetrics" )
}

if ("$TRIPLET" -ne "$XCOMPILE_TRIPLET") {
	Write-Host "Building xcompile dependencies..."
	& "$PSScriptRoot/vcpkg.exe" install --triplet "$XCOMPILE_TRIPLET" boost-optional --clean-after-build
}

foreach ($dep in $MUMBLE_DEPS) {
	Write-Host "Building dependency $dep"
	& "$PSScriptRoot/vcpkg.exe" install --triplet "$TRIPLET" "$dep" --clean-after-build
}
