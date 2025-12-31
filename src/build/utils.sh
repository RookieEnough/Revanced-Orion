[file name]: utils.sh
#!/bin/bash

mkdir -p ./release ./download

# Setup pup for download apk files
wget -q -O ./pup.zip https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip
unzip -o "./pup.zip" -d "./" > /dev/null 2>&1
chmod +x ./pup
pup="./pup"
# Setup APKEditor for install combine split apks
wget -q -O ./APKEditor.jar https://github.com/REAndroid/APKEditor/releases/download/V1.4.2/APKEditor-1.4.2.jar
APKEditor="./APKEditor.jar"

#################################################

# Colored output logs
green_log() {
    echo -e "\e[32m$1\e[0m"
}
red_log() {
    echo -e "\e[31m$1\e[0m"
}

#################################################

# Download Github assets requirement:
dl_gh() {
	if [ $3 == "prerelease" ]; then
		local repo=$1
		for repo in $1 ; do
			local owner=$2 tag=$3 found=0 assets=0
			releases=$(wget -qO- "https://api.github.com/repos/$owner/$repo/releases")
			while read -r line; do
				if [[ $line == *"\"tag_name\":"* ]]; then
					tag_name=$(echo $line | cut -d '"' -f 4)
					if [ "$tag" == "latest" ] || [ "$tag" == "prerelease" ]; then
						found=1
					else
						found=0
					fi
				fi
				if [[ $line == *"\"prerelease\":"* ]]; then
					prerelease=$(echo $line | cut -d ' ' -f 2 | tr -d ',')
					if [ "$tag" == "prerelease" ] && [ "$prerelease" == "true" ] ; then
						found=1
      					elif [ "$tag" == "prerelease" ] && [ "$prerelease" == "false" ]; then
	   					found=1
					fi
				fi
				if [[ $line == *"\"assets\":"* ]]; then
					if [ $found -eq 1 ]; then
						assets=1
					fi
				fi
				if [[ $line == *"\"browser_download_url\":"* ]]; then
					if [ $assets -eq 1 ]; then
						url=$(echo $line | cut -d '"' -f 4)
							if [[ $url != *.asc ]]; then
							name=$(basename "$url")
							wget -q -O "$name" "$url"
							green_log "[+] Downloading $name from $owner"
						fi
					fi
				fi
				if [[ $line == *"],"* ]]; then
					if [ $assets -eq 1 ]; then
						assets=0
						break
					fi
				fi
			done <<< "$releases"
		done
	else
		for repo in $1 ; do
			tags=$( [ "$3" == "latest" ] && echo "latest" || echo "tags/$3" )
			wget -qO- "https://api.github.com/repos/$2/$repo/releases/$tags" \
			| jq -r '.assets[] | "\(.browser_download_url) \(.name)"' \
			| while read -r url names; do
   				if [[ $url != *.asc ]]; then
					green_log "[+] Downloading $names from $2"
					wget -q -O "$names" $url
     				fi
			done
		done
	fi
}

#################################################

# Get patches list:
get_patches_key() {
	excludePatches=""
	includePatches=""
	excludeLinesFound=false
	includeLinesFound=false
	if [ -f "src/patches/$1/include-patches" ]; then
		sed -i 's/\r$//' src/patches/$1/include-patches
	fi
	if [ -f "src/patches/$1/exclude-patches" ]; then
		sed -i 's/\r$//' src/patches/$1/exclude-patches
	fi
	if [[ $(ls revanced-cli-*.jar 2>/dev/null) =~ revanced-cli-([0-9]+) ]]; then
		num=${BASH_REMATCH[1]}
		if [ $num -ge 5 ]; then
			if [ -f "src/patches/$1/exclude-patches" ]; then
				while IFS= read -r line1; do
					excludePatches+=" -d \"$line1\""
					excludeLinesFound=true
				done < src/patches/$1/exclude-patches
			fi
			if [ -f "src/patches/$1/include-patches" ]; then
				while IFS= read -r line2; do
					if [[ "$line2" == *"|"* ]]; then
						patch_name="${line2%%|*}"
						options="${line2#*|}"
						includePatches+=" -e \"${patch_name}\" ${options}"
					else
						includePatches+=" -e \"$line2\""
					fi
					includeLinesFound=true
				done < src/patches/$1/include-patches
			fi
		else
			if [ -f "src/patches/$1/exclude-patches" ]; then
				while IFS= read -r line1; do
					excludePatches+=" -e \"$line1\""
					excludeLinesFound=true
				done < src/patches/$1/exclude-patches
			fi
			
			if [ -f "src/patches/$1/include-patches" ]; then
				while IFS= read -r line2; do
					includePatches+=" -i \"$line2\""
					includeLinesFound=true
				done < src/patches/$1/include-patches
			fi
		fi
	fi
	if [ "$excludeLinesFound" = false ]; then
		excludePatches=""
	fi
	if [ "$includeLinesFound" = false ]; then
		includePatches=""
	fi
	export excludePatches
	export includePatches
}

