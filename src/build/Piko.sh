#!/bin/bash
# Twitter Piko
source src/build/utils.sh

dl_gh "revanced-cli" "revanced" "v4.6.0"
dl_gh "piko revanced-integrations" "crimera" "latest"

# Patch Twitter Piko:
get_patches_key "twitter-piko"

# Method 1: Try direct APKMirror with correct URL structure
echo "[+] Downloading Twitter from APKMirror with correct URL structure..."
if get_apk "com.twitter.android" "twitter-stable" "x" "x-corp/twitter/x" "Bundle_extract"; then
    echo "[+] Successfully downloaded from APKMirror"
else
    # Method 2: Try Uptodown as fallback
    echo "[-] APKMirror failed, trying Uptodown..."
    url="https://twitter.en.uptodown.com/android/download"
    download_url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
    if req "$download_url" -o "twitter-stable.apk"; then
        echo "[+] Successfully downloaded from Uptodown"
    else
        # Method 3: Try alternative APKMirror path
        echo "[-] Uptodown failed, trying alternative APKMirror path..."
        if get_apk "com.twitter.android" "twitter-stable" "twitter" "x-corp/twitter/x-formerly-twitter" "Bundle_extract"; then
            echo "[+] Successfully downloaded from alternative APKMirror path"
        else
            echo "[-] All download methods failed"
            exit 1
        fi
    fi
fi

# Process the downloaded APK
if [ -f "twitter-stable.apk" ]; then
    echo "[+] Twitter APK downloaded successfully, processing splits..."
    split_editor "twitter-stable" "twitter-stable"
    
    # Patch main APK
    patch "twitter-stable" "piko"
    
    # Patch Arm64-v8a version only (remove other architectures)
    if [ -f "twitter-stable-arm64_v8a.apk" ]; then
        echo "[+] Patching ARM64 version..."
        mv "twitter-stable-arm64_v8a.apk" "twitter-arm64-v8a-stable.apk"
        patch "twitter-arm64-v8a-stable" "piko"
    else
        echo "[-] ARM64 split not found, skipping..."
    fi
    
else
    echo "[-] No Twitter APK file found after download attempts"
    exit 1
fi
