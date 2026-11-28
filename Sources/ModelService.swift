import SwiftUI
import FoundationModels

// MARK: - 本地模型可用状态

enum ModelState: Equatable {
    case available
    case notEnabled
    case notEligible
    case notReady
    case unknown

    static func current() -> ModelState {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .available
        case .unavailable(.appleIntelligenceNotEnabled):
            return .notEnabled
        case .unavailable(.deviceNotEligible):
            return .notEligible
        case .unavailable(.modelNotReady):
            return .notReady
        case .unavailable:
            return .unknown
        }
    }

    var title: String {
        switch self {
        case .available:
            return "本地苹果 AI 可用"
        case .notEnabled:
            return "Apple 智能未开启"
        case .notEligible:
            return "这台设备不支持 Apple 智能"
        case .notReady:
            return "模型还没准备好"
        case .unknown:
            return "模型状态未知"
        }
    }

    var detail: String {
        switch self {
        case .available:
            return "问题由设备上的苹果 AI 模型回答，全程本地处理，不联网、不上传。"
        case .notEnabled:
            return "去「设置 → Apple 智能与 Siri」开启 Apple 智能后，回到这里点刷新。"
        case .notEligible:
            return "问答功能需要支持 Apple 智能的 iPhone 或 iPad 才能使用；下面的健康计算不需要 AI，照常可用。"
        case .notReady:
            return "模型可能还在下载。连上 Wi-Fi 等一会儿，再回来点刷新。"
        case .unknown:
            return "暂时读不到模型状态，稍后再点刷新试试。"
        }
    }

    var icon: String {
        switch self {
        case .available:
            return "checkmark.circle.fill"
        case .notReady:
            return "arrow.down.circle.fill"
        default:
            return "exclamationmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .available:
            return Color.green
        case .notReady:
            return Color.orange
        default:
            return Color.red
        }
    }
}

// MARK: - 问答分类

struct Category: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    let instructions: String
    let presets: [String]

    static let all: [Category] = [
        Category(
            id: "general",
            name: "通用问答",
            subtitle: "什么都能问",
            icon: "sparkles",
            color: Color.indigo,
            instructions: "你是一个乐于助人的中文助手。用简明、通俗的中文回答问题，必要时分点列出。回答控制在300字以内，不要使用表格。",
            presets: ["怎么提高睡眠质量？", "出门旅行要带哪些必备物品？", "如何快速记住一串数字？", "冰箱里的食物一般能放多久？"]
        ),
        Category(
            id: "health",
            name: "健康科普",
            subtitle: "保健与常见问题",
            icon: "heart.fill",
            color: Color.pink,
            instructions: "你是一个健康科普助手。用通俗的中文讲解健康知识和日常保健建议，回答控制在300字以内并分点列出。重要提醒：你提供的是科普信息，不能替代医生的诊断和治疗；不要给出确诊结论，不要推荐具体处方药和剂量；涉及具体症状时，要建议用户在症状严重或持续时及时就医。",
            presets: ["每天应该喝多少水？", "久坐对身体有什么影响？", "感冒了多喝热水有用吗？", "如何缓解眼睛疲劳？"]
        ),
        Category(
            id: "life",
            name: "生活常识",
            subtitle: "衣食住行小窍门",
            icon: "house.fill",
            color: Color.teal,
            instructions: "你是一个生活常识助手，回答衣食住行、家居清洁、收纳、应急处理等日常问题。答案要实用、可操作，分步骤列出，控制在300字以内。",
            presets: ["衣服上的油渍怎么去掉？", "手机进水了第一时间该怎么做？", "房间除湿有哪些简单办法？", "切洋葱怎么不流泪？"]
        ),
        Category(
            id: "food",
            name: "饮食营养",
            subtitle: "吃得明白健康",
            icon: "fork.knife",
            color: Color.orange,
            instructions: "你是一个饮食营养助手，讲解食材营养、搭配、保存和简单做法，给出实用的饮食建议。回答控制在300字以内，分点列出。涉及食品安全（变质、误食）时要明确提醒风险。",
            presets: ["鸡蛋怎么保存更新鲜？", "每天吃多少盐合适？", "隔夜菜到底能不能吃？", "哪些食物不适合空腹吃？"]
        ),
        Category(
            id: "fitness",
            name: "运动健身",
            subtitle: "训练与恢复",
            icon: "figure.run",
            color: Color.green,
            instructions: "你是一个运动健身助手，讲解运动方法、拉伸、恢复和训练安排。回答要安全、循序渐进，提醒热身和量力而行，控制在300字以内并分点列出。",
            presets: ["新手跑步应该怎么开始？", "运动后肌肉酸痛怎么缓解？", "每天走多少步比较合适？", "拉伸应该在运动前还是运动后？"]
        ),
        Category(
            id: "tech",
            name: "科技数码",
            subtitle: "手机电脑问题",
            icon: "cpu",
            color: Color.blue,
            instructions: "你是一个科技数码助手，用通俗的中文解释手机、电脑和网络相关问题，给出可操作的步骤。回答控制在300字以内，分点列出。",
            presets: ["手机电池怎么保养寿命更长？", "Wi-Fi 信号差怎么改善？", "照片太多怎么备份最稳妥？", "怎么判断一条短信是不是诈骗？"]
        ),
        Category(
            id: "study",
            name: "学习辅导",
            subtitle: "方法与思路",
            icon: "book.fill",
            color: Color.purple,
            instructions: "你是一个学习辅导助手，讲解知识点、解题思路和学习方法。讲解要循序渐进，先给思路再给结论，控制在300字以内。",
            presets: ["怎么背单词记得更牢？", "数学应用题总是读不懂怎么办？", "考试前一周怎么复习效率高？", "如何制定一个能坚持的学习计划？"]
        )
    ]
}

