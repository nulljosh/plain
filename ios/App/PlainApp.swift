import SwiftUI

@main
struct PlainApp: App {
    var body: some Scene {
        // DocumentGroup: File menu, Open Recent, tabs, autosave, undo. No code for any of it.
        DocumentGroup(newDocument: TextDocument()) { file in
            EditorView(document: file.$document)
        }
        .defaultSize(width: 720, height: 640)
    }
}
