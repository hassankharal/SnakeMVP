import SwiftUI

struct ContentView: View {
    @AppStorage("theme") private var themeId: String = GameTheme.neon.id
    @AppStorage("hapticsOn") private var hapticsOn: Bool = true
    @AppStorage("bestScore") private var bestScore: Int = 0

    @StateObject private var model = GameModel()
    @State private var showSettings = false

    private var theme: GameTheme {
        GameTheme(rawValue: themeId) ?? .neon
    }

    var body: some View {
        ZStack {
            switch model.state {
            case .home:
                HomeView(
                    theme: theme,
                    bestScore: bestScore,
                    onStart: {
                        model.startNewGame()
                    },
                    onSettings: {
                        showSettings = true
                    }
                )
            default:
                GameView(
                    model: model,
                    bestScore: $bestScore,
                    hapticsOn: hapticsOn,
                    theme: theme,
                    onHome: {
                        model.endToHome()
                    },
                    onSettings: {
                        showSettings = true
                    }
                )
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(themeId: $themeId, hapticsOn: $hapticsOn)
        }
    }
}
