#if STRING_PRIMITIVES_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension String {

        #if STRING_PRIMITIVES_AVAILABLE && os(Windows)

            public typealias Char = UInt16

            public typealias Codec = Unicode.UTF16
        #else

            public typealias Char = UInt8

            public typealias Codec = Unicode.UTF8
        #endif

        public typealias CodeUnit = Char

        @inlinable
        public static var terminator: Char { 0 }
    }

#endif
