import String
import Testing

@Suite
struct `String edge cases` {

    static func codeUnits(_ value: borrowing String) -> [String.Char] {
        value.withUnsafeBufferPointer { buffer in Array(unsafe buffer) }
    }

    static func terminator(of value: borrowing String) -> String.Char {
        unsafe value.withUnsafePointer { pointer in unsafe pointer[value.count] }
    }

    @Test
    func `the empty literal has no code units and is still terminated`() {
        let value = String(ascii: "")
        #expect(value.count == 0)
        #expect(value.span.count == 0)
        #expect(Self.codeUnits(value).isEmpty)
        #expect(Self.terminator(of: value) == String.terminator)
    }

    @Test
    func `copying a borrowed view reproduces the code units and terminates them`() {
        let original = String(ascii: "hello world")
        let copy = String(copying: original.view)
        #expect(copy.count == original.count)
        #expect(Self.codeUnits(copy) == Self.codeUnits(original))
        #expect(Self.terminator(of: copy) == String.terminator)
    }

    @Test
    func `copying an empty view yields an empty terminated string`() {
        let original = String(ascii: "")
        let copy = String(copying: original.view)
        #expect(copy.count == 0)
        #expect(Self.terminator(of: copy) == String.terminator)
    }

    @Test
    func `a string rebuilt from a span equals its source`() {
        let original = String(ascii: "span")
        let rebuilt = String(original.span)
        #expect(Self.codeUnits(rebuilt) == [0x73, 0x70, 0x61, 0x6E] as [String.Char])
        #expect(Self.terminator(of: rebuilt) == String.terminator)
    }

    @Test
    func `taking the buffer hands over the code units and the terminator`() {
        let taken = unsafe String(ascii: "take").take()
        #expect(taken.count == 4)
        #expect(unsafe Array(UnsafeBufferPointer(start: taken.pointer, count: taken.count)) == [0x74, 0x61, 0x6B, 0x65] as [String.Char])
        #expect(unsafe taken.pointer[taken.count] == String.terminator)
        unsafe taken.pointer.deallocate()
    }

    @Test
    func `adopting a terminated buffer reports its length without the terminator`() {
        let buffer = UnsafeMutablePointer<String.Char>.allocate(capacity: 3)
        unsafe buffer.initialize(from: [String.Char(0x68), String.Char(0x69), String.terminator], count: 3)
        let adopted = unsafe String(adopting: buffer, count: 2)
        #expect(adopted.count == 2)
        #expect(Self.codeUnits(adopted) == [0x68, 0x69])
    }
}
