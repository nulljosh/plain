// Terminal pane. User command input, output display. macOS only.
// ponytail: simple shell, no TTY features. Add pty if interactive shells needed.

import SwiftUI
import Foundation

#if os(macOS)
struct TerminalPane: View {
    @State private var command = ""
    @State private var output = ""
    @State private var running = false

    var body: some View {
        VStack(spacing: 0) {
            Text("Terminal")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                TextField("$ ", text: $command)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.caption, design: .monospaced))
                    .disabled(running)

                Button(action: execute) {
                    Image(systemName: running ? "ellipsis" : "play.fill")
                        .font(.caption)
                }
                .disabled(running || command.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(8)
        }
        .frame(minHeight: 80, maxHeight: 200)
    }

    private func execute() {
        let cmd = command.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else { return }

        running = true
        output += "$ \(cmd)\n"
        command = ""

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
                output += "error: Failed to run command\n"
                return
            }

            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

            output += String(data: data, encoding: .utf8) ?? ""
            output += String(data: errData, encoding: .utf8) ?? ""
        }
    }
}
#endif
