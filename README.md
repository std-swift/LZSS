# LZSS

[![](https://img.shields.io/badge/Swift-5.0-orange.svg)][1]
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

```Swift
import LZSS
```

```Swift
dependencies: [
	.package(url: "https://github.com/std-swift/LZSS.git",
	         from: "1.0.0")
],
targets: [
	.target(
		name: "",
		dependencies: [
			"LZSS"
		]),
]
```

## Using

### `LZSS`

```Swift
LZSS.decode(_ data: Sequence) -> [UInt8]
LZSS.encode(_ data: Sequence) -> [UInt8]
```

### `LZSSDecoder`

```Swift
mutating func decodePartial<T: Sequence>(_ data: T) where T.Element == UInt8
mutating func decode<T: Sequence>(_ data: T) -> [UInt8] where T.Element == UInt8
mutating func finalize() -> [UInt8]
```

### `LZSSEncoder`

```Swift
mutating func encodePartial<T: Sequence>(_ data: T) where T.Element == UInt8
mutating func encode<T: Sequence>(_ data: T) -> [UInt8] where T.Element == UInt8
mutating func finalize() -> [UInt8]
```
