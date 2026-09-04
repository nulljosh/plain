import SwiftUI

struct EditorView: View {
    @Binding var document: TextDocument
    @AppStorage("monospaced") private var monospaced = false
    @AppStorage("fontSize") private var fontSize = 15.0
    @State private var text = AttributedString()
    @State private var selection = AttributedTextSelection()
    @State private var completing = false

    private var highlighter: Highlighter { Highlighter(type: document.type, size: fontSize, monospaced: monospaced) }

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .onAppear { text = AttributedString(document.text); recolor() }
            // Colour lives in the view; the document stays a String.
            .onChange(of: text) { if String(text.characters) != document.text { document.text = String(text.characters); recolor() } }
            .onChange(of: document.text) { if String(text.characters) != document.text { text = AttributedString(document.text); recolor() } }  // undo, revert, iCloud
            .onChange(of: fontSize) { recolor() }
            .onChange(of: monospaced) { recolor() }
            .lineSpacing(fontSize * 0.25)
            .autocorrectionDisabled()
            #if os(iOS)
            .textInputAutocapitalization(.never)
            .scrollDismissesKeyboard(.interactively)
            #endif
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .safeAreaInset(edge: .bottom) { footer }
            .toolbar { toolbar }
    }

    // Ask the local model to fill in at the cursor. Inserts at wherever the cursor is when the answer arrives.
    private func complete() {
        guard !completing, case .insertionPoint(let i) = selection.indices(in: text) else { return }
        let s = String(text.characters)
        let k = s.index(s.startIndex, offsetBy: text.characters.distance(from: text.startIndex, to: i))
        completing = true
        Task {
            defer { completing = false }
            guard let out = try? await Complete.fill(prefix: String(s[..<k]), suffix: String(s[k...])), !out.isEmpty,
                  case .insertionPoint(let j) = selection.indices(in: text) else { return }
            text.transform(updating: &selection) { $0.insert(AttributedString(out), at: j) }
        }
    }

    private func recolor() {
        let h = highlighter
        text.transform(updating: &selection) { h.apply(&$0) }
    }

    private var footer: some View {
        Text(Stats(document.text).summary)
            .font(.footnote.monospacedDigit())
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.bar)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup {
            #if os(macOS)
            if document.type.kind == .code {
                Button(action: complete) { Label("Complete", systemImage: completing ? "ellipsis" : "text.append") }
                    .help("Complete at cursor with the local model (⌘↩)")
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(completing)
            }
            #endif
            Toggle(isOn: $monospaced) { Label("Monospaced", systemImage: "textformat") }
                .help("Monospaced font")
                .keyboardShortcut("m", modifiers: [.command, .shift])
            Button { fontSize = max(9, fontSize - 1) } label: { Label("Smaller", systemImage: "textformat.size.smaller") }
                .help("Smaller text")
                .keyboardShortcut("-", modifiers: .command)
            Button { fontSize = min(40, fontSize + 1) } label: { Label("Bigger", systemImage: "textformat.size.larger") }
                .help("Bigger text")
                .keyboardShortcut("=", modifiers: .command)
            Button { fontSize = 15 } label: { Label("Actual Size", systemImage: "textformat.size") }
                .help("Reset text size")
                .keyboardShortcut("0", modifiers: .command)
        }
    }
}
