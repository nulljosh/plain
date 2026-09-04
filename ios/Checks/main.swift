// Self-check. swiftc -o /tmp/plaincheck ios/App/Stats.swift ios/App/Highlight.swift ios/App/Complete.swift ios/Checks/main.swift && /tmp/plaincheck
import Foundation
import SwiftUI
import UniformTypeIdentifiers

func check(_ c: Bool, _ l: String) { if !c { print("FAIL: \(l)"); exit(1) } }

check(Stats("") == Stats(lines: 1, words: 0, characters: 0), "empty")
check(Stats("hello world") == Stats(lines: 1, words: 2, characters: 11), "one line")
check(Stats("a\nb\n").lines == 2, "trailing newline does not add a line")
check(Stats("a\n\nb").lines == 3, "blank line counts")
check(Stats("🍋‍🟩").characters == 1, "grapheme cluster is one char")
check(Stats("  two\twords  ").words == 2, "whitespace split")

var a = AttributedString("let x = 1 // hi")
Highlighter(type: .swiftSource, size: 15, monospaced: false).apply(&a)
let runs = a.runs.map { (String(a.characters[$0.range]), $0.foregroundColor) }
check(runs.first?.0 == "let" && runs.first?.1 == .pink, "keyword coloured")
check(runs.last?.0 == "// hi" && runs.last?.1 == .secondary, "comment coloured")
var m = AttributedString("# Title\n`x`")
Highlighter(type: .markdown, size: 15, monospaced: false).apply(&m)
check(m.runs.first.map { String(m.characters[$0.range]) } == "# Title", "heading run")
var t = AttributedString("let x")
Highlighter(type: .plainText, size: 15, monospaced: false).apply(&t)
check(t.runs.count == 1 && t.runs.first?.foregroundColor == nil, "plain text untouched")

// Completion: only when Ollama is up, so the check still passes on a machine without it.
if (try? Data(contentsOf: URL(string: "http://localhost:11434/api/version")!)) != nil {
    let sem = DispatchSemaphore(value: 0)
    Task {
        let out = try? await Complete.fill(prefix: "func add(a: Int, b: Int) -> Int {\n    ", suffix: "\n}")
        check(out?.contains("a + b") == true, "completion fills the middle: \(out ?? "nil")")
        sem.signal()
    }
    sem.wait()
}
print("ok")
