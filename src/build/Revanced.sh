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
	get_patches_key "youtube-revanced"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	split_editor "youtube" "youtube"
	patch "youtube" "revanced"
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-revanced" 
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
	url="https://tiktok.en.uptodown.com/android/download/1026195874-x" #Use uptodown because apkmirror ban tiktok in US lead github action can't download apk file
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "tiktok.apk"
	patch "tiktok" "revanced"
}
4() {
	revanced_dl
	# Patch Google photos:
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "revanced"
	# Armeabi-v7a
	get_patches_key "gg-photos"
 	version="7.32.0.765953717"
	get_apk "com.google.android.apps.photos" "gg-photos-armeabi-v7a" "photos" "google-inc/photos/google-photos" "armeabi-v7a" "nodpi"
	patch "gg-photos-armeabi-v7a" "revanced"
}
5() {
	revanced_dl
	# Patch Pixiv:
	get_patches_key "pixiv"
	get_apkpure "jp.pxv.android" "pixiv" "pixiv/jp.pxv.android"
	patch "pixiv" "revanced"
	# Patch Twitch:
	get_patches_key "twitch"
	get_apk "tv.twitch.android.app" "twitch" "twitch" "twitch-interactive-inc/twitch/twitch-live-streaming" "Bundle_extract"
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
	get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr-social-media-art" "Bundle_extract"
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
	get_apk "com.rarlab.rar" "rar" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "Bundle"
	patch "rar" "revanced"
	# Patch Lightroom:
	get_patches_key "lightroom"
 	url="https://adobe-lightroom-mobile.en.uptodown.com/android/download/1033600808" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "lightroom.apk"
	patch "lightroom" "revanced"
}
8() {
	revanced_dl
	# Patch Duolingo
	get_patches_key "Duolingo"
	lock_version="1"
	get_apk "com.duolingo" "duolingo" "duolingo-duolingo" "duolingo/duolingo-duolingo/duolingo-language-lessons" "Bundle"
	patch "duolingo" "revanced"
}
9() {
	revanced_dl
	# Patch Photomath
	get_patches_key "Photomath"
	get_apk "com.microblink.photomath" "photomath" "photomath" "google-inc/photomath/photomath" "Bundle" "Bundle_extract"
	split_editor "photomath" "photomath"
	patch "photomath" "revanced"
}
10() {
	revanced_dl
	# Patch Strava:
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-2025-health/com.strava" "Bundle"
	patch "strava-arm64-v8a" "revanced"
}
11() {
	revanced_dl
	# Patch Viber
	get_patches_key "Viber-revanced"
	get_apk "com.viber.voip" "viber" "viber" "viber-media-s-a-r-l/viber/rakuten-viber-messenger"
	patch "viber" "revanced"
}
12() {
	revanced_dl
	# Patch Youtube Music
	# Arm64-v8a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced"
	# Armeabi-v7a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-armeabi-v7a" "revanced"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
    3)
        3
        ;;
    4)
        4
        ;;
    5)
        5
        ;;
    6)
        6
        ;;
    7)
        7
        ;;
    8)
        8
        ;;
    9)
        9
        ;;
    10)
        10
        ;;
    11)
        11
        ;;
    12)
        12
        ;;
esac
