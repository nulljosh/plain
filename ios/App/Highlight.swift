// Colour for code and Markdown. Attributes on the string; the system still draws it.
// ponytail: one keyword list for every language, whole file recoloured per keystroke.
// Per-language grammars and incremental recolour only if a real file lags.

import SwiftUI
import UniformTypeIdentifiers

enum Kind { case text, code, markdown }

extension UTType {
    static let markdown = UTType("net.daringfireball.markdown") ?? .plainText
    var kind: Kind {
        if conforms(to: .markdown) { return .markdown }
        if conforms(to: .sourceCode) || conforms(to: .script) || conforms(to: .json) { return .code }
        return .text
    }
    var hashComments: Bool {
        [UTType.pythonScript, .shellScript, .rubyScript, .perlScript, .yaml].contains { conforms(to: $0) }
    }
}

private let keywords = try! Regex(#"\b(?:as|async|await|break|case|catch|class|const|continue|def|default|defer|do|elif|else|enum|export|extension|false|fn|for|from|func|function|guard|if|impl|import|in|init|interface|is|let|match|mod|mut|new|nil|none|not|null|or|and|package|private|protocol|pub|public|return|self|static|struct|super|switch|this|throw|throws|true|try|type|typealias|use|var|void|where|while|yield)\b"#)
private let numbers  = try! Regex(#"\b\d[\w.]*"#)
private let strings  = try! Regex(#""(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*'|`[^`\n]*`"#)
private let slashComments = try! Regex(#"//.*|/\*[\s\S]*?\*/"#)
private let poundComments = try! Regex(#"#.*"#)

private let heading  = try! Regex(#"(?m)^#{1,6} .*$"#)
private let bold     = try! Regex(#"\*\*[^*\n]+\*\*|__[^_\n]+__"#)
// The trailing negative lookaheads keep italic from also matching inside bold:
// `(?!\*)` stops `*text*` from firing on the second `*` of `**text**`, and
// `(?!\w)` stops `_text_` from firing inside `snake_case_word`.
private let italic   = try! Regex(#"\*[^*\n]+\*(?!\*)|_[^_\n]+_(?!\w)"#)
private let code     = try! Regex(#"```[\s\S]*?```|`[^`\n]+`"#)
private let link     = try! Regex(#"\[[^\]\n]*\]\([^)\n]*\)"#)
private let marker   = try! Regex(#"(?m)^\s*(?:[-*+]|\d+\.|>) "#)

struct Highlighter {
    var type: UTType
    var size: Double
    var monospaced: Bool

    func apply(_ a: inout AttributedString) {
        if type.kind == .text { return }   // plain text: never touch attributes
        let base = Font.system(size: size, design: monospaced ? .monospaced : .default)
        a.font = base
        a.foregroundColor = nil
        let s = String(a.characters)
        func paint(_ r: some RegexComponent, _ color: Color? = nil, _ font: Font? = nil) {
            for m in s.matches(of: r) {
                guard let range = Range(m.range, in: a) else { continue }
                if let color { a[range].foregroundColor = color }
                if let font { a[range].font = font }
            }
        }
        switch type.kind {
        case .code:
            paint(keywords, Config.color("keywordColor"))
            paint(numbers, Config.color("numberColor"))
            paint(strings, Config.color("stringColor"))
            paint(type.hashComments ? poundComments : slashComments, Config.color("commentColor"))
        case .text: break
        case .markdown:
            paint(marker, Config.color("linkColor"))
            paint(link, Config.color("linkColor"))
            paint(italic, nil, base.italic())
            paint(bold, nil, base.bold())
            paint(heading, nil, base.bold())
            paint(code, Config.color("commentColor"), .system(size: size, design: .monospaced))
        }
    }
}
