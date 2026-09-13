// File browser sidebar. Lists git ls-files from repo root. Click to open in new tab.
// ponytail: static list, reads once on appear. Re-scan if user navigates. macOS only.

import SwiftUI
import Foundation

#if os(macOS)
struct FileListView: View {
    @Binding var document: TextDocument
    @State private var files: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            Text("Files")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.bar)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(files, id: \.self) { file in
                        FileRow(path: file, action: { openFile(file) })
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
        }
        .frame(minWidth: 120, maxWidth: 200)
        .onAppear { loadFiles() }
    }

    private func loadFiles() {
        guard let root = gitRoot() else { return }
        let task = Process()
        task.currentDirectoryURL = URL(fileURLWithPath: root)
        task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        task.arguments = ["ls-files"]
        let pipe = Pipe()
        task.standardOutput = pipe
        guard (try? task.run()) != nil else { return }
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        files = String(data: data, encoding: .utf8)?
            .split(separator: "\n")
            .map(String.init)
            .sorted() ?? []
    }

    private func openFile(_ path: String) {
        guard let root = gitRoot() else { return }
        let fileURL = URL(fileURLWithPath: root).appendingPathComponent(path)
        NSDocumentController.shared.openDocument(withContentsOf: fileURL, display: true) { _, _, _ in }
    }

    private func gitRoot() -> String? {
        var dir = FileManager.default.currentDirectoryPath
        while dir != "/" {
            if FileManager.default.fileExists(atPath: "\(dir)/.git") { return dir }
            dir = (dir as NSString).deletingLastPathComponent
        }
        return nil
    }
}
#endif

#if os(macOS)
private struct FileRow: View {
    let path: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(path.split(separator: "/").last.map(String.init) ?? path)
                    .lineLimit(1)
                    .font(.caption)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
        }
        .buttonStyle(.plain)
        .help(path)
    }

    private var iconName: String {
        let ext = (path as NSString).pathExtension
        switch ext {
        case "swift": return "s.square"
        case "py": return "p.square"
        case "js", "ts": return "j.square"
        case "json": return "curlybraces"
        case "md": return "doc.text"
        default: return "doc"
        }
    }
}
#endif
