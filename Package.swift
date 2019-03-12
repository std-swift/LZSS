// swift-tools-version:5.0
//
//  Package.swift
//  LZSS
//

import PackageDescription

let package = Package(
	name: "LZSS",
	products: [
		.library(
			name: "LZSS",
			targets: ["LZSS"]),
		.executable(
			name: "lzss",
			targets: ["LZSS-cli"]),
	],
	dependencies: [
		.package(url: "https://github.com/std-swift/Encoding.git",
		         from: "1.1.0")
	],
	targets: [
		.target(
			name: "LZSS",
			dependencies: ["Encoding"]),
		.testTarget(
			name: "LZSSTests",
			dependencies: ["LZSS"]),
		.target(
			name: "LZSS-cli",
			dependencies: ["LZSS"]),
	]
)
