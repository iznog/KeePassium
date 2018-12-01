//
//  ByteArray.swift
//  KeePassium
//
//  Created by Andrei Popleteev on 2018-03-29.
//  Copyright © 2018 Andrei Popleteev. All rights reserved.
//

import Foundation

/// [UInt8] as a reference type.
/// Fills itself with zeros before destruction.
public class ByteArray: Eraseable {
    
    public class InputStream {
        fileprivate let base: Foundation.InputStream
        var hasBytesAvailable: Bool { return base.hasBytesAvailable }
        
        fileprivate init(data: Data) {
            base = Foundation.InputStream(data: data)
        }
        
        func open() {
            base.open()
        }
        func close() {
            base.close()
        }
        
        func read(count: Int) -> ByteArray? {
            let out = ByteArray(count: count)

            var bytesRead = 0
            while bytesRead < count {
                let remainingCount = count - bytesRead
                let n = out.withMutableBytes { (bytes: inout [UInt8]) in
                    return base.read(&bytes + bytesRead, maxLength: remainingCount)
                }
                guard n > 0 else {
                    print("Stream reading problem")
                    return nil
                }
                bytesRead += n
            }
            return out
        }
//        func readString(count: Int, using encoding: String.Encoding = .utf8) -> String? {
//            guard let data = read(count: count) else { return nil }
//            return data.toString(using: encoding)
//        }
        func readUInt8() -> UInt8? {
            let data = self.read(count: MemoryLayout<UInt8>.size)
            return UInt8(data: data)
        }
        func readUInt16() -> UInt16? {
            let data = self.read(count: MemoryLayout<UInt16>.size)
            return UInt16(data: data)
        }
        func readUInt32() -> UInt32? {
            let data = self.read(count: MemoryLayout<UInt32>.size)
            return UInt32(data: data)
        }
        func readInt8() -> Int8? {
            let data = self.read(count: MemoryLayout<Int8>.size)
            return Int8(data: data)
        }
        func readInt16() -> Int16? {
            let data = self.read(count: MemoryLayout<Int16>.size)
            return Int16(data: data)
        }
        func readInt32() -> Int32? {
            let data = self.read(count: MemoryLayout<Int32>.size)
            return Int32(data: data)
        }
    }
    public class OutputStream {
        private let base: Foundation.OutputStream
        fileprivate init() {
            base = Foundation.OutputStream(toMemory: ())
        }
        public func open() {
            base.open()
        }
        public func close() {
            base.close()
        }
        var data: ByteArray? {
            if let data = base.property(forKey: .dataWrittenToMemoryStreamKey) as? Data {
                return ByteArray(data: data)
            } else {
                return nil
            }
        }

        @discardableResult
        func write<T: FixedWidthInteger>(value: T) -> Int {
            return write(data: value.data)
        }
        @discardableResult
        func write(data: ByteArray) -> Int {
            guard data.count > 0 else { return 0 } // to avoid undefined behavior in base.write()
            
            let writtenCount = data.withBytes { bytes in
                return base.write(bytes, maxLength: bytes.count)
            }
            assert(writtenCount == data.count, "Written \(writtenCount) bytes instead of \(data.count) requested")
            return writtenCount
        }
    }
    
    // MARK: ByteArray
    fileprivate var bytes: [UInt8]
    
    public var isEmpty: Bool { return bytes.isEmpty }
    public var count: Int { return bytes.count }
    public var sha256: ByteArray { return CryptoManager.sha256(of: self) }
    public var sha512: ByteArray { return CryptoManager.sha512(of: self) }
    public var asData: Data { return Data(bytes: self.bytes) }
    
    subscript (index: Int) -> UInt8 {
        get { return bytes[index] }
        set { bytes[index] = newValue }
    }
    subscript (range: CountableRange<Int>) -> ByteArray {
        return ByteArray(bytes: self.bytes[range])
    }

