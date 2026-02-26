import Foundation

enum AppSettingsKey {
    static let theme = "theme"
    static let hapticsEnabled = "hapticsOn"
    static let bestScore = "bestScore"
    static let adsRemoved = "adsRemoved"
}

enum AppSettingsDefault {
    static let hapticsEnabled = true
    static let bestScore = 0
    static let adsRemoved = false
}
