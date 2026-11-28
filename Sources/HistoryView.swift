import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: HistoryStore
    @State private var showClearConfirm = false

    private func category(for conversation: Conversation) -> Category? {
        Category.all.first { $0.id == conversation.categoryId }
    }

    var body: some View {
        List {
            ForEach(store.conversations.filter { !$0.messages.isEmpty }) { conversation in
                if let category = category(for: conversation) {
                    NavigationLink {
                        ChatView(category: category, resumeId: conversation.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.title)
                                .font(.body)
                                .lineLimit(1)
                            HStack(spacing: 6) {
                                Text(category.name)
                                Text("·")
                                Text(conversation.updatedAt, style: .date)
                            }
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            .onDelete { offsets in
                let items = store.conversations.filter { !$0.messages.isEmpty }
                for index in offsets {
                    store.delete(id: items[index].id)
                }
            }
        }
        .navigationTitle("历史记录")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(store.conversations.isEmpty)
            }
        }
        .confirmationDialog("清空全部历史记录？", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("清空", role: .destructive) {
                store.deleteAll()
            }
            Button("取消", role: .cancel) {}
        }
        .overlay {
            if store.conversations.filter({ !$0.messages.isEmpty }).isEmpty {
                Text("还没有历史记录，去问一个问题吧")
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
