import SwiftUI

struct EditorView: View {
    @Binding var document: TextDocument
    @AppStorage("monospaced") private var monospaced = false
    @AppStorage("fontSize") private var fontSize = 15.0

    var body: some View {
        TextEditor(text: $document.text)
            .font(.system(size: fontSize, design: monospaced ? .monospaced : .default))
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
