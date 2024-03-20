# diff-match-patch-objc

A library to make it easy to create an XCFramework from [Google's diff-match-patch library](https://github.com/google/diff-match-patch). 

It's important to be able to generate an XCFramework from DiffMatchPatchObjC because Google's diff-match-patch Objective-C code uses manual memory management. Swift Packages using the `-fno-objc-arc` "unsafe" C flag cannot be added to Swift Packages consumed by Xcode.

## Usage

To use the XCFramework, copy the URL to DiffMatchPatchObjC-X.X.X.xcframework.zip from the release of DiffMatchPatchObjC you want to consume. Also, copy the related checksum from the release. Add the following to your Swift package's targets array:

```swift
.binaryTarget(
  name: "DiffMatchPatchObjC",
  url: "URL",
  checksum: "CHECKSUM"
)
```

## License

Google's original library is licensed under the [Apache 2.0 license](https://github.com/google/diff-match-patch/blob/master/LICENSE). Accordingly, this library is also licensed under the same license.
