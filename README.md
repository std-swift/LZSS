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
	         from: "2.0.0")
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

- `LZSSDecoder: StreamDecoder` with `UInt8` elements
- `LZSSEncoder: StreamEncoder` with `UInt8` elements

### `LZSS`

```Swift
LZSS.decode(_ data: Sequence) -> LZSSDecoder.Decoded
LZSS.encode(_ data: Sequence) -> LZSSEncoder.Encoded
```
