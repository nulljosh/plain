# Plain Technical Whitepaper

**v1.0.0** | September 2026

A text editor that writes no editor code. Every text editor on the App Store reinvents undo, autosave, and file handling badly, when the OS already ships all three, tested against millions of documents, for free. Plain exists to prove that a real editor needs almost none of its own code: it's a SwiftUI `DocumentGroup` around a `TextEditor`, shipped for macOS, iOS and iPadOS from one target, with a small command line tool that shares its only piece of logic.

## Core Mechanic: The Document Is a String

`TextDocument` conforms to `FileDocument`. It reads UTF-8 bytes into a `String` and writes them back out. That is the entire file model, because a plain text file has no structure worth modeling beyond its bytes; anything more would be building toward a feature the app doesn't have yet.

Everything a text editor is normally judged on comes from the framework, because the framework already solved it better than a rewrite would:

- Open, save, autosave, rename and Open Recent from `DocumentGroup`.
- Undo and redo, selection, find, dictation and VoiceOver from `TextEditor`, which is `NSTextView` on Mac and `UITextView` on iOS.
- iCloud Drive, document versions and the Files app from the document architecture.
- Window tabs on macOS, split view on iPad.

The app adds three things on top: a monospaced toggle, a font size stepper, and a status line, the minimum a writer actually asks for that the framework doesn't already give. All three are `@AppStorage` values and one `Text`.

## Stats

`Highlight.swift` colours code and Markdown with a handful of regexes over the `AttributedString` the iOS 26 `TextEditor` edits natively: one keyword list for every language, whole file recoloured per keystroke. `Complete.swift` is a single POST to Ollama on localhost with a fill-in-the-middle prompt, wired to ⌘↩ on the Mac. Neither touches how text is drawn.

Errors are surfaced, not swallowed: a completion that fails says why in the footer (Ollama down, model missing, bad reply), a file in any encoding opens, and a settings value of the wrong shape is ignored rather than crashing, because a text editor that crashes on a bad settings file or an odd encoding has failed at the one job it has. `PlainTests` covers stats, colouring, document round-trips, config parsing and the completion error path.

`Stats.swift` is the other logic. It counts lines, words and grapheme clusters. Grapheme, not UTF-16 units and not scalars, so a multi-codepoint emoji counts as one character, matching what a person actually sees rather than how Swift happens to store it. A trailing newline does not add a line. An empty file has one line.

`ios/Checks/main.swift` runs six asserts over it with `swiftc`, no test framework.

## Command Line

`cli/main.swift` compiles with `Stats.swift` into a single binary. `plain <file>` shells out to `open -a Plain`. `plain stat [file]` prints the counts, reading stdin when no path is given. It is deliberately not a terminal editor, that is a different product with different tradeoffs (its own key handling, its own rendering), and bolting one onto an app built around `DocumentGroup` would mean maintaining two editors instead of zero.

## Build

xcodegen `project.yml`, one target with `supportedDestinations: [iOS, macOS]`, chosen over separate targets because the app has no platform-specific logic to justify the split. Entitlements are split per SDK because `application-identifier` is not a valid macOS entitlement. No dependencies, since every dependency is a promise to keep updating something that isn't the editor.

## Not Here Yet

Line numbers, syntax highlighting, current line highlight, multiple encodings. Each needs dropping to `NSTextView` or `UITextView` directly, the exact escape hatch the core mechanic avoids. They come when a real file needs them, not before, since adding them speculatively is how every other text editor ended up big.

MIT. Joshua Trommel, 2026.
