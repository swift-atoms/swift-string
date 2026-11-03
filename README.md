# swift-string

Use this package when you need to own, borrow or hand over a null-terminated platform string, the buffer a C or system API reads or returns: UTF-8 bytes on every platform except Windows, where it is UTF-16 code units. Start from `String`, a noncopyable owner of one heap buffer, and `String.Borrowed`, a non-escaping view over a buffer someone else owns; `Tagged<Tag, String>` gives the same operations to a string with a domain tag. For Unicode text that you compare, search or edit, use `Swift.String` instead.

## Laws

- Every buffer a `String` owns holds `count` code units followed by one `String.terminator`. `count` never includes the terminator, and this holds for the empty string too.
- `count` is stored, not scanned. A zero code unit inside the contents is kept, so `String.length(of:)` and C readers see a shorter string than `count` says.
- `String.length(of:)` scans with no bound until it finds `String.terminator`.
- `init(adopting:count:)` takes ownership of the pointer, which must have been allocated with `UnsafeMutablePointer.allocate`, because the owner frees it with `deallocate()`. The terminator at `pointer[count]` is checked only in debug builds.
- `take()` gives up ownership: the returned pointer still ends in its terminator, the `String` no longer frees it, and the caller must `deallocate()` it.
- `init(copying:)` and `init(_:)` from a span always allocate a new buffer of `count + 1` code units and write the terminator; they never share the source's memory.
- `init(ascii:)` traps in every build if the literal contains a byte of 0x80 or above.
- `String.Borrowed` checks its pointer for a terminator only in debug builds, and only within the first 16 MiB. It never checks that `count` matches where the terminator is.
