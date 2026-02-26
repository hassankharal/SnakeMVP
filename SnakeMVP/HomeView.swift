import SwiftUI

struct HomeView: View {
    let theme: GameTheme
    let bestScore: Int
    let adsRemoved: Bool
    let onStart: () -> Void
    let onSettings: () -> Void

    private var shouldShowAds: Bool {
        AdPlacementPolicy.shouldShowBanners(adsRemoved: adsRemoved)
    }

    var body: some View {
        ZStack {
            BackgroundView(theme: theme)

            VStack(spacing: 20) {
                Spacer()

                HomeTitle(theme: theme)

                GamePreview(theme: theme)
                    .frame(height: 240)
                    .padding(.horizontal, 24)

                if shouldShowAds {
                    AdBannerView(theme: theme, label: "Ad placement")
                        .frame(height: 56)
                        .padding(.horizontal, 28)
                }

                HomeActions(theme: theme, onStart: onStart, onSettings: onSettings)

                Text("Best score: \(bestScore)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.palette.hudSubtle)

                Spacer()
            }
        }
    }
}

private struct HomeTitle: View {
    let theme: GameTheme

    var body: some View {
        VStack(spacing: 10) {
            Text("Snake MVP")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(theme.palette.hudText)

            Text("Free-flowing joystick snake with auto-generated levels")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(theme.palette.hudSubtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
}

private struct HomeActions: View {
    let theme: GameTheme
    let onStart: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onStart) {
                Text("Start Game")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(theme.palette.button)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            Button(action: onSettings) {
                Text("Settings")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.16))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

private struct GamePreview: View {
    let theme: GameTheme

    var body: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(theme.palette.board)
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(theme.palette.boardOutline, lineWidth: 1)
            )
            .overlay(
                VStack {
                    HStack {
                        GlowCircle(color: theme.palette.food, size: 16)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        GlowCircle(color: theme.palette.snakeHead, size: 22)
                    }
                }
                .padding(24)
            )
    }
}
