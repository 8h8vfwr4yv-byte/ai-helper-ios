import SwiftUI

// v2.0：背景改成干净的素色微渐变，不再用彩色光斑
struct AppBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        LinearGradient(
            colors: scheme == .dark
                ? [Color(red: 0.07, green: 0.07, blue: 0.09), Color(red: 0.11, green: 0.11, blue: 0.14)]
                : [Color(red: 0.98, green: 0.98, blue: 1.0), Color(red: 0.93, green: 0.95, blue: 0.98)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
    }

    func glassCardInteractive(cornerRadius: CGFloat = 20) -> some View {
        self.glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}
