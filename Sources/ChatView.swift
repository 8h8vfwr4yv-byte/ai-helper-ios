import SwiftUI

struct ChatView: View {
    let category: Category
    @StateObject private var engine = ChatEngine()
    @State private var input = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if engine.messages.isEmpty {
                                presetList
                            }
                            ForEach(engine.messages) { message in
                                bubble(message)
                                    .id(message.id)
                            }
                            if engine.isGenerating && (engine.messages.last?.text.isEmpty ?? false) {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("思考中…")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                    Spacer()
                                }
                            }
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding()
                    }
                    .onChange(of: engine.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: engine.messages.last?.text) { _, _ in
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                inputBar
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    engine.start(category: category)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .disabled(engine.isGenerating)
            }
        }
        .onAppear {
            if engine.started == false {
                engine.start(category: category)
            }
        }
    }

    private var presetList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("试试这些问题")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.secondary)
            ForEach(category.presets, id: \.self) { question in
                Button {
                    Task {
                        await engine.ask(question)
                    }
                } label: {
                    HStack {
                        Text(question)
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .glassCardInteractive(cornerRadius: 16)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bubble(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 52)
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .foregroundStyle(Color.white)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 18))
            } else {
                Text(message.text.isEmpty ? "…" : message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
                    .textSelection(.enabled)
                Spacer(minLength: 52)
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("输入你的问题", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .focused($inputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .glassEffect(.regular.interactive(), in: Capsule())
            Button {
                let question = input
                input = ""
                Task {
                    await engine.ask(question)
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.headline)
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.glassProminent)
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || engine.isGenerating)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
