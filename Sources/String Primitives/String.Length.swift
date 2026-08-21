#if STRING_PRIMITIVES_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension String {

        @unsafe
        @inlinable
        public static func length(of pointer: UnsafePointer<Char>) -> Int {
            var current = unsafe pointer
            while unsafe current.pointee != terminator {
                unsafe (current = current.successor())
            }
            return unsafe current - pointer
        }
    }

#endif
