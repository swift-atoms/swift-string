import Span
import String
import Testing

@Suite("String × Span")
struct String_Span_Tests {

    static func count<R: Span.`Protocol` & ~Copyable>(
        _ region: borrowing R
    ) -> Int {
        region.span.count
    }

    @Test
    func `String satisfies Span Protocol`() {
        let value = String(ascii: "hello")
        #expect(Self.count(value) == 5)
    }

    @Test
    func `String span exposes its code units`() {
        let value = String(ascii: "span")
        let span = value.span

        #expect(span.count == 4)
        #expect(span[0] == String.Char(115))
        #expect(span[3] == String.Char(110))
    }
}
