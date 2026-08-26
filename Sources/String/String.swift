#if STRING_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import Memory_Heap
    public import Span_Protocol

    @safe
    public struct String: ~Copyable, Sendable {

        @usableFromInline
        internal let _storage: Memory.Heap
    }

    extension String {

        @inlinable
        public var count: Int {
            let byteCount = Int(bitPattern: _storage.capacity)
            return byteCount / MemoryLayout<Char>.stride
        }
    }

    extension String {

        @inlinable
        public init(adopting pointer: UnsafeMutablePointer<String.Char>, count: Int) {
            #if DEBUG
                precondition(
                    unsafe pointer[count] == Self.terminator,
                    "String: adopted buffer must be null-terminated"
                )
            #endif
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(pointer),
                capacity: Memory.Address.Count(UInt(count) * UInt(MemoryLayout<Char>.stride))
            )
        }

        @inlinable
        public init(copying view: borrowing String.Borrowed) {
            let length = view.count
            let buffer = UnsafeMutablePointer<String.Char>.allocate(capacity: length + 1)
            unsafe buffer.initialize(from: view.pointer, count: length)
            (unsafe buffer)[length] = Self.terminator
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(buffer),
                capacity: Memory.Address.Count(UInt(length) * UInt(MemoryLayout<Char>.stride))
            )
        }

        @inlinable
        public init(_ span: Swift.Span<Char>) {
            let length = span.count
            let buffer = UnsafeMutablePointer<Char>.allocate(capacity: length + 1)
            (0..<length).forEach { i in (unsafe buffer)[i] = span[i] }
            (unsafe buffer)[length] = Self.terminator
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(buffer),
                capacity: Memory.Address.Count(UInt(length) * UInt(MemoryLayout<Char>.stride))
            )
        }

        @inlinable
        public init(ascii literal: StaticString) {
            let length = literal.utf8CodeUnitCount
            let buffer = UnsafeMutablePointer<String.Char>.allocate(capacity: length + 1)
            literal.withUTF8Buffer { utf8 in
                (0..<length).forEach { i in
                    let byte = unsafe utf8[i]
                    precondition(
                        byte < 0x80,
                        "String.init(ascii:): literal contains non-ASCII byte 0x\(Swift.String(byte, radix: 16, uppercase: true)) at index \(i)"
                    )
                    (unsafe buffer)[i] = Self.Char(byte)
                }
            }
            (unsafe buffer)[length] = Self.terminator
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(buffer),
                capacity: Memory.Address.Count(UInt(length) * UInt(MemoryLayout<Char>.stride))
            )
        }

    }

    extension String {

        @unsafe
        @inlinable
        package var _base: UnsafePointer<Char> {

            unsafe UnsafePointer(_storage.unsafeBaseAddress.assumingMemoryBound(to: Char.self))
        }

        @unsafe
        @inlinable
        public borrowing func withUnsafePointer<R: ~Copyable, E: Swift.Error>(
            _ body: (UnsafePointer<String.Char>) throws(E) -> R
        ) throws(E) -> R {
            try unsafe body(_base)
        }

        @unsafe
        @inlinable
        public var unsafeBaseAddress: UnsafePointer<String.Char> {
            unsafe _base
        }

        @inlinable
        public var view: String.Borrowed {
            @_lifetime(borrow self) borrowing get {
                let view = unsafe Self.Borrowed(_base, count: count)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }

        @inlinable
        public var span: Swift.Span<String.Char> {
            @_lifetime(borrow self) borrowing get {
                let s = unsafe Swift.Span(_unsafeStart: _base, count: count)
                return unsafe _overrideLifetime(s, borrowing: self)
            }
        }
    }

    extension String {

        @unsafe
        @inlinable
        public consuming func take() -> (pointer: UnsafeMutablePointer<String.Char>, count: Int) {

            let (raw, byteCapacity) = unsafe _storage.take()
            let byteCount = Int(bitPattern: byteCapacity)
            return unsafe (
                raw.assumingMemoryBound(to: Char.self),
                byteCount / MemoryLayout<Char>.stride
            )
        }
    }

    extension String: Span.`Protocol` {}

    extension String {

        @inlinable
        public func withUnsafeBufferPointer<R, E: Swift.Error>(
            _ body: (UnsafeBufferPointer<Char>) throws(E) -> R
        ) throws(E) -> R {
            try unsafe body(UnsafeBufferPointer(start: _base, count: count))
        }
    }

#endif
