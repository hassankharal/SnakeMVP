# DEVELOPMENT

## Architecture Map
### UI Layer
- `SnakeMVP/ContentView.swift`: Chooses `HomeView` or `GameView` based on `GameModel.state`.
- `SnakeMVP/HomeView.swift`: Entry screen and quick actions.
- `SnakeMVP/GameView.swift`: HUD, controls, overlays, ad placeholders.
- `SnakeMVP/GameBoardView.swift`: Draws current world state.
- `SnakeMVP/SettingsView.swift`: Theme/haptics/paid toggle settings.

### State + Engine Layer
- `SnakeMVP/GameModel.swift`: UI adapter and display-link loop.
- `SnakeMVP/GameEngine.swift`: Pure game state transitions, collisions, progression, spawning.

### Generation Layer
- `SnakeMVP/LevelGenerator.swift`: Level scaling and obstacle generation.
- `SnakeMVP/RandomSource.swift`: Random seam for deterministic tests.

### App Configuration Layer
- `SnakeMVP/AppSettings.swift`: Single source of truth for persisted key names/defaults.
- `SnakeMVP/Monetization.swift`: Ad-visibility policy helper.
- `SnakeMVP/Theme.swift`: Visual theme definitions.

## Data Flow
1. `GameModel` receives UI input (`updateInput`) and frame ticks (`CADisplayLink`).
2. `GameModel` calls `GameEngine.advance(by:)`.
3. `GameEngine` mutates gameplay state.
4. `GameModel` publishes updated state for SwiftUI rendering.

## Testing Strategy
### Unit Tests
- Target: `SnakeMVPTests`
- Files:
  - `SnakeMVPTests/GameEngineTests.swift`
  - `SnakeMVPTests/MonetizationTests.swift`

### Covered Areas
- State transitions (home/playing/paused/game over/level complete)
- Collision handling (wall/obstacle/body segment)
- Food collection side effects (score, growth, respawn)
- Level progression monotonicity
- Next-level transition invariants (score carry-over, per-level counter reset)
- Spawn constraints (food/obstacles avoid blocked regions)
- Input edge cases and paused behavior
- Ad placement policy regression

### Commands
```bash
SIMULATOR_NAME="iPhone 16" # replace with an installed simulator

xcodebuild -project SnakeMVP.xcodeproj \
  -scheme SnakeMVP \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=${SIMULATOR_NAME}" \
  build
```

```bash
SIMULATOR_NAME="iPhone 16" # replace with an installed simulator

xcodebuild test -project SnakeMVP.xcodeproj \
  -scheme SnakeMVP \
  -destination "platform=iOS Simulator,name=${SIMULATOR_NAME}"
```

If you need to discover valid destinations on a new machine:

```bash
xcodebuild -showdestinations -project SnakeMVP.xcodeproj -scheme SnakeMVP
```

## Extension Points
### Controls
- Tune joystick behavior in `SnakeMVP/JoystickView.swift` and dead-zone in `GameEngine.Constants.inputDeadZone`.

### Difficulty
- Adjust scaling in `SnakeMVP/LevelGenerator.swift` constants.

### Theme System
- Add new themes in `SnakeMVP/Theme.swift` and they will appear automatically via `GameTheme.allCases`.

### Ads Integration
- Replace `AdBannerView` with ad SDK wrapper.
- Keep visibility gating through `AdPlacementPolicy.shouldShowBanners(adsRemoved:)`.

### StoreKit Hookup
- Replace `adsRemoved` local toggle with entitlement-backed flag.
- Keep `AppSettingsKey.adsRemoved` as fallback/offline cache if needed.

## Known Technical Debt
- Display-link loop and engine state are tightly coupled through `GameModel`; no separate scheduler abstraction.
- No UI snapshot tests.
- No telemetry/analytics for balancing or crash diagnostics.
- No localization workflow yet.
