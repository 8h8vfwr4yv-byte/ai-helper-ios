import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var localState: ModelState = ModelState.current()
    @State private var cloudState: CloudState = CloudState.current()
    @AppStorage("modelMode") private var modeRaw: String = ModelMode.auto.rawValue

    private var mode: ModelMode {
        ModelMode(rawValue: modeRaw) ?? .auto
    }

    private var canAsk: Bool {
        switch mode {
        case .auto:
            return localState == .available || cloudState == .available
        case .cloud:
            return cloudState == .available
        case .local:
            return localState == .available
        }
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                NavigationSplitView {
                    sidebar
                } detail: {
                    NavigationStack {
                        homeContent
                    }
                }
            } else {
                NavigationStack {
                    homeContent
                }
            }
        }
        .onAppear { refreshStates() }
    }

    private func refreshStates() {
        localState = ModelState.current()
        cloudState = CloudState.current()
    }

    // MARK: - 侧边栏（iPad / 折叠屏展开态）

    private var sidebar: some View {
        List {
            Section("问答分类") {
                ForEach(Category.all) { category in
                    NavigationLink {
                        ChatView(category: category)
                    } label: {
                        Label(category.name, systemImage: category.icon)
                    }
                }
            }
            Section {
                NavigationLink {
                    HealthCalcView()
                } label: {
                    Label("健康计算", systemImage: "cross.case.fill")
                }
                NavigationLink {
                    HistoryView()
                } label: {
                    Label("历史记录", systemImage: "clock.arrow.circlepath")
                }
            }
        }
        .navigationTitle("AI问答")
    }

    // MARK: - 主页

    private var homeContent: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    statusCard
                    modeCard
                    categoryGrid
                    healthCard
                    historyCard
                    footerNote
                }
                .padding()
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("AI问答")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AI问答")
                .font(.largeTitle.weight(.bold))
            Text("调用苹果 AI 模型：云端优先，超时自动切本地，也能自己选")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "icloud")
                    .foregroundStyle(cloudState == .available ? Color.green : Color.red)
                Text(cloudState.title)
                    .font(.headline)
                Spacer()
                Button {
                    refreshStates()
                } label: {
                    Label("刷新", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.glass)
            }
            HStack(spacing: 10) {
                Image(systemName: localState.icon)
                    .foregroundStyle(localState.tint)
                Text(localState.title)
                    .font(.headline)
            }
            Text("云端走苹果的 Private Cloud Compute，数据不用于训练、不留存；本地模式全程在设备上处理。")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .padding(18)
        .glassCard()
    }

    private var modeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("使用哪个模型")
                .font(.headline)
            Picker("模型", selection: $modeRaw) {
                ForEach(ModelMode.allCases) { m in
                    Text(m.title).tag(m.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Text(mode.detail)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .padding(18)
        .glassCard()
    }

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("问答分类")
                .font(.title3.weight(.bold))
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: sizeClass == .regular ? 3 : 2),
                spacing: 14
            ) {
                ForEach(Category.all) { category in
                    NavigationLink {
                        ChatView(category: category)
                    } label: {
                        categoryCard(category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .disabled(!canAsk)
            .opacity(canAsk ? 1.0 : 0.45)
            if !canAsk {
                Text("所选模型可用后，上面的分类才能点进去提问。")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private func categoryCard(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: category.icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 36, height: 36)
                .background(category.color.gradient, in: RoundedRectangle(cornerRadius: 10))
            Text(category.name)
                .font(.headline)
                .foregroundStyle(Color.primary)
            Text(category.subtitle)
                .font(.caption)
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCardInteractive()
    }

    private var healthCard: some View {
        NavigationLink {
            HealthCalcView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.red.gradient, in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text("健康计算")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    Text("BMI、每日饮水量、基础代谢 · 不需要 AI")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(14)
            .glassCardInteractive()
        }
        .buttonStyle(.plain)
    }

    private var historyCard: some View {
        NavigationLink {
            HistoryView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.gradient, in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text("历史记录")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    Text("以前问过的问题和回答都保存在本机，随时接着聊")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(14)
            .glassCardInteractive()
        }
        .buttonStyle(.plain)
    }

    private var footerNote: some View {
        Text("回答由苹果 AI 模型生成，仅供参考；健康类内容不能替代医生的诊断和治疗。聊天记录只保存在这台设备上。")
            .font(.footnote)
            .foregroundStyle(Color.secondary)
            .padding(.top, 2)
    }
}
