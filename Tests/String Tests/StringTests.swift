import Testing

@testable import String

@Suite
struct `String Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `String Tests`.Unit {
    @Test
    func `length of empty string`() {
        let empty: [String.Char] = [String.terminator]
        unsafe empty.withUnsafeBufferPointer { buffer in
            let length = unsafe String.length(of: buffer.baseAddress!)
            #expect(length == 0)
        }
    }

    @Test
    func `length of non-empty string`() {

        let hello: [String.Char] = [
            104, 101, 108, 108, 111, String.terminator,
        ]
        unsafe hello.withUnsafeBufferPointer { buffer in
            let length = unsafe String.length(of: buffer.baseAddress!)
            #expect(length == 5)
        }
    }
}
