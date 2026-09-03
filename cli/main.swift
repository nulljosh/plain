// plain: the command line side. Same Stats as the app.
//
//   plain <file>         open in Plain.app (macOS)
//   plain stat <file>    line / word / char counts
//   cat x | plain stat   counts from stdin
//
// Build: swiftc -O -o plain ios/App/Stats.swift cli/main.swift
// ponytail: a terminal editor is a different product. Editing happens in the app.

import Foundation

let args = Array(CommandLine.arguments.dropFirst())

func read(_ path: String?) -> String {
    if let path {
        guard let s = try? String(contentsOfFile: path, encoding: .utf8) else {
            FileHandle.standardError.write("plain: cannot read \(path)\n".data(using: .utf8)!); exit(1)
        }
        return s
    }
    return String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) ?? ""
}

switch args.first {
case "stat":
    print(Stats(read(args.dropFirst().first)).summary)
case nil, "-h", "--help":
    print("usage: plain <file> | plain stat [file]")
case let path?:
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    p.arguments = ["-a", "Plain", path]
    try p.run(); p.waitUntilExit()
    exit(p.terminationStatus)
}
