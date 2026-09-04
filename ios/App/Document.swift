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
    var type: UTType = .plainText

    init() {}

    init(data: Data, type: UTType) {
        // UTF-8 first; anything else decodes with replacement characters, so opening never fails on encoding.
        text = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        self.type = type
    }

    var data: Data {
        if type.conforms(to: .json) { Config.apply(text) }   // saving the settings file applies it
        return Data(text.utf8)
    }

    init(configuration: ReadConfiguration) throws {
        // A directory or a symlink has no regular contents; say so instead of showing an empty editor.
        guard let d = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        self.init(data: d, type: configuration.contentType)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
