import SwiftUI

struct ThemePalette {
    let backgroundTop: Color
    let backgroundBottom: Color
    let board: Color
    let snakeBody: Color
    let snakeHead: Color
    let food: Color
    let obstacle: Color
    let hudText: Color
    let hudSubtle: Color
    let button: Color
    let joystickBase: Color
    let joystickKnob: Color
    let boardOutline: Color
}

enum GameTheme: String, CaseIterable, Identifiable {
    case neon
    case sunrise
    case ocean

    var id: String { rawValue }

    var name: String {
        switch self {
        case .neon: return "Neon"
        case .sunrise: return "Sunrise"
        case .ocean: return "Ocean"
        }
    }

    var palette: ThemePalette {
        switch self {
        case .neon:
            return ThemePalette(
                backgroundTop: Color(red: 0.09, green: 0.12, blue: 0.16),
                backgroundBottom: Color(red: 0.05, green: 0.07, blue: 0.10),
                board: Color(red: 0.12, green: 0.16, blue: 0.20),
                snakeBody: Color(red: 0.32, green: 0.86, blue: 0.55),
                snakeHead: Color(red: 0.55, green: 0.97, blue: 0.68),
                food: Color(red: 1.0, green: 0.40, blue: 0.35),
                obstacle: Color(red: 0.45, green: 0.52, blue: 0.60),
                hudText: .white,
                hudSubtle: Color.white.opacity(0.75),
                button: Color(red: 0.20, green: 0.60, blue: 0.95),
                joystickBase: Color.white.opacity(0.16),
                joystickKnob: Color.white,
                boardOutline: Color.white.opacity(0.12)
            )
        case .sunrise:
            return ThemePalette(
                backgroundTop: Color(red: 0.20, green: 0.09, blue: 0.10),
                backgroundBottom: Color(red: 0.12, green: 0.05, blue: 0.07),
                board: Color(red: 0.26, green: 0.12, blue: 0.12),
                snakeBody: Color(red: 0.96, green: 0.70, blue: 0.34),
                snakeHead: Color(red: 0.99, green: 0.84, blue: 0.55),
                food: Color(red: 0.90, green: 0.35, blue: 0.40),
                obstacle: Color(red: 0.75, green: 0.55, blue: 0.52),
                hudText: Color(red: 1.0, green: 0.96, blue: 0.92),
                hudSubtle: Color(red: 1.0, green: 0.90, blue: 0.85).opacity(0.8),
                button: Color(red: 0.97, green: 0.56, blue: 0.34),
                joystickBase: Color.white.opacity(0.18),
                joystickKnob: Color.white,
                boardOutline: Color.white.opacity(0.14)
            )
        case .ocean:
            return ThemePalette(
                backgroundTop: Color(red: 0.06, green: 0.12, blue: 0.20),
                backgroundBottom: Color(red: 0.03, green: 0.07, blue: 0.14),
                board: Color(red: 0.07, green: 0.18, blue: 0.24),
                snakeBody: Color(red: 0.35, green: 0.80, blue: 0.98),
                snakeHead: Color(red: 0.55, green: 0.88, blue: 0.98),
                food: Color(red: 0.98, green: 0.77, blue: 0.30),
                obstacle: Color(red: 0.40, green: 0.55, blue: 0.70),
                hudText: Color(red: 0.90, green: 0.96, blue: 1.0),
                hudSubtle: Color(red: 0.78, green: 0.88, blue: 0.98),
                button: Color(red: 0.25, green: 0.70, blue: 0.95),
                joystickBase: Color.white.opacity(0.16),
                joystickKnob: Color.white,
                boardOutline: Color.white.opacity(0.12)
            )
        }
    }
}
