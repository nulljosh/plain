import SwiftUI

struct EditorView: View {
    @Binding var document: TextDocument
    @AppStorage("monospaced") private var monospaced = false
    @AppStorage("fontSize") private var fontSize = 15.0

    var body: some View {
        TextEditor(text: $document.text)
            .font(.system(size: fontSize, design: monospaced ? .monospaced : .default))
            .autocorrectionDisabled()
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 8)
            .safeAreaInset(edge: .bottom) {
                Text(Stats(document.text).summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.bar)
            }
            .toolbar {
                ToolbarItemGroup {
                    Toggle(isOn: $monospaced) { Label("Monospaced", systemImage: "textformat") }
                    Button { fontSize = max(9, fontSize - 1) } label: { Label("Smaller", systemImage: "textformat.size.smaller") }
                    Button { fontSize = min(40, fontSize + 1) } label: { Label("Bigger", systemImage: "textformat.size.larger") }
                }
            }
    }
}
