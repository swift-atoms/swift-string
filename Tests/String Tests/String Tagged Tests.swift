import Span
import String
import Tagged
import Testing

@Suite
struct `String Tagged Tests` {

    private enum Name {}
    private enum Copy {}

    @Test
    func `tagged strings vend borrowed and span views`() {
        let name = Tagged<Name, String>(ascii: "swift")

        #expect(name.count == 5)
        #expect(name.view.count == 5)
        #expect(name.span.count == 5)
        #expect(name.span[0] == 115)
        #expect(name.span[4] == 116)
        #expect(elementCount(name) == 5)
    }

    @Test
    func `tagged strings copy borrowed storage across tags`() {
        let source = Tagged<Name, String>(ascii: "tag")
        let copy = Tagged<Copy, String>(copying: source.view)

        #expect(copy.count == 3)
        #expect(copy.span[0] == 116)
        #expect(copy.span[1] == 97)
        #expect(copy.span[2] == 103)
    }

    private func elementCount<S: __Span.`Protocol` & ~Copyable>(_ source: borrowing S) -> Int
    where S.Element == String.Char {
        source.span.count
    }
}
