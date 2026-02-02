import SwiftUI

struct BackgroundView: View {
    let theme: GameTheme

    var body: some View {
        LinearGradient(
            colors: [theme.palette.backgroundTop, theme.palette.backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 300, height: 300)
                .offset(x: -140, y: -200)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.04))
                .frame(width: 240, height: 160)
                .offset(x: 150, y: 240)
        )
    }
}

struct GlowCircle: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.7), radius: size * 0.35, x: 0, y: 0)
    }
}
