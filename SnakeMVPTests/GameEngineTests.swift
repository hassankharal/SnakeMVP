import CoreGraphics
import XCTest
@testable import SnakeMVP

final class GameEngineTests: XCTestCase {
    func testInitialStateStartsAtHomeWithSeededContent() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.2, 0.8]))

        XCTAssertEqual(engine.state, .home)
        XCTAssertEqual(engine.score, 0)
        XCTAssertEqual(engine.foodEaten, 0)
        XCTAssertFalse(engine.snakePath.isEmpty)
        XCTAssertGreaterThan(engine.level.worldSize, 0)
    }

    func testStateTransitionsFromHomeThroughPauseResumeAndBackHome() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.3, 0.6]))

        engine.startNewGame()
        XCTAssertEqual(engine.state, .playing)

        engine.pauseGame()
        XCTAssertEqual(engine.state, .paused)

        engine.resumeGame()
        XCTAssertEqual(engine.state, .playing)

        engine.endToHome()
        XCTAssertEqual(engine.state, .home)
    }

    func testCollisionWithWallMovesToGameOver() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.5]))
        let level = Level(index: 1, worldSize: 140, targetFood: 5, speed: 140, obstacleCount: 0)

        engine.configureForTesting(
            level: level,
            state: .playing,
            snakePath: [
                CGPoint(x: 100, y: 70),
                CGPoint(x: 80, y: 70),
                CGPoint(x: 60, y: 70)
            ],
            food: CGPoint(x: 20, y: 20),
            obstacles: [],
            direction: CGVector(dx: 1, dy: 0),
            inputVector: CGVector(dx: 1, dy: 0)
        )

        engine.advance(by: 0.4)

        XCTAssertEqual(engine.state, .gameOver)
    }

    func testCollisionWithObstacleMovesToGameOver() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.5]))
        let level = Level(index: 1, worldSize: 500, targetFood: 5, speed: 140, obstacleCount: 0)

        engine.configureForTesting(
            level: level,
            state: .playing,
            snakePath: [
                CGPoint(x: 100, y: 100),
                CGPoint(x: 80, y: 100),
                CGPoint(x: 60, y: 100)
            ],
            food: CGPoint(x: 320, y: 300),
            obstacles: [Obstacle(center: CGPoint(x: 150, y: 100), radius: 18)],
            direction: CGVector(dx: 1, dy: 0),
            inputVector: CGVector(dx: 1, dy: 0)
        )

        engine.advance(by: 0.4)

        XCTAssertEqual(engine.state, .gameOver)
    }

    func testCollisionWithSnakeBodySegmentMovesToGameOver() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.5]))
        let level = Level(index: 1, worldSize: 500, targetFood: 5, speed: 100, obstacleCount: 0)

        engine.configureForTesting(
            level: level,
            state: .playing,
            snakePath: [
                CGPoint(x: 220, y: 200),
                CGPoint(x: 200, y: 200),
                CGPoint(x: 180, y: 200),
                CGPoint(x: 160, y: 200),
                CGPoint(x: 140, y: 200),
                CGPoint(x: 120, y: 200),
                CGPoint(x: 120, y: 180),
                CGPoint(x: 140, y: 180),
                CGPoint(x: 160, y: 180),
                CGPoint(x: 180, y: 180),
                CGPoint(x: 200, y: 180),
                CGPoint(x: 220, y: 180)
            ],
            food: CGPoint(x: 360, y: 360),
            obstacles: [],
            direction: CGVector(dx: 0, dy: -1),
            inputVector: CGVector(dx: 0, dy: -1)
        )

        engine.advance(by: 0.2)

        XCTAssertEqual(engine.state, .gameOver)
    }

    func testFoodCollectionIncrementsScoreAndLengthAndRespawnsFood() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.1, 0.9, 0.8, 0.2]))
        let level = Level(index: 1, worldSize: 500, targetFood: 3, speed: 100, obstacleCount: 0)
        let originalLength = engine.snakeLength

        engine.configureForTesting(
            level: level,
            state: .playing,
            snakePath: [
                CGPoint(x: 100, y: 100),
                CGPoint(x: 80, y: 100),
                CGPoint(x: 60, y: 100)
            ],
            food: CGPoint(x: 110, y: 100),
            obstacles: [],
            direction: CGVector(dx: 1, dy: 0),
            inputVector: CGVector(dx: 1, dy: 0),
            score: 0,
            foodEaten: 0
        )

        engine.advance(by: 0.1)

        XCTAssertEqual(engine.state, .playing)
        XCTAssertEqual(engine.score, 10)
        XCTAssertEqual(engine.foodEaten, 1)
        XCTAssertGreaterThan(engine.snakeLength, originalLength)
        XCTAssertNotEqual(engine.food, CGPoint(x: 110, y: 100))
    }

    func testLevelCompletesWhenTargetFoodReached() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.4, 0.6]))
        let level = Level(index: 1, worldSize: 500, targetFood: 1, speed: 100, obstacleCount: 0)

        engine.configureForTesting(
            level: level,
            state: .playing,
            snakePath: [
                CGPoint(x: 100, y: 100),
                CGPoint(x: 80, y: 100),
                CGPoint(x: 60, y: 100)
            ],
            food: CGPoint(x: 110, y: 100),
            obstacles: [],
            direction: CGVector(dx: 1, dy: 0),
            inputVector: CGVector(dx: 1, dy: 0),
            score: 0,
            foodEaten: 0
        )

        engine.advance(by: 0.1)

        XCTAssertEqual(engine.state, .levelComplete)
    }

    func testLevelProgressionMonotonicallyIncreasesDifficultySignals() {
        let level1 = LevelGenerator.generate(after: nil)
        let level2 = LevelGenerator.generate(after: level1)
        let level3 = LevelGenerator.generate(after: level2)

        XCTAssertGreaterThan(level2.speed, level1.speed)
        XCTAssertGreaterThan(level3.speed, level2.speed)

        XCTAssertGreaterThan(level2.targetFood, level1.targetFood)
        XCTAssertGreaterThan(level3.targetFood, level2.targetFood)

        XCTAssertGreaterThan(level2.obstacleCount, level1.obstacleCount)
        XCTAssertGreaterThan(level3.obstacleCount, level2.obstacleCount)

        XCTAssertGreaterThanOrEqual(level2.worldSize, level1.worldSize)
        XCTAssertGreaterThanOrEqual(level3.worldSize, level2.worldSize)
    }

    func testGeneratedObstaclesAvoidBlockedPoints() {
        let random = SequenceRandomSource(values: [0.5, 0.5, 0.1, 0.1, 0.9, 0.9, 0.2, 0.8])
        let level = Level(index: 1, worldSize: 500, targetFood: 6, speed: 140, obstacleCount: 6)
        let blocked = [CGPoint(x: 250, y: 250), CGPoint(x: 240, y: 250)]

        let obstacles = LevelGenerator.generateObstacles(
            level: level,
            blocked: blocked,
            snakeRadius: 14,
            randomSource: random
        )

        XCTAssertFalse(obstacles.isEmpty)
        XCTAssertLessThanOrEqual(obstacles.count, level.obstacleCount)

        for obstacle in obstacles {
            let tooClose = blocked.contains { $0.distance(to: obstacle.center) < 50 }
            XCTAssertFalse(tooClose)
        }
    }

    func testGeneratedFoodAvoidsSnakeAndObstacles() {
        let random = SequenceRandomSource(values: [0.5, 0.5, 0.1, 0.1, 0.9, 0.9])
        let engine = GameEngine(randomSource: random)
        let level = Level(index: 1, worldSize: 400, targetFood: 5, speed: 140, obstacleCount: 0)

        engine.configureForTesting(
            level: level,
            state: .playing,
            snakePath: [
                CGPoint(x: 200, y: 200),
                CGPoint(x: 180, y: 200),
                CGPoint(x: 160, y: 200)
            ],
            food: CGPoint(x: 200, y: 200),
            obstacles: [Obstacle(center: CGPoint(x: 80, y: 80), radius: 18)]
        )

        engine.respawnFoodForTesting()

        let food = engine.food
        XCTAssertGreaterThan(food.distance(to: CGPoint(x: 200, y: 200)), 20)
        XCTAssertGreaterThan(food.distance(to: CGPoint(x: 80, y: 80)), 20)
    }

    func testInputDeadZoneDoesNotChangeDirection() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.4]))
        let level = Level(index: 1, worldSize: 500, targetFood: 5, speed: 100, obstacleCount: 0)

        engine.configureForTesting(
            level: level,
            state: .playing,
            snakePath: [
                CGPoint(x: 100, y: 100),
                CGPoint(x: 80, y: 100),
                CGPoint(x: 60, y: 100)
            ],
            food: CGPoint(x: 300, y: 300),
            obstacles: [],
            direction: CGVector(dx: 1, dy: 0),
            inputVector: CGVector(dx: 1, dy: 0)
        )

        engine.updateInput(CGVector(dx: 0.01, dy: 0.01))
        engine.advance(by: 0.1)

        guard let head = engine.snakePath.first else {
            XCTFail("Expected snake head")
            return
        }

        XCTAssertGreaterThan(head.x, 100)
        XCTAssertEqual(head.y, 100, accuracy: 0.01)
    }

    func testPausedStateDoesNotAdvanceGame() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.4]))

        engine.startNewGame()
        engine.pauseGame()

        let before = engine.snakePath
        engine.advance(by: 0.4)

        XCTAssertEqual(engine.state, .paused)
        XCTAssertEqual(engine.snakePath, before)
    }

    func testNextLevelKeepsScoreAndResetsLevelFoodCounter() {
        let engine = GameEngine(randomSource: SequenceRandomSource(values: [0.25, 0.75]))

        engine.startNewGame()
        let previousLevelIndex = engine.level.index
        engine.configureForTesting(state: .levelComplete, score: 80, foodEaten: 3)

        engine.nextLevel()

        XCTAssertEqual(engine.state, .playing)
        XCTAssertEqual(engine.level.index, previousLevelIndex + 1)
        XCTAssertEqual(engine.score, 80)
        XCTAssertEqual(engine.foodEaten, 0)
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
