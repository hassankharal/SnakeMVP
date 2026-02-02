# Snake MVP (iOS SwiftUI)

This folder contains a simple, mobile-first Snake MVP built in SwiftUI. Levels are auto-generated; every time the player clears a level, a new one is generated with higher speed, more obstacles, and a larger goal. The snake moves freely with a touch joystick (not locked to a grid), and themes can be switched from settings.

## Quick Start (Xcode)
1. Open `SnakeMVP.xcodeproj` in Xcode.
2. Select an iPhone simulator or device.
3. Build and run.

## What's Inside
- `SnakeApp.swift`: App entry point.
- `ContentView.swift`: Root view.
- `HomeView.swift`: Home/start screen.
- `SettingsView.swift`: Theme + settings sheet (including haptics).
- `Haptics.swift`: Lightweight haptic helpers.
- `GameView.swift`: UI, overlays, and controls.
- `GameBoardView.swift`: Canvas-based board rendering.
- `GameModel.swift`: Game loop, state, and collisions.
- `LevelGenerator.swift`: Auto-generated levels that get harder.
- `Models.swift`: Shared models.
- `Theme.swift`: Theme palettes.
- `AIArt.swift`: Minimal AI-styled background shapes.
- `JoystickView.swift`: Touch joystick control.

## Level Generation Rules
- Speed increases each level.
- Obstacle count increases each level.
- Target food increases each level.
- World size grows slightly over time.

If you want adjustments (difficulty curve, visuals, sound, or haptics), just say the word.
