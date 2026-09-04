import SwiftUI

#if os(macOS)
final class AppDelegate: NSObject, NSApplicationDelegate {
    // Empty launch opens the settings file instead of Untitled.
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        NSDocumentController.shared.openDocument(withContentsOf: Config.url, display: true) { _, _, _ in }
        return false
    }
    func applicationDidBecomeActive(_ notification: Notification) { Config.load() }
}
#endif

@main
struct PlainApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    #endif
    init() { Config.load() }

    var body: some Scene {
        // DocumentGroup: File menu, Open Recent, tabs, autosave, undo. No code for any of it.
        DocumentGroup(newDocument: TextDocument()) { file in
            EditorView(document: file.$document)
        }
        .defaultSize(width: 720, height: 640)
    }
}
