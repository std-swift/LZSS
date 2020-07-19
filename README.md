# LZSS

[![](https://img.shields.io/badge/Swift-5.1--5.3-orange.svg)][1]
[![](https://img.shields.io/badge/os-macOS%20|%20Linux-lightgray.svg)][1]
[![](https://travis-ci.com/std-swift/LZSS.svg?branch=master)][2]
[![](https://codecov.io/gh/std-swift/LZSS/branch/master/graph/badge.svg)][3]
[![](https://codebeat.co/badges/a3c6ce7f-d7ee-495a-855a-45c802dfc0d4)][4]

[1]: https://swift.org/download/#releases
[2]: https://travis-ci.com/std-swift/LZSS
[3]: https://codecov.io/gh/std-swift/LZSS
[4]: https://codebeat.co/projects/github-com-std-swift-lzss-master

LZSS compression

## Importing

Add the following line to the dependencies in your `Package.swift` file:

```Swift
.package(url: "https://github.com/std-swift/LZSS.git", from: "3.0.0")
```

Add `Encoding` as a dependency for your target:

```swift
.product(name: "LZSS", package: "LZSS"),
```

and finally,

```Swift
import LZSS
```
