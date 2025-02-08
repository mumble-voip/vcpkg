# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/unordered
    REF boost-${VERSION}
    SHA512 0eade183775073f66cbe0cd772790a1f09f5eafd1e8e60035978a3286dfaa8d6d9f3cb8b37b74e4516a1f10979b647b866cbf64a380721984795e0c3e436c412
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
