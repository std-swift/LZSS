//
//  LZSSDecoder.swift
//  LZSS
//

import Encoding

public struct LZSSDecoder: StreamDecoder {
	public typealias Element = UInt8
	public typealias Partial = [Element]
	public typealias Decoded = [Element]
	
	private var inputQueue = [UInt8]()
	private var outputQueue = [UInt8]()
	
	private var flags = 0
	private var bufferIndex = LZSS.BufferSize - LZSS.MaxLength
	private var buffer = [UInt8](repeating: 32, count: LZSS.BufferSize) // Space
	
	public init() {}

	public mutating func decode<T: Sequence>(_ elements: T) where T.Element == Element {
		self.inputQueue.append(contentsOf: elements)
		self.decodeStep()
	}
	
	public mutating func decodePartial<T: Sequence>(_ elements: T) -> Partial where T.Element == Element {
		self.inputQueue.append(contentsOf: elements)
		self.decodeStep()
		defer { self.outputQueue.removeAll(keepingCapacity: true) }
		return self.outputQueue
	}
	
	public mutating func finalize() -> Decoded {
		defer { self.outputQueue.removeAll(keepingCapacity: true) }
		return self.outputQueue
	}
	
	private mutating func setBuffer(_ value: UInt8) {
		self.buffer[self.bufferIndex] = value
		self.bufferIndex = (self.bufferIndex + 1) & LZSS.BufferIndexMask
	}
	
	private mutating func decodeStep() {
		var iterator = self.inputQueue.makeIterator()
		while let next = iterator.next() {
			if self.flags & 0x100 == 0 {
				self.flags = Int(next) | 0xFF00
				continue
			}
			
			if self.flags & 1 != 0 {
				self.outputQueue.append(next)
				self.setBuffer(next)
			} else {
				guard let second = iterator.next() else {
					self.inputQueue = [next]
					return
				}
				let offset = Int(next) | ((Int(second) & 0xF0) << 4)
				let length = (Int(second) & 0x0F) + LZSS.MinLength
				for index in offset..<(offset + length) {
					let c = self.buffer[index & LZSS.BufferIndexMask]
					self.outputQueue.append(c)
					self.setBuffer(c)
				}
			}
			
			self.flags >>= 1
		}
		self.inputQueue.removeAll(keepingCapacity: true)
	}
}