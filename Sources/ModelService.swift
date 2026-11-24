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

// MARK: - 对话引擎

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    var text: String
}

@MainActor
final class ChatEngine: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    private(set) var started = false
    private var session: LanguageModelSession?

    func start(category: Category) {
        session = LanguageModelSession(instructions: category.instructions)
        session?.prewarm()
        messages = []
        started = true
    }

    func ask(_ rawQuestion: String) async {
        let question = rawQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        if question.isEmpty || isGenerating {
            return
        }
        guard let session = session else {
            return
        }
        messages.append(ChatMessage(isUser: true, text: question))
        isGenerating = true
        messages.append(ChatMessage(isUser: false, text: ""))
        let answerIndex = messages.count - 1
        do {
            let stream: LanguageModelSession.ResponseStream<String> = session.streamResponse(to: question)
            for try await partial in stream {
                messages[answerIndex].text = partial.content
            }
            if messages[answerIndex].text.isEmpty {
                messages[answerIndex].text = "没有生成内容，换个问法试试。"
            }
        } catch let error as LanguageModelSession.GenerationError {
            messages[answerIndex].text = ChatEngine.friendlyMessage(for: error)
        } catch {
            messages[answerIndex].text = "出错了：\(error.localizedDescription)"
        }
        isGenerating = false
    }

    static func friendlyMessage(for error: LanguageModelSession.GenerationError) -> String {
        switch error {
        case .guardrailViolation:
            return "这个问题触发了苹果 AI 的安全限制，没法回答。换个问法，或者问点别的吧。"
        case .exceededContextWindowSize:
            return "这次对话太长了，超出了本地模型的记忆范围。点右上角按钮重新开始一次新对话吧。"
        case .unsupportedLanguageOrLocale:
            return "本地模型暂时不支持当前的语言或地区设置。"
        default:
            return "生成失败：\(error.localizedDescription)"
        }
    }
}
