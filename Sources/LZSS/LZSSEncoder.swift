//
//  LZSSEncoder.swift
//  LZSS
//

public struct LZSSEncoder {
	private var inputQueue = [UInt8]()
	private var outputQueue = [UInt8]()
	
	private var index = 0
	private var bufferIndex = LZSS.BufferSize - LZSS.MaxLength
	private var codeBuffer = [0] + [UInt8](repeating: 32, count: 16) // Space
	private var buffer = [UInt8](repeating: 32, count: LZSS.BufferSize + LZSS.MaxLength - 1) // Space
	
	private var match_length = 0
	private var match_position = 0
	
	private var treeParent = [Int](repeating: LZSS.NIL, count: LZSS.BufferSize + 1)
	private var treeLeft   = [Int](repeating: LZSS.NIL, count: LZSS.BufferSize + 1)
	private var treeRight  = [Int](repeating: LZSS.NIL, count: LZSS.BufferSize + 257)
	
	private var length = 0
	private var lastMatchLength = 0
	private var codeBufferIndex = 1
	
	private var mask: UInt8 = 1
	
	public init() {}
	
	/// Add `data` to the decoding queue and decode as much as possible to the
	/// output queue
	public mutating func encodePartial<T: Sequence>(_ data: T) where T.Element == UInt8 {
		self.inputQueue.append(contentsOf: data)
		self.encodeStep(final: false)
	}
	
	/// Add `data` to the decoding queue and return everything that can be
	/// decoded
	public mutating func encode<T: Sequence>(_ data: T) -> [UInt8] where T.Element == UInt8 {
		self.inputQueue.append(contentsOf: data)
		self.encodeStep(final: false)
		defer { self.outputQueue.removeAll(keepingCapacity: true) }
		return self.outputQueue
	}
	
	/// Stop buffering input data and encode the remaining buffer
	public mutating func finalize() -> [UInt8] {
		self.encodeStep(final: true)
		defer { self.outputQueue.removeAll(keepingCapacity: true) }
		return self.outputQueue
	}
	
	private enum State {
		case firstBuffer
		case afterFirstBuffer
		case topOfLoop
		case loopBuffer
		case afterLoopBuffer
		case done
	}
	private var state = State.firstBuffer
	private var bufferingCount = 0
	
	private mutating func encodeStep(final: Bool) {
		var iterator = self.inputQueue.makeIterator()
		defer { self.inputQueue = Array(iterator) }
		while true {
			switch self.state {
			case .firstBuffer:
				while self.length < LZSS.MaxLength, let c = iterator.next() {
					self.buffer[self.bufferIndex + self.length] = c
					self.length += 1
				}
				if self.length == LZSS.MaxLength || final {
					self.state = .afterFirstBuffer
				} else {
					return
				}
			case .afterFirstBuffer:
				for i in 1...LZSS.MaxLength { self.InsertNode(self.bufferIndex - i) }
				self.InsertNode(self.bufferIndex)
				self.state = .topOfLoop
			case .topOfLoop:
				if self.match_length > self.length { self.match_length = self.length }
				if self.match_length < LZSS.MinLength {
					self.match_length = 1
					self.codeBuffer[0] |= self.mask
					self.codeBuffer[self.codeBufferIndex] = self.buffer[self.bufferIndex]
					self.codeBufferIndex += 1
				} else {
					self.codeBuffer[self.codeBufferIndex] = UInt8(truncatingIfNeeded: self.match_position)
					self.codeBufferIndex += 1
					self.codeBuffer[self.codeBufferIndex] = UInt8(((self.match_position >> 4) & 0xF0) | (self.match_length - LZSS.MinLength))
					self.codeBufferIndex += 1
				}
				self.mask <<= 1
				if self.mask == 0 {
					self.outputQueue.append(contentsOf: self.codeBuffer.prefix(self.codeBufferIndex))
					self.codeBuffer[0] = 0
					self.codeBufferIndex =  1
					self.mask = 1
				}
				self.lastMatchLength = self.match_length
				self.bufferingCount = 0
				self.state = .loopBuffer
			case .loopBuffer:
				while self.bufferingCount < self.lastMatchLength, let c = iterator.next() {
					self.DeleteNode(self.index)
					self.buffer[self.index] = c
					if self.index < LZSS.MaxLength - 1 {
						self.buffer[self.index + LZSS.BufferSize] = c
					}
					self.index = (self.index + 1) & LZSS.BufferIndexMask
					self.bufferIndex = (self.bufferIndex + 1) & LZSS.BufferIndexMask
					InsertNode(self.bufferIndex)
					self.bufferingCount += 1
				}
				if self.bufferingCount == self.lastMatchLength {
					self.state = .topOfLoop
				} else if final {
					self.state = .afterLoopBuffer
				} else {
					return
				}
			case .afterLoopBuffer:
				for _ in self.bufferingCount..<self.lastMatchLength {
					self.DeleteNode(self.index)
					self.index = (self.index + 1) & LZSS.BufferIndexMask
					self.bufferIndex = (self.bufferIndex + 1) & LZSS.BufferIndexMask
					self.length -= 1
					if self.length != 0 {
						self.InsertNode(self.bufferIndex)
					}
				}
				if self.length > 0 {
					self.state = .topOfLoop
				} else {
					self.state = .done
				}
			case .done:
				if self.codeBufferIndex > 1 {
					self.outputQueue.append(contentsOf: self.codeBuffer.prefix(self.codeBufferIndex))
				}
				return
			}
		}
	}
	
