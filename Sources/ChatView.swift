import SwiftUI

struct ChatView: View {
    let category: Category
    var resumeId: UUID? = nil

    @EnvironmentObject private var store: HistoryStore
    @StateObject private var engine = ChatEngine()
    @AppStorage("modelMode") private var modeRaw: String = ModelMode.auto.rawValue
    @State private var input = ""
    @State private var showHistory = false
    @FocusState private var inputFocused: Bool

    private var mode: ModelMode {
        ModelMode(rawValue: modeRaw) ?? .auto
    }

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                modeBar
                messageList
                inputBar
            }
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        engine.startFresh()
                    } label: {
                        Label("新对话", systemImage: "square.and.pencil")
                    }
                    Button {
                        showHistory = true
                    } label: {
                        Label("本分类历史", systemImage: "clock.arrow.circlepath")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .disabled(engine.isGenerating)
            }
        }
        .sheet(isPresented: $showHistory) {
            CategoryHistorySheet(category: category) { conversation in
                engine.load(conversation)
            }
        }
        .onAppear {
            if !engine.started {
                let resume = resumeId.flatMap { id in store.conversations.first { $0.id == id } }
                engine.attach(category: category, store: store, resume: resume)
            }
        }
    }

    private var modeBar: some View {
        HStack(spacing: 8) {
            Picker("模型", selection: $modeRaw) {
                ForEach(ModelMode.allCases) { m in
                    Text(m.title).tag(m.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)
            Spacer()
            if !engine.activeModelLabel.isEmpty {
                Text(engine.activeModelLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var messageList: some View {
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
    }

    private var presetList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("试试这些问题")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.secondary)
            ForEach(category.presets, id: \.self) { question in
                Button {
                    Task {
                        await engine.ask(question, mode: mode)
                    }
                } label: {
                    HStack {
                        Text(question)
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 14)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func bubble(_ message: ChatMessage) -> some View {
        if message.isNote {
            Text(message.text)
                .font(.caption)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 2)
        } else if message.isUser {
            HStack {
                Spacer(minLength: 60)
                Text(message.text)
                    .font(.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 18))
                    .foregroundStyle(Color.white)
            }
        } else {
            HStack {
                Text(message.text)
                    .font(.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glassCard(cornerRadius: 18)
                Spacer(minLength: 60)
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("输入你的问题…", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .focused($inputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .glassCard(cornerRadius: 20)
            Button {
                let text = input
                input = ""
                Task {
                    await engine.ask(text, mode: mode)
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.body.weight(.semibold))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.glassProminent)
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || engine.isGenerating)
        }
        .padding()
    }
}

struct CategoryHistorySheet: View {
    let category: Category
    var onPick: (Conversation) -> Void

    @EnvironmentObject private var store: HistoryStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.list(for: category.id)) { conversation in
                    Button {
                        onPick(conversation)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.title)
                                .font(.body)
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)
                            Text(conversation.updatedAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    let items = store.list(for: category.id)
                    for index in offsets {
                        store.delete(id: items[index].id)
                    }
                }
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .overlay {
                if store.list(for: category.id).isEmpty {
                    Text("还没有历史记录")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
}
