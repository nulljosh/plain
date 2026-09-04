// A file is a String. FileDocument gives open, save, autosave, rename, iCloud,
// versions and the recent-files menu for free. That is the whole point.

import SwiftUI
import UniformTypeIdentifiers

struct TextDocument: FileDocument {
    // Markdown and code conform to plain text, so they open; listing them as writable
    // is what keeps a .md or .swift file editable in place instead of read-only.
    static var readableContentTypes: [UTType] { [.plainText, .sourceCode, .text] }
    static var writableContentTypes: [UTType] { readableContentTypes }

    var text = ""

    init() {}

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        // ponytail: UTF-8 or bust. Latin-1 fallback is the only other encoding worth adding.
        guard let s = String(data: data, encoding: .utf8) else { throw CocoaError(.fileReadInapplicableStringEncoding) }
        text = s
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
