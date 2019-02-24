//
//  main.swift
//  LZSS-cli
//

#if os(macOS)
import Darwin.C.stdlib
#endif

#if os(Linux)
import SwiftGlibc.C.stdlib
#endif

import LZSS

private let READ_SIZE = 4096

private var inputCount = 0
private var outputCount = 0

private var input = [UInt8]()
private var output = [UInt8]()

func ReadInput() -> Bool {
	input.removeAll(keepingCapacity: true)
	repeat {
		let next = getc(stdin)
		if next == EOF { break }
		input.append(UInt8(truncatingIfNeeded: next))
	} while input.count < input.capacity
	inputCount += input.count
	return input.count > 0
}

func WriteOutput() {
	for byte in output {
		fputc(Int32(byte), stdout)
	}
	outputCount += output.count
	output = []
}

private func encode() {
	var encoder = LZSSEncoder()
	while true {
		guard ReadInput() else { break }
		output = encoder.encode(input)
		WriteOutput()
	}
	output = encoder.finalize()
	WriteOutput()
}

private func decode() {
	var decoder = LZSSDecoder()
	while true {
		guard ReadInput() else { break }
		output = decoder.decode(input)
		WriteOutput()
	}
	output = decoder.finalize()
	WriteOutput()
}

private func printUsage(_ exitStatus: Int32) -> Never {
	print("Usage: lzss [ed]", to: &ErrorStream)
	exit(exitStatus)
}

private func main<T: Collection>(_ arguments: T) -> Never where T.Element == String {
	guard arguments.count == 1 else {
		printUsage(EXIT_FAILURE)
	}
	
	input.reserveCapacity(READ_SIZE)
	
	switch arguments.first! {
		case "e": encode()
		case "d": decode()
		case "-h", "--help": printUsage(EXIT_SUCCESS)
		default:             printUsage(EXIT_FAILURE)
	}
	
	print("Total Read: \(inputCount)", to: &ErrorStream)
	print("Total Write: \(outputCount)", to: &ErrorStream)
	
	exit(EXIT_SUCCESS)
}

let arguments = CommandLine.arguments.dropFirst()
main(arguments)