// MARK: - 模型选择（云端 / 本地）

enum ModelMode: String, CaseIterable, Identifiable {
    case auto
    case cloud
    case local

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto: return "自动"
        case .cloud: return "云端"
        case .local: return "本地"
        }
    }

    var detail: String {
        switch self {
        case .auto: return "优先用云端苹果 AI（Private Cloud Compute），超时或不可用时自动切换到本地模型。"
        case .cloud: return "只用云端苹果 AI 回答，需要联网，回答能力更强。"
        case .local: return "只用设备上的本地模型回答，不联网、不上传。"
        }
    }
}

enum ModelKind {
    case cloud
    case local

    var label: String {
        switch self {
        case .cloud: return "云端模型"
        case .local: return "本地模型"
        }
    }
}

enum CloudState {
    case available
    case unavailable

    static func current() -> CloudState {
        if PrivateCloudComputeLanguageModel().isAvailable {
            return .available
        }
        return .unavailable
    }

    var title: String {
        switch self {
        case .available: return "云端苹果 AI 可用"
        case .unavailable: return "云端苹果 AI 当前不可用"
        }
    }
}

// MARK: - 历史记录存储

struct ChatMessage: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var isUser: Bool
    var text: String
    var isNote: Bool = false
}

struct Conversation: Identifiable, Codable {
    var id: UUID = UUID()
    var categoryId: String
    var title: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var messages: [ChatMessage] = []
}

@MainActor
final class HistoryStore: ObservableObject {
    @Published var conversations: [Conversation] = []

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("conversations.json")
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Conversation].self, from: data) else {
            conversations = []
            return
        }
        conversations = decoded.sorted { $0.updatedAt > $1.updatedAt }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(conversations) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func upsert(_ conversation: Conversation) {
        if let idx = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[idx] = conversation
        } else {
            conversations.append(conversation)
        }
        conversations.sort { $0.updatedAt > $1.updatedAt }
        save()
    }

    func delete(id: UUID) {
        conversations.removeAll { $0.id == id }
        save()
    }

    func deleteAll() {
        conversations = []
        save()
    }

    func latest(for categoryId: String) -> Conversation? {
        conversations.first { $0.categoryId == categoryId && !$0.messages.isEmpty }
    }

    func list(for categoryId: String) -> [Conversation] {
        conversations.filter { $0.categoryId == categoryId && !$0.messages.isEmpty }
    }
}

// MARK: - 对话引擎（云端优先 + 超时回退本地）

private struct StreamTimeout: Error {}

private final class StreamBox: @unchecked Sendable {
    var iterator: LanguageModelSession.ResponseStream<String>.AsyncIterator
    init(_ stream: LanguageModelSession.ResponseStream<String>) {
        iterator = stream.makeAsyncIterator()
    }
}

