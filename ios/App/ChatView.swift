// Chat sidebar. Message history + input. Sends to ollama. macOS only.
// ponytail: no streaming, one request at a time, no persistence. Add if needed.

import SwiftUI
import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatView: View {
    @Binding var document: TextDocument
    @State private var messages: [Message] = []
    @State private var input = ""
    @State private var sending = false
    @State private var error: String?

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            Text("Agent")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.bar)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { msg in
                            HStack(spacing: 8) {
                                if msg.isUser {
                                    Spacer()
                                    Text(msg.text)
                                        .padding(8)
                                        .background(.blue)
                                        .foregroundStyle(.white)
                                        .cornerRadius(6)
                                } else {
                                    Text(msg.text)
                                        .padding(8)
                                        .background(.gray.opacity(0.2))
                                        .cornerRadius(6)
                                    Spacer()
                                }
                            }
                            .id(msg.id)
                        }
                        if let error {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(8)
                        }
                    }
                    .padding(8)
                }
                .onChange(of: messages.count) { proxy.scrollTo(messages.last?.id) }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Message...", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .disabled(sending)

                Button(action: send) {
                    Image(systemName: sending ? "ellipsis" : "paperplane.fill")
                }
                .disabled(sending || input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(8)
        }
        .frame(minHeight: 120, maxHeight: 300)
        #else
        EmptyView()
        #endif
    }

    private func send() {
        #if os(macOS)
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        input = ""
        messages.append(Message(text: text, isUser: true))
        error = nil
        sending = true

        Task {
            defer { sending = false }
            do {
                let context = "Current file: \(document.type.preferredFilenameExtension ?? "txt")\n\n\(document.text.prefix(2000))"
                let reply = try await Complete.fill(prefix: context + "\n\nUser: " + text, suffix: "")
                messages.append(Message(text: reply.trimmingCharacters(in: .whitespaces), isUser: false))
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? "Failed to get response"
            }
        }
        #endif
    }
}
