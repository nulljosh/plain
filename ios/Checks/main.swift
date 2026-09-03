// Stats self-check. swiftc -o /tmp/plaincheck ios/App/Stats.swift ios/Checks/main.swift && /tmp/plaincheck
import Foundation

func check(_ c: Bool, _ l: String) { if !c { print("FAIL: \(l)"); exit(1) } }

check(Stats("") == Stats(lines: 1, words: 0, characters: 0), "empty")
check(Stats("hello world") == Stats(lines: 1, words: 2, characters: 11), "one line")
check(Stats("a\nb\n").lines == 2, "trailing newline does not add a line")
check(Stats("a\n\nb").lines == 3, "blank line counts")
check(Stats("🍋‍🟩").characters == 1, "grapheme cluster is one char")
check(Stats("  two\twords  ").words == 2, "whitespace split")
print("ok")
