// Format on save: prettier, black, swiftformat. Shell out on macOS; no-op on iOS.
// ponytail: synchronous, one shot, no error UI (save still works). Async + retry if needed.

import UniformTypeIdentifiers
import Foundation

enum Formatter {
    static func format(_ text: String, type: UTType) -> String {
        #if os(macOS)
        guard UserDefaults.standard.bool(forKey: "formatOnSave") else { return text }

        if type.conforms(to: .json) || type.conforms(to: .html) || type.conforms(to: .javaScript) || type.conforms(to: .sourceCode) {
            return shell("prettier", ["--parser=auto"], text) ?? text
        } else if type.conforms(to: .pythonScript) {
            return shell("black", ["-"], text) ?? text
        } else if type.conforms(to: .swiftSource) {
            return shell("swiftformat", ["--stdin", "swift"], text) ?? text
        }
        #endif
        return text
    }

    #if os(macOS)
    private static func shell(_ cmd: String, _ args: [String], _ input: String) -> String? {
        let which = Process()
        which.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        which.arguments = [cmd]
        let pout = Pipe()
        which.standardOutput = pout
        guard (try? which.run()) != nil else { return nil }
        which.waitUntilExit()
        guard which.terminationStatus == 0,
              let path = String(data: pout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !path.isEmpty else { return nil }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = args
        let stdin = Pipe()
        let stdout = Pipe()
        task.standardInput = stdin
        task.standardOutput = stdout
        task.standardError = Pipe()  // discard errors

        guard (try? task.run()) != nil else { return nil }
        stdin.fileHandleForWriting.write(input.data(using: .utf8) ?? Data())
        try? stdin.fileHandleForWriting.close()

        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        return String(data: data, encoding: .utf8)
    }
    #endif
}
