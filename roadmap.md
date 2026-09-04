# Plain roadmap

## Next
- [ ] ASC name check (asc-name-creator), then app record + workflow ship-ios/ship-mac
- [ ] Line numbers (drop to NSTextView/UITextView via Representable)
- [ ] Current line highlight
- [ ] Latin-1 read fallback when UTF-8 decode fails

## Done
- 2026-09-03: v1.0.0 scaffold. DocumentGroup + TextEditor, iOS+macOS one target, CLI, Stats self-check.
- 2026-09-03: Markdown and code files save in place; UIFileSharingEnabled + LSSupportsOpeningDocumentsInPlace. Syntax highlighting for code/Markdown blocks via regex Highlighter. Local Ollama completion on macOS (⌘↩, qwen2.5-coder). Deployment target bumped to iOS 26/macOS 26. Completions stop at blank line.

## Known
- Title may show "Edited" right after opening a code/Markdown file (recolour on appear mutates the bound AttributedString). Cosmetic; unverified. Fix: skip the first recolour or diff attributes before writing.
