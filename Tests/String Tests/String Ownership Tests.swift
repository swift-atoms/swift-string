import Ownership
import String
import Testing

@Suite("String × Ownership")
struct String_Ownership_Tests {

    static func acceptsBorrowProtocol<R: Ownership.Borrow.`Protocol` & ~Copyable>(
        _ value: borrowing R
    ) -> Bool {
        true
    }

    static func borrowedType(
        of value: borrowing String
    ) -> String.Borrowed.Type {
        func resolve<R: Ownership.Borrow.`Protocol` & ~Copyable>(
            _ value: borrowing R
        ) -> R.Borrowed.Type {
            R.Borrowed.self
        }

        return resolve(value)
    }

    @Test
    func `String satisfies Ownership Borrow Protocol`() {
        let value = String(ascii: "borrow")
        let accepted = Self.acceptsBorrowProtocol(value)
        #expect(accepted)
    }

    @Test
    func `String conformance selects String Borrowed`() {
        let value = String(ascii: "view")
        _ = Self.borrowedType(of: value)

        let view = value.view
        #expect(view.count == 4)
        #expect(view.span[0] == String.Char(118))
    }
}