#################################################

# Store the original version before sanitizing
store_original_version() {
    if [ -n "$version" ]; then
        # Store the original version (with dots) for display and release naming
        export ORIGINAL_VERSION="$version"
        # Sanitize version for URLs (replace dots with hyphens)
        SANITIZED_VERSION=$(echo "$version" | tr -d ' ' | sed 's/\./-/g')
        export version="$SANITIZED_VERSION"
    fi
}

# Download apks files from APKMirror:
_req() {
    if [ "$2" = "-" ]; then
        wget -nv -O "$2" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" --header="Accept-Language: en-US,en;q=0.9" --header="Connection: keep-alive" --header="Upgrade-Insecure-Requests: 1" --header="Cache-Control: max-age=0" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" --keep-session-cookies --timeout=30 "$1" || return 1
    else
        wget -nv -O "./download/$2" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" --header="Accept-Language: en-US,en;q=0.9" --header="Connection: keep-alive" --header="Upgrade-Insecure-Requests: 1" --header="Cache-Control: max-age=0" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" --keep-session-cookies --timeout=30 "$1" || return 1
    fi
}
req() {
    _req "$1" "$2" || rm -f "./download/$2"
}
dl_apk() {
	local url=$1 regexp=$2 output=$3
	local html
	
	# Get first page
	html=$(req "$url" -)
	if [ $? -ne 0 ] || [ -z "$html" ]; then
		red_log "[-] Failed to fetch page: $url"
		return 1
	fi
	
	if [[ -z "$4" ]] || [[ $4 == "Bundle" ]] || [[ $4 == "Bundle_extract" ]]; then
		url="https://www.apkmirror.com$(echo "$html" | tr '\n' ' ' | sed -n "s/.*<a[^>]*href=\"\([^\"]*\)\".*${regexp}.*/\1/p")"
	else
		# For split APKs
		url="https://www.apkmirror.com$(echo "$html" | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	fi
	
	# Get download button page
	html=$(req "$url" -)
	if [ $? -ne 0 ] || [ -z "$html" ]; then
		red_log "[-] Failed to fetch download page"
		return 1
	fi
	
	# Extract download link
	url="https://www.apkmirror.com$(echo "$html" | grep -oP 'class="[^"]*downloadButton[^"]*".*?href="\K[^"]+' | head -1)"
	if [[ -z "$url" ]] || [[ "$url" == "https://www.apkmirror.com" ]]; then
		# Try alternative method
		url="https://www.apkmirror.com$(echo "$html" | grep -oP 'href="\K[^"]+(?="[^>]*>Download APK<)' | head -1)"
	fi
	
	# Get final download link
	html=$(req "$url" -)
	if [ $? -ne 0 ] || [ -z "$html" ]; then
		red_log "[-] Failed to fetch final download page"
		return 1
	fi
	
	url="https://www.apkmirror.com$(echo "$html" | grep -oP 'id="download-link".*?href="\K[^"]+' | head -1)"
	if [[ -z "$url" ]] || [[ "$url" == "https://www.apkmirror.com" ]; then
		red_log "[-] Could not extract download link"
		return 1
	fi
	
	req "$url" "$output"
	return $?
}

#################################################

# Get APK from APKMirror
get_apk() {
	local package_name=$1
	local output_name=$2
	local app_slug=$3
	local publisher=$4
	local arch=${5:-}
	local dpi=${6:-}
	local min_version=${7:-}
	
	# Clean up publisher path
	publisher=$(echo "$publisher" | sed 's/\./-/g')
	
	# Get version from patches if not locked
	if [ -z "$version" ] && [ "$lock_version" != "1" ]; then
		if [[ $(ls revanced-cli-*.jar 2>/dev/null) =~ revanced-cli-([0-9]+) ]]; then
			num=${BASH_REMATCH[1]}
			if [ $num -ge 5 ]; then
				# For CLI v5+
				if ls *.rvp 1> /dev/null 2>&1; then
					version=$(java -jar *cli*.jar list-patches --with-packages --with-versions *.rvp 2>/dev/null | \
						awk -v pkg="$package_name" '
						BEGIN { found = 0 }
						/^Index:/ { found = 0 }
						/Package name: / { if ($3 == pkg) { found = 1 } }
						/Compatible versions:/ { 
							if (found) { 
								getline
								latest_version = $1
								while (getline && $1 ~ /^[0-9]+\./) { 
									latest_version = $1 
								}
								print latest_version
								exit
							}
						}' | head -1)
				fi
			else
				# For older CLI versions
				if ls *.json 1> /dev/null 2>&1; then
					version=$(jq -r '[.. | objects | select(.name == "'$package_name'" and .versions != null) | .versions[]] | reverse | .[0] // ""' *.json 2>/dev/null | uniq | head -1)
				fi
			fi
		fi
	fi
	
	# If still no version, try default versions
	if [ -z "$version" ] || [ "$version" = "null" ] || [ "$version" = "" ]; then
		case "$package_name" in
			"com.google.android.youtube")
				version="19.50.40"
				;;
			"com.google.android.apps.youtube.music")
				version="7.15.53"
				;;
			"com.google.android.apps.photos")
				version="7.32.0.765953717"
				;;
			"com.duolingo")
				version="7.3.2"
				;;
			*)
				version=""
				;;
		esac
	fi
	
	# Store original version before sanitizing
	store_original_version
	
	if [[ -n "$version" ]]; then
		green_log "[+] Downloading $output_name version: $ORIGINAL_VERSION $arch $dpi"
		
		if [[ $arch == "Bundle" ]] || [[ $arch == "Bundle_extract" ]]; then
			local base_apk="$output_name.apkm"
		else
			local base_apk="$output_name.apk"
		fi
		
		local url_regexp
		if [[ -z $arch ]] || [[ $arch == "Bundle" ]] || [[ $arch == "Bundle_extract" ]]; then
			if [[ $arch == "Bundle" ]] || [[ $arch == "Bundle_extract" ]]; then
				url_regexp='BUNDLE<\/span>'
			else
				url_regexp='APK<\/span>'
			fi
			dl_apk "https://www.apkmirror.com/apk/$publisher/$app_slug-$version-release/" \
				   "$url_regexp" \
				   "$base_apk" \
				   "$arch"
		else
			# For split APKs
			url_regexp="$arch.*$dpi.*$min_version"
			dl_apk "https://www.apkmirror.com/apk/$publisher/$app_slug-$version-release/" \
				   "$url_regexp" \
				   "$base_apk" \
				   "$arch"
		fi
		
		if [[ -f "./download/$base_apk" ]]; then
			green_log "[+] Successfully downloaded $output_name"
			
			if [[ $arch == "Bundle" ]]; then
				green_log "[+] Merging splits apk to standalone apk"
				java -jar $APKEditor m -i "./download/$base_apk" -o "./download/$output_name.apk" > /dev/null 2>&1
			elif [[ $arch == "Bundle_extract" ]]; then
				green_log "[+] Extracting bundle"
				unzip -o "./download/$base_apk" -d "./download/$output_name" > /dev/null 2>&1
			fi
			return 0
		else
			red_log "[-] Failed to download $output_name"
			return 1
		fi
	fi
	
	# Fallback: try multiple versions
	local attempt=0
	local versions=("19.50.40" "19.49.37" "19.45.43" "19.44.39" "19.43.36")
	
	while [ $attempt -lt ${#versions[@]} ]; do
		if [ $attempt -eq 0 ]; then
			version=${versions[0]}
		else
			version=${versions[$attempt]}
		fi
		
		# Store original version before sanitizing
		store_original_version
		
		green_log "[+] Trying to download $output_name version: $ORIGINAL_VERSION (attempt $((attempt+1)))"
		
		if [[ $arch == "Bundle" ]] || [[ $arch == "Bundle_extract" ]]; then
			local base_apk="$output_name.apkm"
		else
			local base_apk="$output_name.apk"
		fi
		
		local url_regexp
		if [[ -z $arch ]] || [[ $arch == "Bundle" ]] || [[ $arch == "Bundle_extract" ]]; then
			if [[ $arch == "Bundle" ]] || [[ $arch == "Bundle_extract" ]]; then
				url_regexp='BUNDLE<\/span>'
			else
				url_regexp='APK<\/span>'
			fi
			dl_apk "https://www.apkmirror.com/apk/$publisher/$app_slug-$version-release/" \
				   "$url_regexp" \
				   "$base_apk" \
				   "$arch"
		else
			url_regexp="$arch.*$dpi.*$min_version"
			dl_apk "https://www.apkmirror.com/apk/$publisher/$app_slug-$version-release/" \
				   "$url_regexp" \
				   "$base_apk" \
				   "$arch"
		fi
		
		if [[ -f "./download/$base_apk" ]]; then
			green_log "[+] Successfully downloaded $output_name"
			
			if [[ $arch == "Bundle" ]]; then
				green_log "[+] Merging splits apk to standalone apk"
				java -jar $APKEditor m -i "./download/$base_apk" -o "./download/$output_name.apk" > /dev/null 2>&1
			elif [[ $arch == "Bundle_extract" ]]; then
				green_log "[+] Extracting bundle"
				unzip -o "./download/$base_apk" -d "./download/$output_name" > /dev/null 2>&1
			fi
			return 0
		else
			((attempt++))
			red_log "[-] Failed to download $output_name with version $ORIGINAL_VERSION"
			unset version
			unset ORIGINAL_VERSION
		fi
	done
	
	red_log "[-] No more versions to try. Failed to download $output_name"
	return 1
}

get_apkpure() {
	local package_name=$1
	local output_name=$2
	local app_slug=$3
	local arch=${4:-}
	
	if [ -z "$version" ] && [ "$lock_version" != "1" ]; then
		if [[ $(ls revanced-cli-*.jar 2>/dev/null) =~ revanced-cli-([0-9]+) ]]; then
			num=${BASH_REMATCH[1]}
			if [ $num -ge 5 ]; then
				if ls *.rvp 1> /dev/null 2>&1; then
					version=$(java -jar *cli*.jar list-patches --with-packages --with-versions *.rvp 2>/dev/null | \
						awk -v pkg="$package_name" '
						BEGIN { found = 0 }
						/^Index:/ { found = 0 }
						/Package name: / { if ($3 == pkg) { found = 1 } }
						/Compatible versions:/ { 
							if (found) { 
								getline
								latest_version = $1
								while (getline && $1 ~ /^[0-9]+\./) { 
									latest_version = $1 
								}
								print latest_version
								exit
							}
						}' | head -1)
				fi
			else
				if ls *.json 1> /dev/null 2>&1; then
					version=$(jq -r '[.. | objects | select(.name == "'$package_name'" and .versions != null) | .versions[]] | reverse | .[0] // ""' *.json 2>/dev/null | uniq | head -1)
				fi
			fi
		fi
	fi
	
	if [[ $arch == "Bundle" ]] || [[ $arch == "Bundle_extract" ]]; then
		local base_apk="$output_name.xapk"
	else
		local base_apk="$output_name.apk"
	fi
	
	if [[ -n "$version" ]]; then
		url="https://apkpure.com/$app_slug/$package_name/download?from=details&versionCode="
	else
		url="https://apkpure.com/$app_slug/$package_name/download"
		version="$(req "$url" - | awk -F'Download APK | \\(' '/<h2>/{print $2}' | head -1)"
	fi
	
	# Store original version before sanitizing
	store_original_version
	
	green_log "[+] Downloading $output_name version: $ORIGINAL_VERSION $arch"
	
	# Try to get download link
	local download_url=$(req "$url" - | grep -oP '<a[^>]+id="download_link"[^>]+href="\Khttps://[^"]+' | head -1)
	
	if [ -z "$download_url" ]; then
		# Alternative method for APKPure
		download_url="https://download.apkpure.com/b/APK/$package_name?version=latest"
	fi
	
	req "$download_url" "$base_apk"
	
	if [[ -f "./download/$base_apk" ]]; then
		green_log "[+] Successfully downloaded $output_name"
		
		if [[ $arch == "Bundle" ]]; then
			green_log "[+] Merging splits apk to standalone apk"
			java -jar $APKEditor m -i "./download/$base_apk" -o "./download/$output_name.apk" > /dev/null 2>&1
		elif [[ $arch == "Bundle_extract" ]]; then
			green_log "[+] Extracting bundle"
			unzip -o "./download/$base_apk" -d "./download/$output_name" > /dev/null 2>&1
		fi
		return 0
	else
		red_log "[-] Failed to download $output_name from APKPure"
		return 1
	fi
}

#################################################

# Patching apps with Revanced CLI:
patch() {
	green_log "[+] Patching $1:"
	if [ -f "./download/$1.apk" ]; then
		local p b m ks a pu opt force
		if [ "$3" = "inotia" ]; then
			p="patch " 
			b="-p *.rvp" 
			m="" 
			a="" 
			ks="_ks" 
			pu="--purge=true" 
			opt="--legacy-options=./src/options/$2.json" 
			force=" --force"
			echo "Patching with Revanced-cli inotia"
		else
			if [[ $(ls revanced-cli-*.jar 2>/dev/null) =~ revanced-cli-([0-9]+) ]]; then
				num=${BASH_REMATCH[1]}
				if [ $num -ge 5 ]; then
					p="patch " 
					b="-p *.rvp" 
					m="" 
					a="" 
					ks="ks" 
					pu="--purge=true" 
					opt="" 
					force=" --force"
					echo "Patching with Revanced-cli version 5+"
				elif [ $num -eq 4 ]; then
					p="patch " 
					b="--patch-bundle *patch*.jar" 
					m="--merge *integration*.apk " 
					a="" 
					ks="ks" 
					pu="--purge=true" 
					opt="--options=./src/options/$2.json "
					echo "Patching with Revanced-cli version 4"
				elif [ $num -eq 3 ]; then
					p="patch " 
					b="--patch-bundle *patch*.jar" 
					m="--merge *integration*.apk " 
					a="" 
					ks="_ks" 
					pu="--purge=true" 
					opt="--options=./src/options/$2.json "
					echo "Patching with Revanced-cli version 3"
				elif [ $num -eq 2 ]; then
					p="" 
					b="--bundle *patch*.jar" 
					m="--merge *integration*.apk " 
					a="--apk " 
					ks="_ks" 
					pu="--clean" 
					opt="--options=./src/options/$2.json "
					echo "Patching with Revanced-cli version 2"
				fi
			fi
		fi
		
		# Determine output filename with version
		local output_filename
		if [ -n "$ORIGINAL_VERSION" ]; then
			# Clean version for filename (replace dots with hyphens)
			local clean_version=$(echo "$ORIGINAL_VERSION" | sed 's/\./-/g')
			output_filename="$1-$2-v$clean_version.apk"
		else
			output_filename="$1-$2.apk"
		fi
		
		# Build command
		local cmd="java -jar *cli*.jar $p$b $m$opt --out=./release/$output_filename$excludePatches$includePatches --keystore=./src/$ks.keystore $pu$force $a./download/$1.apk"
		
		# Run patching command
		eval $cmd
		
  		unset version
		unset ORIGINAL_VERSION
		unset lock_version
		unset excludePatches
		unset includePatches
	else 
		red_log "[-] Not found $1.apk in download directory"
		ls -la ./download/ 2>/dev/null || echo "Download directory doesn't exist"
		return 1
	fi
}

#################################################

split_editor() {
    if [[ -z "$3" || -z "$4" ]]; then
        green_log "[+] Merging splits apk to standalone apk"
        java -jar $APKEditor m -i "./download/$1" -o "./download/$2.apk" > /dev/null 2>&1
        return 0
    fi
    
    IFS=' ' read -r -a include_files <<< "$4"
    mkdir -p "./download/$2"
    
    # Check if source directory exists
    if [ ! -d "./download/$1" ]; then
        red_log "[-] Source directory ./download/$1 not found"
        return 1
    fi
    
    for file in "./download/$1"/*.apk; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        filename=$(basename "$file")
        basename_no_ext="${filename%.apk}"
        
        if [[ "$filename" == "base.apk" ]]; then
            cp -f "$file" "./download/$2/" > /dev/null 2>&1
            continue
        fi
        
        if [[ "$3" == "include" ]]; then
            if [[ " ${include_files[*]} " =~ " ${basename_no_ext} " ]]; then
                cp -f "$file" "./download/$2/" > /dev/null 2>&1
            fi
        elif [[ "$3" == "exclude" ]]; then
            if [[ ! " ${include_files[*]} " =~ " ${basename_no_ext} " ]]; then
                cp -f "$file" "./download/$2/" > /dev/null 2>&1
            fi
        fi
    done

    green_log "[+] Merging splits apk to standalone apk"
    java -jar $APKEditor m -i "./download/$2" -o "./download/$2.apk" > /dev/null 2>&1
}

#################################################

# Split architectures using Revanced CLI, created by inotia00
archs=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
libs=("armeabi-v7a x86_64 x86" "arm64-v8a x86_64 x86" "armeabi-v7a arm64-v8a x86" "armeabi-v7a arm64-v8a x86_64")
gen_rip_libs() {
	for lib in $@; do
		echo -n "--rip-lib $lib "
	done
}
split_arch() {
	green_log "[+] Splitting $1 to ${archs[i]}:"
	if [ -f "./download/$1.apk" ]; then
		unset CI GITHUB_ACTION GITHUB_ACTIONS GITHUB_ACTOR GITHUB_ENV GITHUB_EVENT_NAME GITHUB_EVENT_PATH GITHUB_HEAD_REF GITHUB_JOB GITHUB_REF GITHUB_REPOSITORY GITHUB_RUN_ID GITHUB_RUN_NUMBER GITHUB_SHA GITHUB_WORKFLOW GITHUB_WORKSPACE RUN_ID RUN_NUMBER
		
		local rip_libs=$(gen_rip_libs ${libs[i]})
		
		# Determine output filename with version
		local output_filename
		if [ -n "$ORIGINAL_VERSION" ]; then
			# Clean version for filename (replace dots with hyphens)
			local clean_version=$(echo "$ORIGINAL_VERSION" | sed 's/\./-/g')
			output_filename="$1-${archs[i]}-$2-v$clean_version.apk"
		else
			output_filename="$1-${archs[i]}-$2.apk"
		fi
		
		eval java -jar revanced-cli*.jar patch \
		-p *.rvp \
		$3 \
		--keystore=./src/_ks.keystore --force \
		--legacy-options=./src/options/$2.json $excludePatches$includePatches \
		$rip_libs \
		--out=./release/$output_filename \
		./download/$1.apk
	else
		red_log "[-] Not found $1.apk"
		return 1
	fi
}
