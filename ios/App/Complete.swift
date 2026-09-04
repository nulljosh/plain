// Autocomplete from a model running on this Mac. One key, one HTTP call, text lands at the cursor.
// ponytail: no ghost text, no streaming, Mac only (Ollama listens on localhost). A picker for
// the model and a LAN host for iPhone are the two upgrades; add when someone asks.

import Foundation

enum CompleteError: LocalizedError {
    case offline, badStatus(Int), badReply, empty
    var errorDescription: String? {
        switch self {
        case .offline: "Ollama is not running (localhost:11434)"
        case .badStatus(let c): c == 404 ? "Model not found. ollama pull \(Complete.model)" : "Ollama returned \(c)"
        case .badReply: "Ollama sent something that is not JSON"
        case .empty: "Nothing to add here"
        }
    }
}

enum Complete {
    static var model: String { UserDefaults.standard.string(forKey: "model") ?? "qwen2.5-coder:1.5b-base" }

    static func fill(prefix: String, suffix: String) async throws -> String {
        var r = URLRequest(url: URL(string: "http://localhost:11434/api/generate")!)
        r.httpMethod = "POST"
        r.httpBody = try JSONSerialization.data(withJSONObject: [
            "model": model, "raw": true, "stream": false,
            "prompt": "<|fim_prefix|>\(prefix.suffix(4000))<|fim_suffix|>\(suffix.prefix(1000))<|fim_middle|>",
            "options": ["num_predict": 96, "temperature": 0.2,
                        "stop": ["<|fim_prefix|>", "<|fim_suffix|>", "<|fim_middle|>", "<|endoftext|>", "<|file_sep|>", "\n\n"]],
        ])
        r.timeoutInterval = 30
        let d: Data, resp: URLResponse
        do { (d, resp) = try await URLSession.shared.data(for: r) } catch { throw CompleteError.offline }
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(code) else { throw CompleteError.badStatus(code) }
        guard let j = try? JSONSerialization.jsonObject(with: d) as? [String: Any], let out = j["response"] as? String else { throw CompleteError.badReply }
        guard !out.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw CompleteError.empty }
        return out
    }
}
