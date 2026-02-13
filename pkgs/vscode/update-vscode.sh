#! /usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq nix

set -euo pipefail

FILE="./pkgs/vscode/default.nix"

echo "Checking latest VS Code release..."

latestVersion=$(curl -s https://api.github.com/repos/microsoft/vscode/releases |
	jq -r 'map(select(.prerelease==false)) | .[].tag_name' |
	sort -V | tail -n1)

currentVersion=$(grep -Po 'version = "\K[^"]+' "$FILE")

echo "Latest:  $latestVersion"
echo "Current: $currentVersion"

if [[ $latestVersion == "$currentVersion" ]]; then
	echo "Already up to date."
	exit 0
fi

echo "Fetching commit SHA..."
rev=$(curl -s https://api.github.com/repos/microsoft/vscode/git/ref/tags/$latestVersion |
	jq -r .object.sha)

echo "Prefetching main binary hash..."
mainHash=$(nix store prefetch-file \
	"https://update.code.visualstudio.com/${latestVersion}/linux-x64/stable" \
	--json | jq -r .hash)

echo "Prefetching server hash..."
serverHash=$(nix store prefetch-file \
	"https://update.code.visualstudio.com/commit:${rev}/server-linux-x64/stable" \
	--json | jq -r .hash)

echo "Updating file..."

sed -i "s/version = \".*\";/version = \"$latestVersion\";/" "$FILE"
sed -i "s/rev = \".*\";/rev = \"$rev\";/" "$FILE"
sed -i "s/hash = \"sha256-.*\";/hash = \"$mainHash\";/" "$FILE"
sed -i "s/serverHash = \"sha256-.*\";/serverHash = \"$serverHash\";/" "$FILE"

echo "Done."
