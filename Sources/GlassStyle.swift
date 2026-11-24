import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.82, green: 0.90, blue: 1.0),
                    Color(red: 0.93, green: 0.87, blue: 1.0),
                    Color(red: 0.85, green: 0.98, blue: 0.93)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color.blue.opacity(0.35))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -120, y: -260)
            Circle()
                .fill(Color.pink.opacity(0.30))
                .frame(width: 240, height: 240)
                .blur(radius: 70)
                .offset(x: 130, y: -60)
            Circle()
                .fill(Color.orange.opacity(0.28))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: -80, y: 300)
            Circle()
                .fill(Color.teal.opacity(0.30))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: 140, y: 430)
        }
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
