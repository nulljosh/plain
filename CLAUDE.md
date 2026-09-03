# Plain

v1.0.0, plain text editor. SwiftUI `DocumentGroup` + `TextEditor`, one xcodegen target for iOS and macOS, plus a CLI. No web build.

## Files

- `ios/App/Document.swift`: `FileDocument`, UTF-8 string in and out
- `ios/App/EditorView.swift`: `TextEditor`, monospaced toggle, font size, stats footer
- `ios/App/Stats.swift`: lines/words/graphemes. The only logic. Shared with the CLI
- `ios/Checks/main.swift`: asserts over Stats
- `cli/main.swift`: `plain <file>` opens in the app, `plain stat [file]` counts

## Build

```bash
cd ios && xcodegen generate
xcodebuild build -scheme Plain -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/dd-plain -skipPackagePluginValidation
xcodebuild build -scheme Plain -destination 'platform=macOS' -derivedDataPath /tmp/dd-plain-mac -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
swiftc -o /tmp/plaincheck ios/App/Stats.swift ios/Checks/main.swift && /tmp/plaincheck
swiftc -O -o plain ios/App/Stats.swift cli/main.swift
```

## Rules

- Never add an editor layer. If a feature needs `NSTextView`/`UITextView`, wrap via `NSViewRepresentable`/`UIViewRepresentable`, keep `TextDocument` untouched.
- Monospace only inside the editor, and only when the user toggles it. Chrome stays system sans.
- ASC record not created yet. Run asc-name-creator before creating one; "Plain" is probably taken.