	private mutating func InsertNode(_ r: Int) {
		self.match_length = 0
		self.treeRight[r] = LZSS.NIL
		self.treeLeft[r] = LZSS.NIL
		
		var p = LZSS.BufferSize + 1 + Int(self.buffer[r])
		
		var cmp = 1
		while true {
			if cmp >= 0 {
				if self.treeRight[p] != LZSS.NIL {
					p = self.treeRight[p]
				} else {
					self.treeRight[p] = r
					self.treeParent[r] = p
					return
				}
			} else {
				if self.treeLeft[p] != LZSS.NIL {
					p = self.treeLeft[p]
				} else {
					self.treeLeft[p] = r
					self.treeParent[r] = p
					return
				}
			}
			var i = 1
			while i < LZSS.MaxLength {
				cmp = Int(self.buffer[r + i]) - Int(self.buffer[p + i])
				if cmp != 0 { break }
				i += 1
			}
			if i > self.match_length {
				self.match_position = p
				self.match_length = i
				if self.match_length >= LZSS.MaxLength { break }
			}
		}
		self.treeParent[r] = self.treeParent[p]
		self.treeLeft[r] = self.treeLeft[p]
		self.treeRight[r] = self.treeRight[p]
		self.treeParent[self.treeLeft[p]] = r
		self.treeParent[self.treeRight[p]] = r
		if self.treeRight[self.treeParent[p]] == p {
			self.treeRight[self.treeParent[p]] = r
		} else {
			self.treeLeft[self.treeParent[p]] = r
		}
		self.treeParent[p] = LZSS.NIL
	}
	
	private mutating func DeleteNode(_ p: Int) {
		var q = 0
		
		if self.treeParent[p] == LZSS.NIL { return }
		if self.treeRight[p] == LZSS.NIL {
			q = self.treeLeft[p]
		} else if self.treeLeft[p] == LZSS.NIL {
			q = self.treeRight[p]
		} else {
			q = self.treeLeft[p]
			if self.treeRight[q] != LZSS.NIL {
				repeat {
					q = self.treeRight[q]
				} while self.treeRight[q] != LZSS.NIL
				self.treeRight[self.treeParent[q]] = self.treeLeft[q]
				self.treeParent[self.treeLeft[q]] = self.treeParent[q]
				self.treeLeft[q] = self.treeLeft[p]
				self.treeParent[self.treeLeft[p]] = q
			}
			self.treeRight[q] = self.treeRight[p]
			self.treeParent[self.treeRight[p]] = q
		}
		self.treeParent[q] = self.treeParent[p]
		if self.treeRight[self.treeParent[p]] == p {
			self.treeRight[self.treeParent[p]] = q
		} else {
			self.treeLeft[self.treeParent[p]] = q
		}
		self.treeParent[p] = LZSS.NIL
	}
}
