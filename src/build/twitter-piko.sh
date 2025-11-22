#!/bin/bash
# Twitter Piko - Working version
source src/build/utils.sh

echo "[+] Starting Twitter Piko build..."

# Download requirements
echo "[+] Downloading ReVanced CLI..."
dl_gh "revanced-cli" "revanced" "latest"

echo "[+] Downloading Piko patches and integrations..."
dl_gh "piko revanced-integrations" "crimera" "latest"

# Download Twitter from Uptodown
echo "[+] Downloading Twitter from Uptodown..."
url="https://twitter.en.uptodown.com/android/download"
download_page=$(req "$url" -)

if [ -z "$download_page" ]; then
    echo "[-] Failed to fetch download page"
    exit 1
fi

download_path=$(echo "$download_page" | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')
if [ -z "$download_path" ]; then
    echo "[-] Could not extract download path from Uptodown"
    exit 1
fi

download_url="https://dw.uptodown.com/dwn/$download_path"
echo "[+] Downloading Twitter APK..."
req "$download_url" -o "./download/twitter-stable.apk"

if [ ! -f "./download/twitter-stable.apk" ]; then
    echo "[-] Failed to download Twitter from Uptodown"
    exit 1
fi

echo "[+] Twitter APK downloaded successfully"

# Process splits
echo "[+] Processing APK splits..."
split_editor "twitter-stable" "twitter-stable"

# Patch main APK
echo "[+] Patching main Twitter APK..."
java -jar *cli*.jar patch \
    -p *.rvp \
    --merge *integration*.apk \
    --out=./release/twitter-stable-piko.apk \
    --keystore=./src/_ks.keystore \
    --purge=true \
    ./download/twitter-stable.apk

# Patch ARM64 version only
if [ -f "./download/twitter-stable-arm64_v8a.apk" ]; then
    echo "[+] Patching ARM64 version..."
    java -jar *cli*.jar patch \
        -p *.rvp \
        --merge *integration*.apk \
        --out=./release/twitter-arm64-v8a-piko.apk \
        --keystore=./src/_ks.keystore \
        --purge=true \
        ./download/twitter-stable-arm64_v8a.apk
else
    echo "[-] ARM64 split not found, skipping..."
fi

echo "[+] Twitter Piko build completed successfully!"
