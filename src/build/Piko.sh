#!/bin/bash
# Twitter Piko
source src/build/utils.sh

dl_gh "revanced-cli" "revanced" "v4.6.0"
dl_gh "piko revanced-integrations" "crimera" "latest"

# Patch Twitter Piko:
get_patches_key "twitter-piko"

download_twitter() {
    # Method 1: Direct APKMirror download
    echo "[+] Attempting direct APKMirror download..."
    TWITTER_VERSION="11-40-0-release-1"
    TWITTER_URL="https://www.apkmirror.com/apk/x-corp/twitter/x-${TWITTER_VERSION}-release/"
    
    echo "[+] Fetching download page: $TWITTER_URL"
    DOWNLOAD_PAGE=$(req "$TWITTER_URL" -)
    
    if [ -n "$DOWNLOAD_PAGE" ]; then
        DOWNLOAD_PATH=$(echo "$DOWNLOAD_PAGE" | grep -o 'href="/wp-content/themes/APKMirror/download.php[^"]*' | head -1 | sed 's/href="//')
        if [ -n "$DOWNLOAD_PATH" ]; then
            DOWNLOAD_URL="https://www.apkmirror.com${DOWNLOAD_PATH}"
            echo "[+] Found APKMirror download URL, downloading..."
            req "$DOWNLOAD_URL" -o "twitter-stable.apk"
            if [ -f "twitter-stable.apk" ]; then
                echo "[+] Successfully downloaded from APKMirror"
                return 0
            fi
        fi
    fi
    
    # Method 2: Uptodown fallback
    echo "[-] APKMirror failed, trying Uptodown..."
    UPTODOWN_URL="https://twitter.en.uptodown.com/android/download"
    UPTODOWN_DOWNLOAD=$(req "$UPTODOWN_URL" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}' | head -1)
    
    if [ -n "$UPTODOWN_DOWNLOAD" ]; then
        echo "[+] Found Uptodown download URL, downloading..."
        req "https://dw.uptodown.com/dwn/$UPTODOWN_DOWNLOAD" -o "twitter-stable.apk"
        if [ -f "twitter-stable.apk" ]; then
            echo "[+] Successfully downloaded from Uptodown"
            return 0
        fi
    fi
    
    echo "[-] All download methods failed"
    return 1
}

# Download Twitter APK
if download_twitter; then
    echo "[+] Twitter APK downloaded successfully, processing splits..."
    split_editor "twitter-stable" "twitter-stable"
    patch "twitter-stable" "piko"

    # Patch Twitter Piko Arm64-v8a:
    echo "[+] Patching ARM64 version..."
    get_patches_key "twitter-piko"
    split_editor "twitter-stable" "twitter-arm64-v8a-stable" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64 split_config.mdpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
    patch "twitter-arm64-v8a-stable" "piko"

    echo "[+] Twitter Piko build completed successfully!"
else
    echo "[-] Failed to download Twitter APK"
    exit 1
fi
