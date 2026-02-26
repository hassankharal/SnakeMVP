import SwiftUI

struct ContentView: View {
    @AppStorage(AppSettingsKey.theme) private var themeId: String = GameTheme.neon.rawValue
    @AppStorage(AppSettingsKey.hapticsEnabled) private var hapticsOn: Bool = AppSettingsDefault.hapticsEnabled
    @AppStorage(AppSettingsKey.bestScore) private var bestScore: Int = AppSettingsDefault.bestScore
    @AppStorage(AppSettingsKey.adsRemoved) private var adsRemoved: Bool = AppSettingsDefault.adsRemoved

    @StateObject private var model = GameModel()
    @State private var isSettingsPresented = false

    private var theme: GameTheme {
        GameTheme(rawValue: themeId) ?? .neon
    }

    var body: some View {
        Group {
            switch model.state {
            case .home:
                HomeView(
                    theme: theme,
                    bestScore: bestScore,
                    adsRemoved: adsRemoved,
                    onStart: model.startNewGame,
                    onSettings: { isSettingsPresented = true }
                )
            default:
                GameView(
                    model: model,
                    bestScore: $bestScore,
                    hapticsOn: hapticsOn,
                    adsRemoved: adsRemoved,
                    theme: theme,
                    onHome: model.endToHome,
                    onSettings: { isSettingsPresented = true }
                )
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(themeId: $themeId, hapticsOn: $hapticsOn, adsRemoved: $adsRemoved)
        }
    }
}
