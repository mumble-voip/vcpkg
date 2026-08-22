# Inherit from this triplet
include("${CMAKE_CURRENT_LIST_DIR}/../triplets/community/arm64-osx-release.cmake")

# Note: when changing this, you should also change the value for the x64-osx triplet
# We can only use v15 or higher once we use a Qt version that includes
# https://github.com/qt/qtbase/commit/6c12b7323dbc918d0720a9c4d96e4a2342681a6a
# which will be 6.12+
set(VCPKG_OSX_DEPLOYMENT_TARGET 14.0)
