#! /usr/bin/env bash

set -e

function get_project_dir() {
  SELF=`realpath $0`
  DIR=`dirname $SELF`
  echo ${DIR%/*}
}

function get_version() {
  cat "$(get_project_dir)"/VERSION | sed 's/[\sv]//g'
}

function deletePreviousArtifacts() {
  find . -type f -name "$1*.xcframework" -exec rm {} +
  find . -type f -name "$1*.xcframework.zip" -exec rm {} +
  find . -type f -name "$1*.xcframework.zip.checksum" -exec rm {} +
  rm -rf .archives
}

function buildFramework() {
  xcodebuild archive \
    -scheme $1 \
    -destination "$2" \
    -archivePath "$3" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
}

function builtFrameworkPathForArchive() {
  realpath "$1/.archives/$2/Products/usr/local/lib/$3.framework"
}

function dsymSymbolsPathForArchive() {
  realpath "$1/.archives/$2/dSYMs/$3.framework.dSYM"
}

function createXCFramework() {
  xcodebuild \
    -create-xcframework \
    -framework "$(builtFrameworkPathForArchive $1 $2-iOS.xcarchive $2)" \
    -debug-symbols "$(dsymSymbolsPathForArchive $1 $2-iOS.xcarchive $2)" \
    -framework "$(builtFrameworkPathForArchive $1 $2-iOS-Simulator.xcarchive $2)" \
    -debug-symbols "$(dsymSymbolsPathForArchive $1 $2-iOS-Simulator.xcarchive $2)" \
    -framework "$(builtFrameworkPathForArchive $1 $2-macOS-Catalyst.xcarchive  $2)" \
    -debug-symbols "$(dsymSymbolsPathForArchive $1 $2-macOS-Catalyst.xcarchive $2)" \
    -framework "$(builtFrameworkPathForArchive $1 $2-macOS.xcarchive $2)" \
    -debug-symbols "$(dsymSymbolsPathForArchive $1 $2-macOS.xcarchive $2)" \
    -output "$2.xcframework"
}

function zipXCFramework() {
  ditto -c -k --sequesterRsrc --keepParent "$1.xcframework" "$2"
}

function createChecksum() {
  local checksum=`swift package compute-checksum $1`
  
  echo "$checksum" > "$1.checksum"
  
  echo ""
  echo "🔒 $(swift package compute-checksum $1)"
}

name="DiffMatchPatchObjC"
version="$(get_version)"

if [ -z "$version" ]; then
    echo "❌️ Version must be set"
    exit -1
fi

project_dir="$(get_project_dir)"
pushd "$project_dir" &>/dev/null

deletePreviousArtifacts "$name"
mkdir .archives

buildFramework "$name" "generic/platform=iOS" ".archives/$name-iOS"
buildFramework "$name" "generic/platform=iOS Simulator" ".archives/$name-iOS-Simulator"
buildFramework "$name" "generic/platform=macOS,variant=Mac Catalyst" ".archives/$name-macOS-Catalyst"
buildFramework "$name" "generic/platform=macOS" ".archives/$name-macOS"
createXCFramework "$project_dir" "$name"
zip_name="$name-$version.xcframework.zip"
zipXCFramework "$name" "$zip_name"
createChecksum "$zip_name"
rm -rf "$name.xcframework"

popd &>/dev/null
