#!/bin/bash
# Twitter Piko - Simplified version
source src/build/utils.sh

echo "[+] Starting Twitter Piko build..."

# Download requirements
dl_gh "revanced-cli" "revanced" "v4.6.0"
dl_gh "piko revanced-integrations" "crimera" "latest"

# Download Twitter directly from Uptodown (bypass APKMirror completely)
echo "[+] Downloading Twitter from Uptodown..."
url="https://twitter.en.uptodown.com/android/download"
download_url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
req "$download_url" -o "./download/twitter-stable.apk"

if [ ! -f "./download/twitter-stable.apk" ]; then
    echo "[-] Failed to download Twitter from Uptodown"
    exit 1
fi

echo "[+] Twitter APK downloaded successfully"

# Apply patches directly without using get_patches_key (which triggers APKMirror)
echo "[+] Applying Piko patches..."
java -jar *cli*.jar patch \
    -p *.rvp \
    --merge *integration*.apk \
    --out=./release/twitter-stable-piko.apk \
    --keystore=./src/_ks.keystore \
    --purge=true \
    ./download/twitter-stable.apk

echo "[+] Twitter Piko build completed successfully!"
