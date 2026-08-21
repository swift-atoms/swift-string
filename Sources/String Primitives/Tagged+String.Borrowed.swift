#if STRING_PRIMITIVES_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import Tagged_Primitives

    extension Tagged where Underlying == String, Tag: ~Copyable & ~Escapable {

        @inlinable
        public var view: String.Borrowed {
            @_lifetime(borrow self) borrowing get {
                let pointer = unsafe underlying.unsafeBaseAddress
                let count = underlying.count
                let borrowed = unsafe String.Borrowed(pointer, count: count)
                return unsafe _overrideLifetime(borrowed, borrowing: self)
            }
        }
    }

#endif