@MainActor
final class ChatEngine: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    @Published var activeModelLabel: String = ""

    private(set) var started = false
    private var category: Category?
    private weak var store: HistoryStore?
    private var conversationId: UUID = UUID()
    private var createdAt: Date = Date()
    private var localSession: LanguageModelSession?
    private var cloudSession: LanguageModelSession?

    private static let cloudFirstTokenTimeout: TimeInterval = 20

    func attach(category: Category, store: HistoryStore, resume: Conversation?) {
        self.category = category
        self.store = store
        if let resume {
            load(resume)
        } else if let latest = store.latest(for: category.id) {
            load(latest)
        } else {
            startFresh()
        }
        started = true
    }

    func load(_ conversation: Conversation) {
        conversationId = conversation.id
        createdAt = conversation.createdAt
        messages = conversation.messages
        localSession = nil
        cloudSession = nil
    }

    func startFresh() {
        conversationId = UUID()
        createdAt = Date()
        messages = []
        localSession = nil
        cloudSession = nil
    }

    private func session(for kind: ModelKind) -> LanguageModelSession {
        guard let category else {
            return LanguageModelSession(instructions: "")
        }
        switch kind {
        case .local:
            if let localSession { return localSession }
            let s = LanguageModelSession(model: SystemLanguageModel.default, instructions: category.instructions)
            s.prewarm()
            localSession = s
            return s
        case .cloud:
            if let cloudSession { return cloudSession }
            let s = LanguageModelSession(model: PrivateCloudComputeLanguageModel(), instructions: category.instructions)
            cloudSession = s
            return s
        }
    }

    private func nextChunk(_ box: StreamBox, timeout: TimeInterval?) async throws -> String? {
        guard let timeout else {
            return try await box.iterator.next()?.content
        }
        return try await withThrowingTaskGroup(of: String?.self) { group in
            group.addTask {
                try await box.iterator.next()?.content
            }
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw StreamTimeout()
            }
            let value = try await group.next()!
            group.cancelAll()
            return value
        }
    }

    // 返回 true 表示已生成内容；false 表示一个字都没生成（可回退）
    private func streamAttempt(kind: ModelKind, question: String, answerIndex: Int) async -> Bool {
        let session = self.session(for: kind)
        let box = StreamBox(session.streamResponse(to: question))
        var gotAny = false
        do {
            while true {
                let timeout: TimeInterval? = (kind == .cloud && !gotAny) ? ChatEngine.cloudFirstTokenTimeout : nil
                guard let content = try await nextChunk(box, timeout: timeout) else { break }
                gotAny = true
                messages[answerIndex].text = content
            }
        } catch {
            if !gotAny {
                return false
            }
            messages[answerIndex].text += "\n\n（回答中途中断了）"
            return true
        }
        return gotAny
    }

    func ask(_ rawQuestion: String, mode: ModelMode) async {
        let question = rawQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        if question.isEmpty || isGenerating {
            return
        }
        let localOK = ModelState.current() == .available
        let cloudOK = CloudState.current() == .available

        var order: [ModelKind] = []
        switch mode {
        case .auto:
            if cloudOK { order.append(.cloud) }
            if localOK { order.append(.local) }
        case .cloud:
            order = [.cloud]
        case .local:
            order = [.local]
        }

        messages.append(ChatMessage(isUser: true, text: question))
        isGenerating = true
        messages.append(ChatMessage(isUser: false, text: ""))
        let answerIndex = messages.count - 1

        if order.isEmpty {
            messages[answerIndex].text = "现在云端和本地模型都不可用。检查一下网络，或去「设置 → Apple 智能与 Siri」确认 Apple 智能已开启。"
            isGenerating = false
            persist()
            return
        }

        var fellBack = false
        for (index, kind) in order.enumerated() {
            let ok = await streamAttempt(kind: kind, question: question, answerIndex: answerIndex)
            if ok {
                activeModelLabel = kind.label
                if fellBack {
                    messages.insert(
                        ChatMessage(isUser: false, text: "云端模型响应超时，已自动切换到本地模型回答", isNote: true),
                        at: answerIndex
                    )
                }
                isGenerating = false
                persist()
                return
            }
            if index < order.count - 1 {
                fellBack = true
                messages[answerIndex].text = ""
                if kind == .cloud { cloudSession = nil }
                if kind == .local { localSession = nil }
            }
        }

        // 所有候选都没生成内容
        if mode == .cloud {
            messages[answerIndex].text = "云端模型响应超时或暂时不可用。检查网络后再试，或者在上方把模型切到「自动」或「本地」。"
        } else if mode == .local {
            messages[answerIndex].text = "本地模型暂时没响应，稍后再试一次。"
        } else {
            messages[answerIndex].text = "云端和本地模型都没能响应，稍后再试一次。"
        }
        isGenerating = false
        persist()
    }

    private func persist() {
        guard let category, let store else { return }
        let firstQuestion = messages.first(where: { $0.isUser })?.text ?? "新对话"
        let conversation = Conversation(
            id: conversationId,
            categoryId: category.id,
            title: String(firstQuestion.prefix(30)),
            createdAt: createdAt,
            updatedAt: Date(),
            messages: messages
        )
        store.upsert(conversation)
    }
}
