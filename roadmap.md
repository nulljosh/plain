# Plain roadmap

## Next
- [ ] ASC name check (asc-name-creator), then app record + workflow ship-ios/ship-mac
- [ ] Line numbers (drop to NSTextView/UITextView via Representable)
- [ ] Current line highlight
- [ ] Latin-1 read fallback when UTF-8 decode fails

## Done
- 2026-09-03: v1.0.0 scaffold. DocumentGroup + TextEditor, iOS+macOS one target, CLI, Stats self-check.
- 2026-09-03: Markdown and code files save in place; UIFileSharingEnabled + LSSupportsOpeningDocumentsInPlace. Syntax highlighting for code/Markdown blocks via regex Highlighter. Local Ollama completion on macOS (⌘↩, qwen2.5-coder). Deployment target bumped to iOS 26/macOS 26. Completions stop at blank line.
- 2026-09-03: Landing page demo. Replaced static screenshot with a live textarea where visitors type, running the same line/word/grapheme counting logic as the native app in JavaScript. Uses Intl.Segmenter for proper grapheme handling. Styled inside device-mac chrome with real title bar and traffic lights. Deployed to plain.heyitsmejosh.com.

## Known
- Title shows "Edited" right after opening any file, plain .txt included, with no attribute mutation on our side (verified 2026-09-03). Comes from the iOS 26 AttributedString TextEditor inside DocumentGroup. Cosmetic. Retest on the next OS point release before working around it.

## Considered
- Rewrite the Mac app in C/C++/Rust. No. It is already native (SwiftUI over AppKit's text view); the language is not where time goes. Revisit only if a measured hot path appears.
- Web: type, edit and use Plain in the browser (a textarea plus the same regex colouring; keep the no-editor-code rule). Deferred; landing demo is sufficient for launch.
