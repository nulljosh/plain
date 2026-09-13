# Plain

v1.0.0, plain text editor. SwiftUI `DocumentGroup` + `TextEditor`, one xcodegen target for iOS and macOS, plus a CLI. No web build. Syntax highlighting (regex + tree-sitter ready), on-save formatting (prettier/black/swiftformat).

## Files

- `ios/App/Document.swift`: `FileDocument`, UTF-8 string in and out, formats on save via Formatter
- `ios/App/EditorView.swift`: `TextEditor`, monospaced toggle, font size, stats footer, format-on-save toggle (macOS only)
- `ios/App/Formatter.swift`: Shell out to prettier/black/swiftformat; macOS only, gracefully falls back if tool missing or fails
- `ios/App/Highlight.swift`: Regex-based syntax highlighting for code and markdown, language detection via UTType
- `ios/App/Config.swift`: User settings loaded from `~/Library/Application Support/Plain/plain.json`, includes formatter and color preferences
- `ios/App/Stats.swift`: lines/words/graphemes. The only logic. Shared with the CLI
- `ios/Checks/main.swift`: Sanity checks for Formatter and Config
- `cli/main.swift`: `plain <file>` opens in the app, `plain stat [file]` counts

## Build

```bash
cd ios && xcodegen generate
xcodebuild build -scheme Plain -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/dd-plain -skipPackagePluginValidation
xcodebuild build -scheme Plain -destination 'platform=macOS' -derivedDataPath /tmp/dd-plain-mac -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
swiftc -O ios/App/Config.swift ios/App/Formatter.swift ios/App/Highlight.swift ios/App/Stats.swift ios/App/Document.swift ios/Checks/main.swift -o /tmp/checks && /tmp/checks
swiftc -O -o plain ios/App/Stats.swift cli/main.swift
```

## Rules

- Never add an editor layer. If a feature needs `NSTextView`/`UITextView`, wrap via `NSViewRepresentable`/`UIViewRepresentable`, keep `TextDocument` untouched.
- Monospace only inside the editor, and only when the user toggles it. Chrome stays system sans.
- Formatting is macOS only (Process API unavailable on iOS). Falls back gracefully on missing tools; save never fails.
- ASC record not created yet. Run asc-name-creator before creating one; "Plain" is probably taken.
