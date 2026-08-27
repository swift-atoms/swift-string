#if STRING_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension String {

        @safe
        public struct Borrowed: ~Copyable, ~Escapable {

            public let pointer: UnsafePointer<Char>

            public let count: Int

            @inlinable
            @_lifetime(borrow pointer)
            public init(_ pointer: UnsafePointer<String.Char>, count: Int) {
                #if DEBUG
                    unsafe Self.debugValidateTermination(pointer)
                #endif
                unsafe (self.pointer = pointer)
                self.count = count
            }
        }
    }

    #if DEBUG
        extension String.Borrowed {

            @usableFromInline
            internal static let maxDebugScanLength = 16 * 1024 * 1024

            @unsafe
            @usableFromInline
            internal static func debugValidateTermination(_ pointer: UnsafePointer<String.Char>) {
                var current = unsafe pointer
                var scanned = 0
                while scanned < maxDebugScanLength {
                    if unsafe current.pointee == String.terminator {
                        return
                    }
                    unsafe (current = current.successor())
                    scanned += 1
                }
                assertionFailure(
                    "String.Borrowed: pointer does not appear to be null-terminated within \(maxDebugScanLength) bytes"
                )
            }
        }
    #endif

    extension String.Borrowed {

        @unsafe
        @inlinable
        public borrowing func withUnsafePointer<R: ~Copyable, E: Swift.Error>(
            _ body: (UnsafePointer<String.Char>) throws(E) -> R
        ) throws(E) -> R {
            try unsafe body(pointer)
        }

        @inlinable
        public var length: Int { count }

        @inlinable
        public var span: Swift.Span<String.Char> {
            @_lifetime(copy self) borrowing get {
                let span = unsafe Span(_unsafeStart: pointer, count: count)
                return unsafe _overrideLifetime(span, copying: self)
            }
        }
    }

#endif
