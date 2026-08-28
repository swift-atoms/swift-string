#if STRING_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import Tagged
    public import Span_Protocol

    extension Tagged where Underlying == String, Tag: ~Copyable & ~Escapable {

        public typealias CodeUnit = String.CodeUnit
    }

    extension Tagged where Underlying == String, Tag: ~Copyable & ~Escapable {

        @inlinable
        public static var terminator: String.Char { String.terminator }

        @unsafe
        @inlinable
        public static func length(of pointer: UnsafePointer<String.Char>) -> Int {
            unsafe String.length(of: pointer)
        }
    }

    extension Tagged where Underlying == String, Tag: ~Copyable & ~Escapable {

        @inlinable
        public init(adopting pointer: UnsafeMutablePointer<String.Char>, count: Int) {
            unsafe self.init(_unchecked: String(adopting: pointer, count: count))
        }

        @inlinable
        public init(copying view: borrowing String.Borrowed) {
            self.init(_unchecked: String(copying: view))
        }

        @inlinable
        public init(ascii literal: StaticString) {
            self.init(_unchecked: String(ascii: literal))
        }
    }

    extension Tagged where Underlying == String, Tag: ~Copyable & ~Escapable {

        @inlinable
        public var count: Int { underlying.count }

        @inlinable
        public var span: Swift.Span<String.Char> {
            @_lifetime(borrow self) borrowing get {
                let pointer = unsafe underlying.unsafeBaseAddress
                let count = underlying.count
                let span = unsafe Swift.Span(_unsafeStart: pointer, count: count)
                return unsafe _overrideLifetime(span, borrowing: self)
            }
        }
    }

    extension Tagged where Underlying == String, Tag: ~Copyable & ~Escapable {

        @unsafe
        @inlinable
        public consuming func take() -> (pointer: UnsafeMutablePointer<String.Char>, count: Int) {
            var captured: (pointer: UnsafeMutablePointer<String.Char>, count: Int)? = nil
            _ = Self.map(self) { (str: consuming String) -> Bool in
                unsafe (captured = str.take())
                return true
            }
            guard let result = unsafe captured else {
                fatalError("Tagged<_, String>.take(): map did not invoke its transform")
            }
            return unsafe result
        }
    }

    extension Tagged: @retroactive Span.`Protocol`
    where Underlying == String, Tag: ~Copyable & ~Escapable {}

    extension Tagged where Underlying == String, Tag: ~Copyable & ~Escapable {

        @inlinable
        public func withUnsafeBufferPointer<R, E: Swift.Error>(
            _ body: (UnsafeBufferPointer<String.Char>) throws(E) -> R
        ) throws(E) -> R {
            try unsafe underlying.withUnsafeBufferPointer(body)
        }
    }

#endif
