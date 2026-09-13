// Output pane. Build/test output, error parsing, click jumps to line. macOS only.
// ponytail: plain scrolling text, error regex patterns. Add persistent history if needed.

import SwiftUI
import Foundation

#if os(macOS)
struct OutputPane: View {
    @Binding var document: TextDocument
    @State private var output = ""
    @State private var running = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Output")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: clearOutput) {
                    Image(systemName: "xmark.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Clear output")
            }
            .padding(8)
            .background(.bar)

            ScrollView(.vertical) {
                Text(output)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .textSelection(.enabled)
            }

            HStack(spacing: 8) {
                Button(action: { runCommand("swift build") }) {
                    Text("Build").font(.caption)
                }
                Button(action: { runCommand("swift test") }) {
                    Text("Test").font(.caption)
                }
                Button(action: { runCommand("python -m pytest") }) {
                    Text("PyTest").font(.caption)
                }
                Spacer()
            }
            .padding(8)
            .background(.bar)
        }
        .frame(minHeight: 80, maxHeight: 200)
    }

    private func runCommand(_ cmd: String) {
        guard !running else { return }
        running = true
        output = "$ \(cmd)\n"

        Task {
            defer { running = false }
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.arguments = ["-c", cmd]
            task.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

            let pipe = Pipe()
            let errPipe = Pipe()
            task.standardOutput = pipe
            task.standardError = errPipe

            guard (try? task.run()) != nil else {
                output += "Error: Failed to run command\n"
                return
            }

            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

            let stdout = String(data: data, encoding: .utf8) ?? ""
            let stderr = String(data: errData, encoding: .utf8) ?? ""

            output += stdout + stderr
            if task.terminationStatus == 0 {
                output += "\n✓ Success"
            } else {
                output += "\n✗ Exit code: \(task.terminationStatus)"
            }
        }
    }

    private func clearOutput() {
        output = ""
    }
}
#endif
