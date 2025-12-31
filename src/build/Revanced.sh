[file name]: Revanced.sh
#!/bin/bash
# Revanced build
source ./src/build/utils.sh

# Download requirements
revanced_dl(){
	dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"
}

1() {
	revanced_dl
	# Patch YouTube:
	get_patches_key "youtube-revanced"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	if [ -d "./download/youtube" ]; then
		split_editor "youtube" "youtube"
		if [ -f "./download/youtube.apk" ]; then
			patch "youtube" "revanced"
		else
			red_log "[-] Failed to create youtube.apk from bundle"
		fi
	else
		red_log "[-] YouTube bundle extraction failed"
	fi
	
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-revanced" 
	if [ -d "./download/youtube" ]; then
		split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
		if [ -f "./download/youtube-arm64-v8a.apk" ]; then
			patch "youtube-arm64-v8a" "revanced"
		fi
	fi
	
	# Patch Youtube Armeabi-v7a
	get_patches_key "youtube-revanced" 
	if [ -d "./download/youtube" ]; then
		split_editor "youtube" "youtube-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
		if [ -f "./download/youtube-armeabi-v7a.apk" ]; then
			patch "youtube-armeabi-v7a" "revanced"
		fi
	fi
}

2() {
	revanced_dl
	# Patch Messenger:
	# Arm64-v8a
	get_patches_key "messenger"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger"
	if [ -f "./download/messenger-arm64-v8a.apk" ]; then
		patch "messenger-arm64-v8a" "revanced"
	fi
	
	# Patch Facebook:
	# Arm64-v8a
	get_patches_key "facebook"
 	get_apkpure "com.facebook.katana" "facebook-arm64-v8a" "facebook"
	if [ -f "./download/facebook-arm64-v8a.apk" ]; then
		patch "facebook-arm64-v8a" "revanced"
	fi
}

3() {
	revanced_dl
	# Patch Tiktok:
	get_patches_key "tiktok"
	# Try multiple sources for TikTok
	url="https://tiktok.en.uptodown.com/android/download"
	html=$(req "$url" -)
	if [ $? -eq 0 ] && [ -n "$html" ]; then
		download_url=$(echo "$html" | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}' | head -1)
		if [ -n "$download_url" ]; then
			req "$download_url" "tiktok.apk"
		else
			# Fallback to APKPure
			get_apkpure "com.zhiliaoapp.musically" "tiktok" "tiktok"
		fi
	else
		# Fallback to APKPure
		get_apkpure "com.zhiliaoapp.musically" "tiktok" "tiktok"
	fi
	
	if [ -f "./download/tiktok.apk" ]; then
		patch "tiktok" "revanced"
	fi
}

4() {
	revanced_dl
	# Patch Google photos:
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	if [ -f "./download/gg-photos-arm64-v8a.apk" ]; then
		patch "gg-photos-arm64-v8a" "revanced"
	fi
	
	# Armeabi-v7a
	get_patches_key "gg-photos"
 	version="7.32.0.765953717"
 	lock_version="1"
	get_apk "com.google.android.apps.photos" "gg-photos-armeabi-v7a" "photos" "google-inc/photos/google-photos" "armeabi-v7a" "nodpi"
	if [ -f "./download/gg-photos-armeabi-v7a.apk" ]; then
		patch "gg-photos-armeabi-v7a" "revanced"
	fi
	unset lock_version
}

5() {
	revanced_dl
	# Patch Pixiv:
	get_patches_key "pixiv"
	get_apkpure "jp.pxv.android" "pixiv" "pixiv"
	if [ -f "./download/pixiv.apk" ]; then
		patch "pixiv" "revanced"
	fi
	
	# Patch Twitch:
	get_patches_key "twitch"
	get_apk "tv.twitch.android.app" "twitch" "twitch" "twitch-interactive-inc/twitch/twitch-live-streaming" "Bundle_extract"
	if [ -d "./download/twitch" ]; then
		split_editor "twitch" "twitch"
		if [ -f "./download/twitch.apk" ]; then
			patch "twitch" "revanced"
		fi
		
		# Patch Twitch Arm64-v8a:
		get_patches_key "twitch"
		split_editor "twitch" "twitch-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
		if [ -f "./download/twitch-arm64-v8a.apk" ]; then
			patch "twitch-arm64-v8a" "revanced"
		fi
	fi
}

