//
//  LZSSTests.swift
//  LZSSTests
//

import XCTest
import LZSS

final class LZSSTests: XCTestCase {
	func testDecompressGreenEggsAndHam() {
		let input: [UInt8] = [                                       // 18 spaces for alignment
			0xFD,  32, 0xEE,0xFE, 73, 32, 97, 109, 32, 83,           // ' '(4078,17)'I am S'
			0xAF,  97, 109, 10, 10, 0x05,0x00, 32, 0x00,0x01, 10,    // 'am\n\n'(5,3)' '(0,4)'\n'
			0xDF,  10, 84, 104, 97, 116, 0x04,0x01, 45, 73,          // '\nThat'(4,4)'-I'
			0xEF,  45, 97, 109, 33, 0x13,0x0D, 73, 32, 100,          // '-am!'(19,16)'I d'
			0xFF,  111, 32, 110, 111, 116, 32, 108, 105,             // 'o not li'
			0xEF,  107, 101, 10, 116, 0x15,0x0B, 10, 68, 111,        // 'ke\nt'(21,14)'\nDo'
			0xEF,  32, 121, 111, 117, 0x3A,0x02, 32, 103, 114,       // ' you'(58,5)' gr'
			0xFF,  101, 101, 110, 32, 101, 103, 103, 115,            // 'een eggs'
			0xFF,  32, 97, 110, 100, 32, 104, 97, 109,               // ' and ham'
			0xF7,  63, 10, 10, 0x32,0x0A, 32, 116, 104, 101,         // '?\n\n'(49,13)' the'
			0x4B,  109, 44, 0x18,0x06, 46, 0x70,0x0C, 0x5C,0x0F, 46, // 'm,'(24,9)'.'(112,15)(92,18)'.'
		]
		
		let output = #"""
		                  I am Sam
		
		Sam I am
		
		That Sam-I-am!
		That Sam-I-am!
		I do not like
		that Sam-I-am!
		
		Do you like green eggs and ham?

		I do not like them, Sam-I-am.
		I do not like green eggs and ham.
		"""#
		
		let decompressed = LZSS.decode(input)
			.map { Character(UnicodeScalar($0)) }
		XCTAssertEqual(String(decompressed), output)
	}
	
	func testCompressGreenEggsAndHam() {
		let source = #"""
		                  I am Sam
		
		Sam I am
		
		That Sam-I-am!
		That Sam-I-am!
		I do not like
		that Sam-I-am!
		
		Do you like green eggs and ham?
		
		I do not like them, Sam-I-am.
		I do not like green eggs and ham.
		"""#
		
		var encoder = LZSSEncoder()
		encoder.encode(source.utf8)
		let compressed = encoder.finalize()
		XCTAssertEqual(compressed.count, 106) // Compression amount check
		
		let decompressed = LZSS.decode(compressed)
			.map { Character(UnicodeScalar($0)) }
		XCTAssertEqual(String(decompressed), source)
		XCTAssertEqual(decompressed.count, 194)
		XCTAssertLessThan(compressed.count, decompressed.count)
	}
	
	func testPartialEncoding() {
		let source = "I am SamSam I amThat Sam-I-am!That Sam-I-am!I do not like"
		var encoder = LZSSEncoder()
		encoder.encode(source.utf8)
		let output = encoder.finalize()
		XCTAssertLessThan(output.count, source.count)
		
		let partialSources = stride(from: 0, to: source.count, by: 5)
			.map { start -> String in
				let end = min(start + 5, source.count)
				let startIndex = source.index(source.startIndex, offsetBy: start)
				let endIndex = source.index(source.startIndex, offsetBy: end)
				return String(source[startIndex..<endIndex])
		}
		var encoder2 = LZSSEncoder()
		let partialOutputs = partialSources
			.map { encoder2.encodePartial($0.utf8) } + [encoder2.finalize()]
		let finalOutput = partialOutputs.reduce([], +)
		XCTAssertEqual(finalOutput, output)
	}
	
	func testPartialDecoding() {
		let source = "I am SamSam I amThat Sam-I-am!That Sam-I-am!I do not like"
		var encoder = LZSSEncoder()
		encoder.encode(source.utf8)
		let output = encoder.finalize()
		XCTAssertLessThan(output.count, source.count)
		
		let partialOutputs = stride(from: 0, to: output.count, by: 5)
			.map { Array(output[$0..<min($0 + 5, output.count)]) }
		var decoder = LZSSDecoder()
		let partialSources = partialOutputs.map { decoder.decodePartial($0) }
		
		let outputSource = partialSources.reduce([], +)
			.map { Character(UnicodeScalar($0)) }
		XCTAssertEqual(String(outputSource), source)
	}
	
	func testLargeStream() {
		var encoder = LZSSEncoder()
		var decoder = LZSSDecoder()
		
		var inputLength = 0
		var outputLength = 0
		
		for _ in 0..<100 {
			inputLength += 100
			let input = String(repeating: "A", count: 100)
			let encoded = encoder.encodePartial(input.utf8)
			let decoded = decoder.decodePartial(encoded)
			let output = String(decoded.map { Character(UnicodeScalar($0)) })
			outputLength += output.count
			XCTAssert(output.allSatisfy { $0 == "A" })
		}
		
		let encoded = encoder.finalize()
		let decoded = decoder.decodePartial(encoded)
		let output = String(decoded.map { Character(UnicodeScalar($0)) })
		outputLength += output.count
		XCTAssert(output.allSatisfy { $0 == "A" })
		
		XCTAssertEqual(outputLength, inputLength)
	}
	
	func testEncodePerformance() {
		let input = String(repeating: "A", count: 100_000)
		
		measure {
			var encoder = LZSSEncoder()
			encoder.encode(input.utf8)
			_ = encoder.finalize()
		}
	}
	
	func testDecodePerformance() {
		let input = String(repeating: "A", count: 100_000)
		var encoder = LZSSEncoder()
		encoder.encode(input.utf8)
		let encoded = encoder.finalize()
		
		measure {
			var decoder = LZSSDecoder()
			decoder.decode(encoded)
			_ = decoder.finalize()
		}
	}
}
