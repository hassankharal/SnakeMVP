import CoreGraphics
import Foundation

final class GameEngine {
    private enum Constants {
        static let headRadius: CGFloat = 14
        static let bodyRadius: CGFloat = 10
        static let foodRadius: CGFloat = 10

        static let initialSnakeLength: CGFloat = 220
        static let growthPerFood: CGFloat = 26
        static let pointsPerFood = 10

        static let initialDirection = CGVector(dx: 1, dy: 0)
        static let inputDeadZone: CGFloat = 0.15

        static let startSegmentSpacing: CGFloat = 20
        static let wallPadding: CGFloat = headRadius
        static let selfCollisionStartIndex = 6
        static let selfCollisionThreshold: CGFloat = bodyRadius * 0.9

        static let foodSpawnPadding: CGFloat = headRadius + foodRadius + 10
        static let foodAvoidDistance: CGFloat = headRadius + foodRadius + 12
        static let maxFoodPlacementAttempts = 1500
    }

    private let randomSource: RandomSource

    private(set) var level: Level
    private(set) var state: GameState = .home
    private(set) var snakePath: [CGPoint] = []
    private(set) var food: CGPoint = .zero
    private(set) var obstacles: [Obstacle] = []
    private(set) var score = 0
    private(set) var foodEaten = 0

    let headRadius = Constants.headRadius
    let bodyRadius = Constants.bodyRadius
    let foodRadius = Constants.foodRadius

    private(set) var snakeLength: CGFloat = Constants.initialSnakeLength

    private var direction = Constants.initialDirection
    private var inputVector = Constants.initialDirection

    init(randomSource: RandomSource = SystemRandomSource()) {
        self.randomSource = randomSource
        self.level = LevelGenerator.generate(after: nil)
        setupLevel(resetScore: true)
        state = .home
    }

    func startNewGame() {
        level = LevelGenerator.generate(after: nil)
        score = 0
        foodEaten = 0
        setupLevel(resetScore: true)
        state = .playing
    }

    func pauseGame() {
        guard state == .playing else { return }
        state = .paused
    }

    func resumeGame() {
        guard state == .paused else { return }
        state = .playing
    }

    func nextLevel() {
        level = LevelGenerator.generate(after: level)
        setupLevel(resetScore: false)
        state = .playing
    }

    func endToHome() {
        state = .home
    }

    func updateInput(_ vector: CGVector) {
        inputVector = vector
    }

    func advance(by delta: CGFloat) {
        guard state == .playing else { return }
        guard !snakePath.isEmpty else { return }

        updateDirectionFromInputIfNeeded()

        guard let head = snakePath.first else { return }
        let nextHead = CGPoint(
            x: head.x + direction.dx * level.speed * delta,
            y: head.y + direction.dy * level.speed * delta
        )

        if isCollision(at: nextHead) {
            state = .gameOver
            return
        }

        snakePath.insert(nextHead, at: 0)
        trimSnakePath(to: snakeLength)

        if nextHead.distance(to: food) <= (headRadius + foodRadius) {
            foodEaten += 1
            score += Constants.pointsPerFood
            snakeLength += Constants.growthPerFood

            if foodEaten >= level.targetFood {
                state = .levelComplete
            } else {
                food = generateFoodPoint()
            }
        }
    }

    func configureForTesting(
        level: Level? = nil,
        state: GameState? = nil,
        snakePath: [CGPoint]? = nil,
        food: CGPoint? = nil,
        obstacles: [Obstacle]? = nil,
        direction: CGVector? = nil,
        inputVector: CGVector? = nil,
        snakeLength: CGFloat? = nil,
        score: Int? = nil,
        foodEaten: Int? = nil
    ) {
        if let level { self.level = level }
        if let state { self.state = state }
        if let snakePath { self.snakePath = snakePath }
        if let food { self.food = food }
        if let obstacles { self.obstacles = obstacles }
        if let direction { self.direction = direction }
        if let inputVector { self.inputVector = inputVector }
        if let snakeLength { self.snakeLength = snakeLength }
        if let score { self.score = score }
        if let foodEaten { self.foodEaten = foodEaten }
    }

    func respawnFoodForTesting() {
        food = generateFoodPoint()
    }

    private func setupLevel(resetScore: Bool) {
        let worldSize = level.worldSize
        let center = CGPoint(x: worldSize * 0.5, y: worldSize * 0.5)

        direction = Constants.initialDirection
        inputVector = Constants.initialDirection

        snakeLength = Constants.initialSnakeLength
        snakePath = [
            center,
            CGPoint(x: center.x - Constants.startSegmentSpacing, y: center.y),
            CGPoint(x: center.x - Constants.startSegmentSpacing * 2, y: center.y),
            CGPoint(x: center.x - Constants.startSegmentSpacing * 3, y: center.y)
        ]

        obstacles = LevelGenerator.generateObstacles(
            level: level,
            blocked: snakePath,
            snakeRadius: headRadius,
            randomSource: randomSource
        )

        food = generateFoodPoint()

        if resetScore {
            score = 0
        }
        foodEaten = 0
    }