6() {
	revanced_dl
	# Patch Tumblr:
	get_patches_key "tumblr"
	get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr" "Bundle_extract"
	if [ -d "./download/tumblr" ]; then
		split_editor "tumblr" "tumblr"
		if [ -f "./download/tumblr.apk" ]; then
			patch "tumblr" "revanced"
		fi
		
		# Patch Tumblr Arm64-v8a:
		get_patches_key "tumblr"
		split_editor "tumblr" "tumblr-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
		if [ -f "./download/tumblr-arm64-v8a.apk" ]; then
			patch "tumblr-arm64-v8a" "revanced"
		fi
	fi
}

7() {
	revanced_dl
	# Patch RAR:
	get_patches_key "rar"
	get_apk "com.rarlab.rar" "rar" "rar" "rarlab/rar/rar" "Bundle"
	if [ -f "./download/rar.apk" ]; then
		patch "rar" "revanced"
	fi
	
	# Patch Lightroom:
	get_patches_key "lightroom"
 	url="https://adobe-lightroom-mobile.en.uptodown.com/android/download"
	html=$(req "$url" -)
	if [ $? -eq 0 ] && [ -n "$html" ]; then
		download_url=$(echo "$html" | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}' | head -1)
		if [ -n "$download_url" ]; then
			req "$download_url" "lightroom.apk"
		else
			# Fallback to APKPure
			get_apkpure "com.adobe.lrmobile" "lightroom" "adobe-lightroom"
		fi
	else
		# Fallback to APKPure
		get_apkpure "com.adobe.lrmobile" "lightroom" "adobe-lightroom"
	fi
	
	if [ -f "./download/lightroom.apk" ]; then
		patch "lightroom" "revanced"
	fi
}

8() {
	revanced_dl
	# Patch Duolingo
	get_patches_key "Duolingo"
	lock_version="1"
	get_apk "com.duolingo" "duolingo" "duolingo" "duolingo/duolingo/duolingo" "Bundle"
	if [ -f "./download/duolingo.apk" ]; then
		patch "duolingo" "revanced"
	fi
	unset lock_version
}

9() {
	revanced_dl
	# Patch Photomath
	get_patches_key "Photomath"
	get_apk "com.microblink.photomath" "photomath" "photomath" "google-inc/photomath/photomath" "Bundle_extract"
	if [ -d "./download/photomath" ]; then
		split_editor "photomath" "photomath"
		if [ -f "./download/photomath.apk" ]; then
			patch "photomath" "revanced"
		fi
	fi
}

10() {
	revanced_dl
	# Patch Strava:
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava" "Bundle"
	if [ -f "./download/strava-arm64-v8a.apk" ]; then
		patch "strava-arm64-v8a" "revanced"
	fi
}

11() {
	revanced_dl
	# Patch Viber
	get_patches_key "Viber-revanced"
	get_apk "com.viber.voip" "viber" "viber" "viber-media-sarl/viber/viber" "Bundle"
	if [ -f "./download/viber.apk" ]; then
		patch "viber" "revanced"
	fi
}

12() {
	revanced_dl
	# Patch Youtube Music
	# Arm64-v8a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a" "nodpi"
	if [ -f "./download/youtube-music-arm64-v8a.apk" ]; then
		patch "youtube-music-arm64-v8a" "revanced"
	fi
	
	# Armeabi-v7a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a" "nodpi"
	if [ -f "./download/youtube-music-armeabi-v7a.apk" ]; then
		patch "youtube-music-armeabi-v7a" "revanced"
	fi
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
    *)
        echo "Invalid option: $1"
        exit 1
        ;;
esac
