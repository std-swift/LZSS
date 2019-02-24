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
	
	public static func decode<T: Sequence>(_ data: T) -> [UInt8] where T.Element == UInt8 {
		var decoder = LZSSDecoder()
		decoder.decodePartial(data)
		return decoder.finalize()
	}
	
	public static func encode<T: Sequence>(_ data: T) -> [UInt8] where T.Element == UInt8 {
		var decoder = LZSSEncoder()
		decoder.encodePartial(data)
		return decoder.finalize()
	}
}
