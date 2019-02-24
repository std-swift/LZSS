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
	targets: [
		.target(
			name: "LZSS",
			dependencies: []),
		.testTarget(
			name: "LZSSTests",
			dependencies: ["LZSS"]),
		.target(
			name: "LZSS-cli",
			dependencies: ["LZSS"]),
	]
)
