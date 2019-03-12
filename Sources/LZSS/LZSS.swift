//
//  LZSS.swift
//  LZSS
//

public struct LZSS {
	internal static let MinLength = 3
	internal static let MaxLength = 18
	internal static let BufferSize = 4096
	internal static let NIL = BufferSize
	internal static let BufferIndexMask = 4096 - 1
	
	@inlinable
	public static func decode<T: Sequence>(_ data: T) -> LZSSDecoder.Decoded where T.Element == LZSSDecoder.Element {
		var decoder = LZSSDecoder()
		decoder.decode(data)
		return decoder.finalize()
	}
	
	@inlinable
	public static func encode<T: Sequence>(_ data: T) -> LZSSEncoder.Encoded where T.Element == LZSSEncoder.Element {
		var decoder = LZSSEncoder()
		decoder.encode(data)
		return decoder.finalize()
	}
}
