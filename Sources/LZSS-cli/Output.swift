//
//  Output.swift
//  LZSS-cli
//

#if os(macOS)
import Darwin.C.stdlib
#endif

#if os(Linux)
import SwiftGlibc.C.stdlib
#endif

struct Stream: TextOutputStream {
	private let file: UnsafeMutablePointer<FILE>
	
	fileprivate init(_ file: UnsafeMutablePointer<FILE>) {
		self.file = file
	}
	
	func write(_ string: String) {
		fputs(string, self.file)
	}
}

var ErrorStream = Stream(stderr)
