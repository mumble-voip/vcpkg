vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davidebeatrici/ipxx
    REF "v${VERSION}"
    SHA512 146a70e8600c516da084d6d133fb90d711c131cdf333a0a79f257d91d606956166859fd5b59776b1fa37f6cda4919b6b5d72246ccea793af50a7b8b5b3d2b28e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIPXX_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