    public init() {
        bytes = []
    }
    public init(data: Data) {
        let bytes = data.withUnsafeBytes{ (pointer: UnsafePointer<UInt8>) -> [UInt8] in
            let buffer = UnsafeBufferPointer(start: pointer, count: data.count)
            return Array<UInt8>(buffer)
        }
        self.bytes = bytes
    }
    public init(bytes: [UInt8]) {
        self.bytes = [UInt8](bytes)
    }
    public init(bytes: ArraySlice<UInt8>) {
        self.bytes = [UInt8](bytes)
    }
    /// Creates an instance filled with `count` zeroes.
    convenience public init(count: Int) {
        self.init(bytes: [UInt8](repeating: 0, count: count))
    }
    convenience public init(capacity: Int) {
        self.init()
        bytes.reserveCapacity(capacity)
    }
    convenience public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        self.init(data: data)
    }
    convenience public init?(utf8String: String) {
        guard let data = utf8String.data(using: .utf8) else { return nil }
        self.init(data: data)
    }
    convenience public init?(base64Encoded: String?) {
        if let base64Encoded = base64Encoded {
            guard let data = Data(base64Encoded: base64Encoded) else { return nil }
            self.init(data: data)
        } else {
            return nil
        }
    }
    
    /// Tries to create a ByteArray from a hex-encoded string. (From https://stackoverflow.com/a/40278391)
    convenience public init?(hexString string: String) {
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }
        
        self.init()
        bytes.reserveCapacity(string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                bytes.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
    
    deinit {
        erase()
    }
    
    /// Returns a deep copy of this ByteArray
    public func clone() -> ByteArray {
        return ByteArray(bytes: self.bytes)
    }
    public func bytesCopy() -> [UInt8] {
        return Array<UInt8>(bytes)
    }
    
    public func erase() {
        for i in 0..<count {
            bytes[i] = 0
        }
    }
    
    
    /// Returns data contents as hex string. (From https://stackoverflow.com/a/40089462)
    public var asHexString: String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self.bytes {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    
    public func prefix(_ maxLength: Int) -> ByteArray {
        return ByteArray(bytes: self.bytes.prefix(maxLength))
    }
    public func prefix(upTo: Int) -> ByteArray {
        return ByteArray(bytes: self.bytes.prefix(upTo: upTo))
    }
    public func suffix(from: Int) -> ByteArray {
        return ByteArray(bytes: self.bytes.suffix(from: from))
    }
    
    /// Shortens the array to first `toCount` bytes at most.
    /// Safely erases eventual leftovers.
    public func trim(toCount newCount: Int) {
        if (newCount < 0) || (bytes.count <= newCount) { return }
        
        for i in newCount..<bytes.count {
            bytes[i] = 0
        }
        bytes.removeLast(bytes.count - newCount)
    }
    
    /// Concatenates given arrays into one
    public static func concat(_ arrays: ByteArray...) -> ByteArray {
        var totalSize = 0
        for arr in arrays {
            totalSize += arr.count
        }
        var buffer = [UInt8]()
        buffer.reserveCapacity(totalSize)
        for arr in arrays {
            buffer.append(contentsOf: arr.bytes)
        }
        return ByteArray(bytes: buffer)
    }
    
    public func append(_ value: UInt8) {
        bytes.append(value)
    }
    public func append(bytes: Array<UInt8>) {
        self.bytes.append(contentsOf: bytes)
    }
    public func append(_ another: ByteArray) {
        self.bytes.append(contentsOf: another.bytes)
    }
    
    public func write(to url: URL, options: Data.WritingOptions) throws {
        try asData.write(to: url, options: options)
    }
    
    @discardableResult
    public func withBytes<TResult>(_ body: ([UInt8]) -> TResult) -> TResult {
        return body(bytes)
    }
    @discardableResult
    public func withMutableBytes<TResult>(_ body: (inout [UInt8]) -> TResult) -> TResult {
        return body(&bytes)
    }

    
    public func base64EncodedString() -> String {
        return Data(bytes: bytes).base64EncodedString()
    }
    
    /// Tries to convert byte array into a string
    /// using given encoding (or UTF-8 by default).
    public func toString(using encoding: String.Encoding = .utf8) -> String? {
        return String(bytes: self.bytes, encoding: encoding)
    }
    
    public func asInputStream() -> ByteArray.InputStream {
        return ByteArray.InputStream(data: Data(bytes: self.bytes))
    }
    public static func makeOutputStream() -> ByteArray.OutputStream {
        return ByteArray.OutputStream()
    }
    
    public func gunzipped() throws -> ByteArray {
        return try ByteArray(data: Data(bytes: self.bytes).gunzipped())
    }
    public func gzipped() throws -> ByteArray {
        return try ByteArray(data: Data(bytes: self.bytes).gzipped(level: .bestCompression))
    }
    
    /// Checks if data consists only of given byte value.
    public func containsOnly(_ value: UInt8) -> Bool {
        for i in 0..<bytes.count {
            if bytes[i] != value {
                return false
            }
        }
        return true
    }
}

extension ByteArray: Equatable {
    public static func ==(lhs: ByteArray, rhs: ByteArray) -> Bool {
        return lhs.bytes == rhs.bytes
    }
}

/// ByteArray locked to physical memory (no paging to disk).
/// The size is fixed on init; trying to append/trim will throw a runtime error.
public class SecureByteArray: ByteArray {
    override public var sha256: SecureByteArray { return SecureByteArray(CryptoManager.sha256(of: self)) }

    override convenience public init() {
        self.init(bytes: [])
    }
    convenience public init(_ source: ByteArray) {
        self.init(bytes: source.bytesCopy())
    }
    override private init(bytes: [UInt8]) {
        super.init(bytes: bytes)
        self.bytes.withUnsafeBufferPointer { (ptr) -> Void in
            mlock(ptr.baseAddress, ptr.count)
        }
    }
    override public init(data: Data) {
        super.init(data: data)
        self.bytes.withUnsafeBufferPointer { (ptr) -> Void in
            mlock(ptr.baseAddress, ptr.count)
        }
    }
    deinit {
        self.bytes.withUnsafeBufferPointer { (ptr) -> Void in
            munlock(ptr.baseAddress, ptr.count)
        }
    }
    
    public func secureClone() -> SecureByteArray {
        return SecureByteArray(self)
    }
    
    /// Concatenates given arrays into one
    public static func concat(_ arrays: SecureByteArray...) -> SecureByteArray {
        var totalSize = 0
        for arr in arrays {
            totalSize += arr.count
        }
        var buffer = [UInt8]()
        buffer.reserveCapacity(totalSize)
        for arr in arrays {
            buffer.append(contentsOf: arr.bytes)
        }
        return SecureByteArray(bytes: buffer)
    }

    override public func append(_ byte: UInt8) {
        fatalError("Cannot change immutable array")
    }
    override public func append(_ another: ByteArray) {
        fatalError("Cannot change immutable array")
        //TODO: need to do that (fails on kp2 - AES key derivation). maybe reallocate?
    }
    override public func trim(toCount newCount: Int) {
        fatalError("Cannot change immutable array")
    }
}
