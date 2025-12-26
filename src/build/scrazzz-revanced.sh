#!/bin/bash
# scrazzz build
source ./src/build/utils.sh

#################################################
# Download requirements
dl_gh "revanced-cli" "revanced" "latest"
dl_gh "my-revanced-patches" "scrazzz" "prerelease"

#################################################
# Patch Solid Explorer arm64-v8a:
get_patches_key "Soild-Explorer"

# FIX: Updated slugs for APKMirror
# Arg 3 (app name for recent uploads): "solid-explorer-file-manager"
# Arg 4 (URL path): "neatbytes/solid-explorer/solid-explorer-file-manager"
get_apk "pl.solidexplorer2" "solid-explorer-arm64-v8a" "solid-explorer-file-manager" "neatbytes/solid-explorer/solid-explorer-file-manager" "arm64-v8a"

patch "solid-explorer-arm64-v8a" "scrazzz"
