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

## Prerequisites
- macOS with Xcode installed
- iOS Simulator runtime installed from Xcode

## Build And Run (Any Workstation)
1. From the repository root, list available simulator destinations:

```bash
xcodebuild -showdestinations -project SnakeMVP.xcodeproj -scheme SnakeMVP
```

2. Pick an available simulator (for example `iPhone 16`) and build:

```bash
SIMULATOR_NAME="iPhone 16" # replace with one from showdestinations

xcodebuild -project SnakeMVP.xcodeproj \
  -scheme SnakeMVP \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=${SIMULATOR_NAME}" \
  build
```

3. Run in Xcode if preferred:
- `open SnakeMVP.xcodeproj`
- Select any installed iOS simulator
- Run scheme `SnakeMVP`

## Run Tests (Any Workstation)
```bash
SIMULATOR_NAME="iPhone 16" # replace with one from showdestinations

xcodebuild test -project SnakeMVP.xcodeproj \
  -scheme SnakeMVP \
  -destination "platform=iOS Simulator,name=${SIMULATOR_NAME}"
```

Test target: `SnakeMVPTests`

## Quick Smoke Test Checklist
1. Launch app to Home screen.
2. Start game and verify joystick movement.
3. Pause and resume from overlay.
4. Trigger game over and restart.
5. Complete a level and continue.
6. Open settings and change theme.
7. Toggle haptics and verify feedback.
8. Toggle paid mode and confirm ad placeholders hide/show.

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
- `DEVELOPMENT.md`
- `STATE_OF_APP.md`
