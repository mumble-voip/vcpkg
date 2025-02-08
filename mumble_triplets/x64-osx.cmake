# Inherit from this triplet
include("${CMAKE_CURRENT_LIST_DIR}/../triplets/community/x64-osx-release.cmake")

# Apparently Qt 6 doesn't support OSX 15 (yet)
# Note: when changing this, you should also change the value for the arm64-osx triplet
set(VCPKG_OSX_DEPLOYMENT_TARGET 13.0)
