//
//  LZSSDecoder.swift
//  LZSS
//

/// A queue decoder. Data is stored in input and output queues.
public struct LZSSDecoder {
	private var inputQueue = [UInt8]()
	private var outputQueue = [UInt8]()
	
	private var flags = 0
	private var bufferIndex = LZSS.BufferSize - LZSS.MaxLength
	private var buffer = [UInt8](repeating: 32, count: LZSS.BufferSize) // Space
	
	public init() {}
	
	/// Add `data` to the decoding queue and decode as much as possible to the
	/// output queue
	public mutating func decodePartial<T: Sequence>(_ data: T) where T.Element == UInt8 {
		self.inputQueue.append(contentsOf: data)
		self.decodeStep()
	}
	
	/// Add `data` to the decoding queue and return everything that can be
	/// decoded
	public mutating func decode<T: Sequence>(_ data: T) -> [UInt8] where T.Element == UInt8 {
		self.inputQueue.append(contentsOf: data)
		self.decodeStep()
		defer { self.outputQueue = [] }
		return self.outputQueue
	}
	
	/// Stop buffering input data and encode the remaining buffer
	public mutating func finalize() -> [UInt8] {
		defer { self.outputQueue = [] }
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
		self.inputQueue = []
	}
}
