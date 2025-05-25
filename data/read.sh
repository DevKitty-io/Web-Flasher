#!/usr/bin/env bash

counter=0
temp_file="$(mktemp)"

process() {
	if [[ -z "$1" ]]; then
		# TODO: fix first check and remove this one
		# echo "check=false" >> "$GITHUB_OUTPUT"
		echo "NO LIST!"
	else
		while IFS= read -r file; do
			# echo "$file"
			# echo "$file"
			filename=$(basename "$file")
			echo "$filename"
			rm -rf "$filename"
			curl -LJO "$file"
		done <<<"$1"
	fi
}
while IFS=',' read -r NAME DESC VER LINK EMOJI RELID; do

	if [ $counter -eq 0 ]; then
		counter=$((counter + 1))
		echo "$NAME,$DESC,$VER,$LINK,$EMOJI,$RELID," >>"$temp_file"
		continue
	else
		counter=$((counter + 1))
	fi
	echo "$counter"
	# NAME=$(echo "$line" | cut -d "," -f 1)
	# LINK=$(echo "$line" | cut -d "," -f 4)
	# RELID=$(echo "$line" | cut -d "," -f 5)
	echo "$NAME"
	echo "$RELID"

	# echo "$lline"
	# echo "LINK: $(basename "$LINK")"

	# NOTE: gets the last elem in string
	repo=${LINK##*/}
	repo=${repo::-1}
	ver=${VER:1:-1}
	# echo "$repo"
	# const assetUrl = `https://api.github.com/repos/DevKitty-io/${text}/releases/latest`;
	# curl -LO "$lline/"
	#https://api.github.com/repositories/731907336/releases/latest
	URL="https://api.github.com/repos/DevKitty-io/${repo}/releases/${ver}"
	# echo "$URL"
	list=$(curl "$URL")
	if [[ -z "$list" ]]; then
		# echo "check=false" >> "$GITHUB_OUTPUT"
		# TODO: figure how to get this check to clear so that the next check is not neededj
		echo "NO LIST!"
		continue
	fi
	# echo $list

	files=$(echo "$list" | jq -r '.assets.[] | "\(.browser_download_url)"')
	id=$(echo "$list" | jq -r '.id')
	echo "ID CHECK: $RELID"

	if [[ -z "$RELID" ]]; then
		echo "EMPTY RELID"
		process "$files"
		if [[ "$id" != "null" ]]; then
			RELID="$id"
		fi
	elif [[ "$RELID" == "$id" ]]; then
		echo "IDS MATCH... IGNORING"
	else
		process "$files"
		RELID="$id"
	fi
	echo "$NAME,$DESC,$VER,$LINK,$EMOJI,$RELID," >>"$temp_file"

done <./firmwareRepositories.csv

# echo "$temp_file"
mv "$temp_file" firmwareRepositories.csv

# curl https://api.github.com/repositories/731907336/releases/latest | jq -r '.assets.[] | "\(.browser_download_url)"'
# curl https://api.github.com/repos/DevKitty-io/ScriptKitty-Firmware/releases/latest | jq -r '.assets.[] | "\(.browser_download_url)"'
#
