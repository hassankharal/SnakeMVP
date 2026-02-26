import SwiftUI

struct AdBannerView: View {
    let theme: GameTheme
    let label: String

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(theme.palette.board.opacity(0.85))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.palette.boardOutline, lineWidth: 1)
            )
            .overlay(
                HStack(spacing: 8) {
                    Circle()
                        .fill(theme.palette.food)
                        .frame(width: 8, height: 8)
                    Text(label)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.palette.hudSubtle)
                    Spacer()
                    Text("Sponsored")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.palette.hudSubtle)
                }
                .padding(.horizontal, 14)
            )
    }
}
