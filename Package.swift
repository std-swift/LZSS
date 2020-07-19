// swift-tools-version:5.1
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
		.package(url: "https://github.com/std-swift/Encoding.git", from: "2.0.0")
	],
	targets: [
		.target(
			name: "LZSS",
			dependencies: [
				.product(name: "Encoding", package: "Encoding"),
			]),
		.testTarget(
			name: "LZSSTests",
			dependencies: ["LZSS"]),
		.target(
			name: "LZSS-cli",
			dependencies: ["LZSS"]),
	]
)
