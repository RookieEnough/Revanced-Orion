#!/bin/bash
# Twitter Piko
source src/build/utils.sh

echo "[+] Starting Twitter Piko build..."
dl_gh "revanced-cli" "revanced" "v4.6.0"
dl_gh "piko revanced-integrations" "crimera" "latest"

# Patch Twitter Piko:
get_patches_key "twitter-piko"
echo "[+] Attempting to download Twitter/X from APKMirror..."

# Use the correct APKMirror parameters for Twitter/X
get_apk "com.twitter.android" "twitter-stable" "x" "x-corp/twitter/x" "Bundle_extract"

if [ ! -f "twitter-stable.apk" ]; then
    echo "[-] Failed to download Twitter APK"
    exit 1
fi

echo "[+] Twitter APK downloaded successfully, processing splits..."
split_editor "twitter-stable" "twitter-stable"
patch "twitter-stable" "piko"

# Patch Twitter Piko Arm64-v8a:
echo "[+] Patching ARM64 version..."
get_patches_key "twitter-piko"
split_editor "twitter-stable" "twitter-arm64-v8a-stable" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64 split_config.mdpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
patch "twitter-arm64-v8a-stable" "piko"

echo "[+] Twitter Piko build completed successfully!"
