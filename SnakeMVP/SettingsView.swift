import SwiftUI

struct SettingsView: View {
    @Binding var themeId: String
    @Binding var hapticsOn: Bool
    @Binding var adsRemoved: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Theme")) {
                    Picker("Theme", selection: $themeId) {
                        ForEach(GameTheme.allCases) { theme in
                            Text(theme.name).tag(theme.id)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text("Feedback")) {
                    Toggle("Haptics", isOn: $hapticsOn)
                }

                Section(header: Text("Paid")) {
                    Toggle("Remove Ads (Paid)", isOn: $adsRemoved)
                }

                Section(footer: Text("More options like sound, difficulty, and control sensitivity can be added next.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
