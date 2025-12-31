#!/bin/bash
# Revanced build
source ./src/build/utils.sh

# Download requirements
revanced_dl(){
    dl_gh "revanced-patches revanced-cli" "revanced" "latest"
}

1() {
    revanced_dl
    # Patch YouTube:
    # switched to get_apkpure with Bundle_extract to support the split logic below
    get_patches_key "youtube-revanced"
    get_apkpure "com.google.android.youtube" "youtube" "youtube-watch-listen-stream/com.google.android.youtube" "Bundle_extract"
    split_editor "youtube" "youtube"
    patch "youtube" "revanced"

    # Patch Youtube Arm64-v8a
    get_patches_key "youtube-revanced"
    # Re-using the extracted bundle from above
    split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
    patch "youtube-arm64-v8a" "revanced"

    # Patch Youtube Armeabi-v7a
    get_patches_key "youtube-revanced"
    split_editor "youtube" "youtube-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
    patch "youtube-armeabi-v7a" "revanced"
}

2() {
    revanced_dl
    # Patch Messenger:
    # Arm64-v8a
    get_patches_key "messenger"
    get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
    patch "messenger-arm64-v8a" "revanced"

    # Patch Facebook:
    # Arm64-v8a
    get_patches_key "facebook"
    get_apkpure "com.facebook.katana" "facebook-arm64-v8a" "facebook/com.facebook.katana"
    patch "facebook-arm64-v8a" "revanced"
}

3() {
    revanced_dl
    # Patch Tiktok:
    get_patches_key "tiktok"
    # Switched to APKPure
    get_apkpure "com.zhiliaoapp.musically" "tiktok" "tiktok-make-your-day/com.zhiliaoapp.musically" "Bundle"
    patch "tiktok" "revanced"
}

4() {
    revanced_dl
    # Patch Google photos:
    # Arm64-v8a
    get_patches_key "gg-photos"
    get_apkpure "com.google.android.apps.photos" "gg-photos-arm64-v8a" "google-photos/com.google.android.apps.photos" "Bundle"
    patch "gg-photos-arm64-v8a" "revanced"

    # Armeabi-v7a
    # Note: APKPure usually provides universal bundles, so strict arch splitting might require bundle extraction logic if strict arch is needed.
    # For now, using standard Bundle download which is safer than broken APKMirror.
    get_patches_key "gg-photos"
    get_apkpure "com.google.android.apps.photos" "gg-photos-armeabi-v7a" "google-photos/com.google.android.apps.photos" "Bundle"
    patch "gg-photos-armeabi-v7a" "revanced"
}

5() {
    revanced_dl
    # Patch Pixiv:
    get_patches_key "pixiv"
    get_apkpure "jp.pxv.android" "pixiv" "pixiv/jp.pxv.android" "Bundle"
    patch "pixiv" "revanced"

    # Patch Twitch:
    get_patches_key "twitch"
    # Switched to APKPure with Bundle_extract to support split_editor logic
    get_apkpure "tv.twitch.android.app" "twitch" "twitch-live-game-streaming/tv.twitch.android.app" "Bundle_extract"
    split_editor "twitch" "twitch"
    patch "twitch" "revanced"

    # Patch Twitch Arm64-v8a:
    get_patches_key "twitch"
    split_editor "twitch" "twitch-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
    patch "twitch-arm64-v8a" "revanced"
}

6() {
    revanced_dl
    # Patch Tumblr:
    get_patches_key "tumblr"
    get_apkpure "com.tumblr" "tumblr" "tumblr-fandom-art-chaos/com.tumblr" "Bundle_extract"
    split_editor "tumblr" "tumblr"
    patch "tumblr" "revanced"

    # Patch Tumblr Arm64-v8a:
    get_patches_key "tumblr"
    split_editor "tumblr" "tumblr-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
    patch "tumblr-arm64-v8a" "revanced"
}

7() {
    revanced_dl
    # Patch RAR:
    get_patches_key "rar"
    get_apkpure "com.rarlab.rar" "rar" "rar/com.rarlab.rar"
    patch "rar" "revanced"

    # Patch Lightroom:
    get_patches_key "lightroom"
    # Switched to APKPure
    get_apkpure "com.adobe.lrmobile" "lightroom" "adobe-lightroom-photo-editor/com.adobe.lrmobile" "Bundle"
    patch "lightroom" "revanced"
}

8() {
    revanced_dl
    # Patch Duolingo
    get_patches_key "Duolingo"
    lock_version="1"
    # Switched to APKPure
    get_apkpure "com.duolingo" "duolingo" "duolingo-language-lessons/com.duolingo" "Bundle"
    patch "duolingo" "revanced"
}

9() {
    revanced_dl
    # Patch Photomath
    get_patches_key "Photomath"
    get_apkpure "com.microblink.photomath" "photomath" "photomath/com.microblink.photomath" "Bundle_extract"
    split_editor "photomath" "photomath"
    patch "photomath" "revanced"
}

10() {
    revanced_dl
    # Patch Strava:
    get_patches_key "strava"
    get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-bike-hike/com.strava" "Bundle"
    patch "strava-arm64-v8a" "revanced"
}

11() {
    revanced_dl
    # Patch Viber
    get_patches_key "Viber-revanced"
    get_apkpure "com.viber.voip" "viber" "rakuten-viber-messenger/com.viber.voip" "Bundle"
    patch "viber" "revanced"
}

12() {
    revanced_dl
    # Patch Youtube Music
    # Arm64-v8a
    get_patches_key "youtube-music-revanced"
    get_apkpure "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music/com.google.android.apps.youtube.music" "Bundle"
    patch "youtube-music-arm64-v8a" "revanced"

    # Armeabi-v7a
    get_patches_key "youtube-music-revanced"
    get_apkpure "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music/com.google.android.apps.youtube.music" "Bundle"
    patch "youtube-music-armeabi-v7a" "revanced"
}

case "$1" in
    1) 1 ;;
    2) 2 ;;
    3) 3 ;;
    4) 4 ;;
    5) 5 ;;
    6) 6 ;;
    7) 7 ;;
    8) 8 ;;
    9) 9 ;;
    10) 10 ;;
    11) 11 ;;
    12) 12 ;;
esac
