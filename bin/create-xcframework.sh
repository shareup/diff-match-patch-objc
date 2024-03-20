#! /usr/bin/env bash

set -e

XCODE_PROJECT="DiffMatchPatchObjC.xcodeproj"
SCHEME="DiffMatchPatchObjC"
NAME="DiffMatchPatchObjC"

function get_project_dir() {
  SELF=`realpath $0`
  DIR=`dirname $SELF`
  echo ${DIR%/*}
}

function get_version() {
  cat "$(get_project_dir)"/VERSION | sed 's/[\sv]//g'
}

function deletePreviousArtifacts() {
  find . -type f -name "$NAME*.xcframework" -exec rm {} +
  find . -type f -name "$NAME*.xcframework.zip" -exec rm {} +
  find . -type f -name "$NAME*.xcframework.zip.checksum" -exec rm {} +
  rm -rf .archives
}

function buildFramework() {
  xcodebuild archive \
    -project $XCODE_PROJECT \
    -scheme $SCHEME \
    -destination "$1" \
    -archivePath "$2" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
}

function createXCFramework() {
  xcodebuild \
    -create-xcframework \
    -framework ".archives/$NAME-iOS.xcarchive/Products/Library/Frameworks/CWasm3.framework" \
    -debug-symbols "$1/.archives/$NAME-iOS.xcarchive/BCSymbolMaps/9EDFC8DD-15A8-39FB-B396-190B0F458495.bcsymbolmap" \
    -debug-symbols "$1/.archives/$NAME-iOS.xcarchive/dSYMs/$NAME.framework.dSYM" \
    -framework ".archives/$NAME-iOS-Simulator.xcarchive/Products/Library/Frameworks/$NAME.framework" \
    -debug-symbols "$1/.archives/$NAME-iOS-Simulator.xcarchive/dSYMs/$NAME.framework.dSYM" \
    -framework ".archives/$NAME-macOS-Catalyst.xcarchive/Products/Library/Frameworks/$NAME.framework" \
    -debug-symbols "$1/.archives/$NAME-macOS-Catalyst.xcarchive/dSYMs/$NAME.framework.dSYM" \
    -framework ".archives/$NAME-macOS.xcarchive/Products/Library/Frameworks/$NAME.framework" \
    -debug-symbols "$1/.archives/$NAME-macOS.xcarchive/dSYMs/$NAME.framework.dSYM" \
    -output CWasm3.xcframework
}

function zipXCFramework() {
  ditto -c -k --sequesterRsrc --keepParent "$NAME.xcframework" "$1"
}

function createChecksum() {
  CHECKSUM=`swift package compute-checksum $1`
  
  echo "$CHECKSUM" > "$1.checksum"
  
  echo ""
  echo "🔒 $(swift package compute-checksum $1)"
}

VERSION="$(get_version)"

if [ -z "$VERSION" ]; then
    echo "❌️ Version must be set"
    exit -1
fi

PROJECT_DIR="$(get_project_dir)"
pushd "$PROJECT_DIR" &>/dev/null

deletePreviousArtifacts
mkdir .archives

buildFramework "generic/platform=iOS" ".archives/$NAME-iOS"
buildFramework "generic/platform=iOS Simulator" ".archives/$NAME-iOS-Simulator"
buildFramework "generic/platform=macOS,variant=Mac Catalyst" ".archives/$NAME-macOS-Catalyst"
buildFramework "generic/platform=macOS" ".archives/$NAME-macOS"
createXCFramework $PROJECT_DIR
ZIP_NAME="$NAME-$VERSION.xcframework.zip"
zipXCFramework $ZIP_NAME
createChecksum $ZIP_NAME
rm -rf "$NAME.xcframework"

popd &>/dev/null