    private func updateDirectionFromInputIfNeeded() {
        let magnitude = hypot(inputVector.dx, inputVector.dy)
        guard magnitude > Constants.inputDeadZone else { return }

        direction = CGVector(
            dx: inputVector.dx / magnitude,
            dy: inputVector.dy / magnitude
        )
    }

    // Head collision uses world bounds, obstacle circles, then path segment proximity.
    private func isCollision(at point: CGPoint) -> Bool {
        if isOutsideBounds(point) {
            return true
        }

        if obstacles.contains(where: { $0.center.distance(to: point) < (headRadius + $0.radius) }) {
            return true
        }

        return collidesWithBody(point)
    }

    private func isOutsideBounds(_ point: CGPoint) -> Bool {
        let minBound = Constants.wallPadding
        let maxX = level.worldSize - Constants.wallPadding
        let maxY = level.worldSize - Constants.wallPadding

        return point.x < minBound || point.y < minBound || point.x > maxX || point.y > maxY
    }

    private func collidesWithBody(_ point: CGPoint) -> Bool {
        guard snakePath.count > Constants.selfCollisionStartIndex + 2 else { return false }

        let startIndex = Constants.selfCollisionStartIndex
        let endIndex = snakePath.count - 1
        guard startIndex < endIndex else { return false }

        for index in startIndex..<endIndex {
            let segmentStart = snakePath[index]
            let segmentEnd = snakePath[index + 1]
            if distanceFromPoint(point, toSegmentFrom: segmentStart, to: segmentEnd) < Constants.selfCollisionThreshold {
                return true
            }
        }

        return false
    }

    private func generateFoodPoint() -> CGPoint {
        let worldSize = level.worldSize
        let minCoordinate = Constants.foodSpawnPadding
        let maxCoordinate = worldSize - Constants.foodSpawnPadding

        var attempts = 0
        while attempts < Constants.maxFoodPlacementAttempts {
            attempts += 1

            let candidate = CGPoint(
                x: randomSource.nextCGFloat(in: minCoordinate...maxCoordinate),
                y: randomSource.nextCGFloat(in: minCoordinate...maxCoordinate)
            )

            let overlapsSnake = snakePath.contains { $0.distance(to: candidate) < Constants.foodAvoidDistance }
            if overlapsSnake {
                continue
            }

            let overlapsObstacle = obstacles.contains { obstacle in
                obstacle.center.distance(to: candidate) < (obstacle.radius + foodRadius + 12)
            }
            if overlapsObstacle {
                continue
            }

            return candidate
        }

        return CGPoint(x: worldSize * 0.5, y: worldSize * 0.5)
    }

    // Keeps a polyline tail by trimming to a fixed arc length.
    private func trimSnakePath(to maxLength: CGFloat) {
        guard snakePath.count > 1 else { return }

        var consumedLength: CGFloat = 0
        var trimmedPath: [CGPoint] = []

        guard let firstPoint = snakePath.first else { return }
        trimmedPath.append(firstPoint)

        for point in snakePath.dropFirst() {
            guard let previousPoint = trimmedPath.last else { break }
            let segmentLength = previousPoint.distance(to: point)

            if segmentLength <= 0.001 {
                continue
            }

            if consumedLength + segmentLength >= maxLength {
                let remaining = max(0, maxLength - consumedLength)
                let t = remaining / segmentLength
                let tailPoint = CGPoint(
                    x: previousPoint.x + (point.x - previousPoint.x) * t,
                    y: previousPoint.y + (point.y - previousPoint.y) * t
                )
                trimmedPath.append(tailPoint)
                break
            }

            consumedLength += segmentLength
            trimmedPath.append(point)
        }

        snakePath = trimmedPath
    }

    private func distanceFromPoint(_ point: CGPoint, toSegmentFrom a: CGPoint, to b: CGPoint) -> CGFloat {
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let ap = CGPoint(x: point.x - a.x, y: point.y - a.y)
        let abLengthSquared = ab.x * ab.x + ab.y * ab.y

        guard abLengthSquared > 0 else {
            return point.distance(to: a)
        }

        let projection = (ap.x * ab.x + ap.y * ab.y) / abLengthSquared
        let t = max(0, min(1, projection))
        let closest = CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
        return point.distance(to: closest)
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
