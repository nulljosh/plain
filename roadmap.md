# Plain roadmap

## Next
- [ ] Line numbers (drop to NSTextView/UITextView via Representable)
- [ ] Current line highlight
- [ ] Extend IDE panes to iOS (currently macOS only)

## Ship (2026-09-12)
- [x] IDE feature set complete. File browser sidebar for directory navigation. Agent chat pane for asking Claude about code/document inline. Output pane for formatter feedback (prettier/black/swiftformat). Terminal pane with live REPL for the document's language (Python, JavaScript, Swift). Tree-sitter syntax highlighting foundation wired (currently using regex, tree-sitter parsed ready). On-save formatting integrated with graceful fallbacks. Landing page updated with IDE hero section. Whitepaper refreshed with "why" framing.

## Done
- 2026-09-03: v1.0.0 scaffold. DocumentGroup + TextEditor, iOS+macOS one target, CLI, Stats self-check.
- 2026-09-03: Markdown and code files save in place; UIFileSharingEnabled + LSSupportsOpeningDocumentsInPlace. Syntax highlighting for code/Markdown blocks via regex Highlighter. Local Ollama completion on macOS (⌘↩, qwen2.5-coder). Deployment target bumped to iOS 26/macOS 26. Completions stop at blank line.
- 2026-09-03: Landing page demo. Replaced static screenshot with a live textarea where visitors type, running the same line/word/grapheme counting logic as the native app in JavaScript. Uses Intl.Segmenter for proper grapheme handling. Styled inside device-mac chrome with real title bar and traffic lights. Deployed to plain.heyitsmejosh.com.

## Known
- Title shows "Edited" right after opening any file, plain .txt included, with no attribute mutation on our side (verified 2026-09-03). Comes from the iOS 26 AttributedString TextEditor inside DocumentGroup. Cosmetic. Retest on the next OS point release before working around it.

## Considered
- Rewrite the Mac app in C/C++/Rust. No. It is already native (SwiftUI over AppKit's text view); the language is not where time goes. Revisit only if a measured hot path appears.
- Web: type, edit and use Plain in the browser (a textarea plus the same regex colouring; keep the no-editor-code rule). Deferred; landing demo is sufficient for launch.
- [ ] native (kmp) port — sibling apps have one, this doesn't (project-sync 2026-09-05)
