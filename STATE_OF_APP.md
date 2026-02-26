# STATE OF APP

## Current Status
The project is in a stable MVP state with deterministic unit tests around gameplay logic.

## What Is Stable
- App builds successfully on iOS simulator.
- Core game loop functions with free-flow movement.
- Level progression and obstacle generation are working.
- Pause/resume/home transitions are stable.
- Theme switching and haptics toggles are persisted.
- Ad visibility gating is deterministic and test-covered.

## What Is Placeholder
- Ad banners are UI placeholders only.
- Paid mode is a local toggle only; not connected to purchases.
- App icon assets are not fully populated.
- No production-grade telemetry, crash reporting, or analytics.

## Validation Snapshot
### Automated
- `xcodebuild ... build`: passing
- `xcodebuild ... test`: passing

### Manual Smoke Checklist
1. Launch app to Home screen.
2. Start game and verify joystick movement.
3. Pause and resume from overlay.
4. Trigger game over and restart.
5. Complete level and continue to next level.
6. Open settings and change theme.
7. Toggle haptics and verify food/terminal event feedback.
8. Toggle paid mode and verify ad placeholders hide/show.

## Suggested Backlog (Priority Order)
1. Integrate StoreKit for real paid entitlement and tie it to `adsRemoved`.
2. Replace ad placeholders with real ad SDK integration points.
3. Add UI tests/snapshot tests for overlay and layout regressions.
4. Add gameplay analytics (session length, level reached, fail reason).
5. Add audio/sound controls and content settings.
6. Add localization and accessibility QA pass.

## If Another Engineer Takes Over
Start with these files in order:
1. `SnakeMVP/GameEngine.swift`
2. `SnakeMVP/GameModel.swift`
3. `SnakeMVP/GameView.swift`
4. `SnakeMVP/LevelGenerator.swift`
5. `SnakeMVPTests/GameEngineTests.swift`

Then run:
- Build command from `README.md`
- Test command from `README.md`
