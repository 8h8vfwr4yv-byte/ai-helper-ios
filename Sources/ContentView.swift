import SwiftUI

struct ContentView: View {
    @State private var modelState: ModelState = ModelState.current()

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        statusCard
                        categoryGrid
                        healthCard
                        footerNote
                    }
                    .padding()
                }
            }
            .navigationTitle("AI问答")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .onAppear {
                modelState = ModelState.current()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AI问答")
                .font(.largeTitle.weight(.bold))
            Text("调用设备上的苹果 AI 模型，本地回答健康、生活等问题")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: modelState.icon)
                    .font(.title3)
                    .foregroundStyle(modelState.tint)
                Text(modelState.title)
                    .font(.headline)
                Spacer()
                Button {
                    modelState = ModelState.current()
                } label: {
                    Label("刷新", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.glass)
            }
            Text(modelState.detail)
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
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Category.all) { category in
                    NavigationLink {
                        ChatView(category: category)
                    } label: {
                        categoryCard(category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .disabled(modelState != .available)
            .opacity(modelState == .available ? 1.0 : 0.45)
            if modelState != .available {
                Text("模型可用后，上面的分类才能点进去提问。")
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

    private var footerNote: some View {
        Text("回答由设备上的苹果 AI 模型生成，仅供参考；健康类内容不能替代医生的诊断和治疗。")
            .font(.footnote)
            .foregroundStyle(Color.secondary)
            .padding(.top, 2)
    }
}
