import SwiftUI

struct GameView: View {
    @ObservedObject var model: GameModel
    @Binding var bestScore: Int
    let hapticsOn: Bool
    let theme: GameTheme
    let onHome: () -> Void
    let onSettings: () -> Void

    var body: some View {
        ZStack {
            BackgroundView(theme: theme)

            VStack(spacing: 0) {
                HUDView(model: model, bestScore: bestScore, theme: theme)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                Spacer(minLength: 8)

                GameBoardView(model: model, theme: theme)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 12)
            }

            VStack {
                HStack {
                    Button(action: { onHome() }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: { onSettings() }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    JoystickView(size: 120, theme: theme) { vector in
                        model.updateInput(vector)
                    }

                    Spacer()

                    Button(action: {
                        if model.state == .playing {
                            model.pauseGame()
                        } else if model.state == .paused {
                            model.resumeGame()
                        }
                    }) {
                        Text(model.state == .paused ? "Resume" : "Pause")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(theme.palette.button)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(model.state != .playing && model.state != .paused)
                    .opacity(model.state == .playing || model.state == .paused ? 1 : 0.4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 22)
            }

            overlayView
        }
        .onChange(of: model.state) { newState in
            if (newState == .gameOver || newState == .levelComplete), model.score > bestScore {
                bestScore = model.score
            }
            if hapticsOn {
                switch newState {
                case .levelComplete:
                    Haptics.notify(.success)
                case .gameOver:
                    Haptics.notify(.error)
                default:
                    break
                }
            }
        }
        .onChange(of: model.foodEaten) { newValue in
            if hapticsOn, newValue > 0 {
                Haptics.impact(.light)
            }
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch model.state {
        case .levelComplete:
            OverlayCard(
                title: "Level \(model.level.index) Complete",
                subtitle: "New level generated. Faster speed and more obstacles.",
                primaryTitle: "Next Level",
                primaryAction: { model.nextLevel() },
                secondaryTitle: "Home",
                secondaryAction: { onHome() },
                theme: theme
            )
        case .gameOver:
            OverlayCard(
                title: "Game Over",
                subtitle: "Score \(model.score). You can do better.",
                primaryTitle: "Restart",
                primaryAction: { model.startNewGame() },
                secondaryTitle: "Home",
                secondaryAction: { onHome() },
                theme: theme
            )
        case .paused:
            OverlayCard(
                title: "Paused",
                subtitle: "Tap resume or adjust settings.",
                primaryTitle: "Resume",
                primaryAction: { model.resumeGame() },
                secondaryTitle: "Settings",
                secondaryAction: { onSettings() },
                theme: theme
            )
        default:
            EmptyView()
        }
    }
}

private struct HUDView: View {
    @ObservedObject var model: GameModel
    let bestScore: Int
    let theme: GameTheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(model.level.index)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.palette.hudText)
                Text("Goal: \(model.foodEaten)/\(model.level.targetFood)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.palette.hudSubtle)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Score \(model.score)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.palette.hudText)
                Text("Best \(bestScore)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.palette.hudSubtle)
            }
        }
    }
}

private struct OverlayCard: View {
    let title: String
    let subtitle: String
    let primaryTitle: String
    let primaryAction: () -> Void
    let secondaryTitle: String
    let secondaryAction: () -> Void
    let theme: GameTheme

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button(action: primaryAction) {
                    Text(primaryTitle)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(theme.palette.button)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Button(action: secondaryAction) {
                    Text(secondaryTitle)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.16))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(28)
        .background(Color.black.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 24)
    }
}
