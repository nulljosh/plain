# Plain Technical Whitepaper

**v1.0.0** | September 2026

A text editor that writes no editor code. Plain is a SwiftUI `DocumentGroup` around a `TextEditor`, shipped for macOS, iOS and iPadOS from one target, with a small command line tool that shares its only piece of logic.

## Core Mechanic: The Document Is a String

`TextDocument` conforms to `FileDocument`. It reads UTF-8 bytes into a `String` and writes them back out. That is the entire file model.

Everything a text editor is normally judged on comes from the framework:

- Open, save, autosave, rename and Open Recent from `DocumentGroup`.
- Undo and redo, selection, find, dictation and VoiceOver from `TextEditor`, which is `NSTextView` on Mac and `UITextView` on iOS.
- iCloud Drive, document versions and the Files app from the document architecture.
- Window tabs on macOS, split view on iPad.

The app adds three things on top: a monospaced toggle, a font size stepper, and a status line. All three are `@AppStorage` values and one `Text`.

## Stats

`Highlight.swift` colours code and Markdown with a handful of regexes over the `AttributedString` the iOS 26 `TextEditor` edits natively: one keyword list for every language, whole file recoloured per keystroke. `Complete.swift` is a single POST to Ollama on localhost with a fill-in-the-middle prompt, wired to ⌘↩ on the Mac. Neither touches how text is drawn.

`Stats.swift` is the other logic. It counts lines, words and grapheme clusters. Grapheme, not UTF-16 units and not scalars, so a multi-codepoint emoji counts as one character. A trailing newline does not add a line. An empty file has one line.

`ios/Checks/main.swift` runs six asserts over it with `swiftc`, no test framework.

## Command Line

`cli/main.swift` compiles with `Stats.swift` into a single binary. `plain <file>` shells out to `open -a Plain`. `plain stat [file]` prints the counts, reading stdin when no path is given. It is deliberately not a terminal editor; that is a different product.

## Build

xcodegen `project.yml`, one target with `supportedDestinations: [iOS, macOS]`. Entitlements are split per SDK because `application-identifier` is not a valid macOS entitlement. No dependencies.

## Not Here Yet

Line numbers, syntax highlighting, current line highlight, multiple encodings. Each needs dropping to `NSTextView` or `UITextView` directly. They come when a real file needs them.

MIT. Joshua Trommel, 2026.
