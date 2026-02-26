# Snake MVP (iOS SwiftUI)

## What This App Is
Snake MVP is a mobile-first iOS Snake game built with SwiftUI. The snake is controlled with a touch joystick and moves in continuous space. Levels are auto-generated and progressively harder.

## Core Features
- Free-flowing snake movement (not grid-locked)
- Auto-generated levels with increased speed, target food, and obstacle density
- Home screen, in-game HUD, pause/game-over/level-complete overlays
- Theme switching (Neon, Sunrise, Ocean)
- Haptics toggle
- Ad placement placeholders (top and bottom banner areas)
- Paid-mode toggle placeholder that removes ad placements locally

## Project Layout
- `SnakeMVP/SnakeApp.swift`: App entry point
- `SnakeMVP/ContentView.swift`: Root routing between Home and Game
- `SnakeMVP/GameView.swift`: Main game screen + controls + overlays
- `SnakeMVP/GameBoardView.swift`: Canvas rendering of board, snake, food, and obstacles
- `SnakeMVP/GameModel.swift`: ObservableObject adapter for UI and frame timing
- `SnakeMVP/GameEngine.swift`: Core game logic/state transitions (test surface)
- `SnakeMVP/LevelGenerator.swift`: Level and obstacle generation
- `SnakeMVP/RandomSource.swift`: Deterministic/random source abstraction for generation
- `SnakeMVP/Theme.swift`: Theme palette definitions
- `SnakeMVP/SettingsView.swift`: Theme/haptics/paid toggle settings
- `SnakeMVP/HomeView.swift`: Start screen
- `SnakeMVP/AdBannerView.swift`: Ad placeholder UI component
- `SnakeMVP/Monetization.swift`: Ad visibility policy helper
- `SnakeMVP/AppSettings.swift`: Centralized AppStorage keys/defaults

## Build And Run
1. Open `/Users/hassankharal/Documents/Dev/Snake/SnakeMVP.xcodeproj` in Xcode.
2. Select simulator `iPhone 17` (or another available simulator).
3. Run the `SnakeMVP` scheme.

CLI build command:

```bash
xcodebuild -project /Users/hassankharal/Documents/Dev/Snake/SnakeMVP.xcodeproj \
  -scheme SnakeMVP \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

## Run Tests
```bash
xcodebuild test -project /Users/hassankharal/Documents/Dev/Snake/SnakeMVP.xcodeproj \
  -scheme SnakeMVP \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Test target: `SnakeMVPTests`

## Monetization Placeholder Behavior
- `adsRemoved = false`: top and bottom ad placeholder banners are shown.
- `adsRemoved = true`: banner regions are removed.
- Current implementation is local state (`@AppStorage`) and not connected to StoreKit.

## Limitations
- No real ad SDK integration yet
- No StoreKit purchase flow yet
- No backend persistence or cloud sync
- Gameplay tests cover logic, not snapshot/UI pixel tests

## Handoff Docs
- `/Users/hassankharal/Documents/Dev/Snake/DEVELOPMENT.md`
- `/Users/hassankharal/Documents/Dev/Snake/STATE_OF_APP.md`
