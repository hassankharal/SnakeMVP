import Foundation
import SwiftUI
import QuartzCore

final class GameModel: ObservableObject {
    @Published private(set) var level: Level
    @Published private(set) var state: GameState = .home
    @Published private(set) var snakePath: [CGPoint] = []
    @Published private(set) var food: CGPoint = .zero
    @Published private(set) var obstacles: [Obstacle] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var foodEaten: Int = 0

    let headRadius: CGFloat = 14
    let bodyRadius: CGFloat = 10
    let foodRadius: CGFloat = 10

    private var snakeLength: CGFloat = 220
    private var direction: CGVector = CGVector(dx: 1, dy: 0)
    private var lastInput: CGVector = CGVector(dx: 1, dy: 0)
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    init() {
        self.level = LevelGenerator.generate(after: nil)
        setupLevel(resetScore: true)
        state = .home
    }

    func startNewGame() {
        stopLoop()
        level = LevelGenerator.generate(after: nil)
        score = 0
        foodEaten = 0
        setupLevel(resetScore: true)
        state = .playing
        startLoop()
    }

    func resumeGame() {
        guard state == .paused else { return }
        state = .playing
        startLoop()
    }

    func pauseGame() {
        guard state == .playing else { return }
        state = .paused
        stopLoop()
    }

    func nextLevel() {
        stopLoop()
        level = LevelGenerator.generate(after: level)
        setupLevel(resetScore: false)
        state = .playing
        startLoop()
    }

    func endToHome() {
        stopLoop()
        state = .home
    }

    func updateInput(_ vector: CGVector) {
        lastInput = vector
    }

    private func startLoop() {
        stopLoop()
        lastTimestamp = 0
        let link = CADisplayLink(target: self, selector: #selector(step))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopLoop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
    }

    @objc private func step(link: CADisplayLink) {
        guard state == .playing else { return }
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        let dt = CGFloat(link.timestamp - lastTimestamp)
        lastTimestamp = link.timestamp
        tick(delta: min(dt, 0.05))
    }

    private func tick(delta: CGFloat) {
        guard !snakePath.isEmpty else { return }

        let inputMagnitude = hypot(lastInput.dx, lastInput.dy)
        if inputMagnitude > 0.15 {
            direction = CGVector(dx: lastInput.dx / inputMagnitude, dy: lastInput.dy / inputMagnitude)
        }

        let speed = level.speed
        let head = snakePath[0]
        let nextHead = CGPoint(
            x: head.x + direction.dx * speed * delta,
            y: head.y + direction.dy * speed * delta
        )

        if isCollision(at: nextHead) {
            state = .gameOver
            stopLoop()
            return
        }

        snakePath.insert(nextHead, at: 0)
        trimSnakePath(to: snakeLength)

        if nextHead.distance(to: food) <= (headRadius + foodRadius) {
            foodEaten += 1
            score += 10
            snakeLength += 26

            if foodEaten >= level.targetFood {
                state = .levelComplete
                stopLoop()
            } else {
                food = generateFood()
            }
        }
    }

    private func setupLevel(resetScore: Bool) {
        let world = level.worldSize
        let center = CGPoint(x: world * 0.5, y: world * 0.5)
        direction = CGVector(dx: 1, dy: 0)
        lastInput = direction

        snakeLength = 220
        snakePath = [
            center,
            CGPoint(x: center.x - 20, y: center.y),
            CGPoint(x: center.x - 40, y: center.y),
            CGPoint(x: center.x - 60, y: center.y)
        ]

        obstacles = LevelGenerator.generateObstacles(
            level: level,
            blocked: snakePath,
            snakeRadius: headRadius
        )
        food = generateFood()

        if resetScore {
            score = 0
            foodEaten = 0
        } else {
            foodEaten = 0
        }
    }

    private func isCollision(at point: CGPoint) -> Bool {
        let world = level.worldSize
        if point.x < headRadius || point.y < headRadius || point.x > world - headRadius || point.y > world - headRadius {
            return true
        }

        for obstacle in obstacles {
            if obstacle.center.distance(to: point) < (headRadius + obstacle.radius) {
                return true
            }
        }

        if snakePath.count > 8 {
            for index in 6..<(snakePath.count - 1) {
                let a = snakePath[index]
                let b = snakePath[index + 1]
                if distancePointToSegment(point, a, b) < bodyRadius * 0.9 {
                    return true
                }
            }
        }

        return false
    }

    private func generateFood() -> CGPoint {
        let world = level.worldSize
        let padding = headRadius + foodRadius + 10

        var attempts = 0
        while attempts < 1500 {
            attempts += 1
            let point = CGPoint(
                x: CGFloat.random(in: padding..<(world - padding)),
                y: CGFloat.random(in: padding..<(world - padding))
            )

            if snakePath.contains(where: { $0.distance(to: point) < (headRadius + foodRadius + 12) }) {
                continue
            }

            if obstacles.contains(where: { $0.center.distance(to: point) < ($0.radius + foodRadius + 12) }) {
                continue
            }

            return point
        }

        return CGPoint(x: world * 0.5, y: world * 0.5)
    }

    private func trimSnakePath(to length: CGFloat) {
        guard snakePath.count > 1 else { return }

        var total: CGFloat = 0
        var trimmed: [CGPoint] = [snakePath[0]]

        for index in 1..<snakePath.count {
            let prev = trimmed.last!
            let point = snakePath[index]
            let dist = prev.distance(to: point)
            if dist <= 0.001 { continue }

            if total + dist >= length {
                let remaining = max(0, length - total)
                let t = remaining / dist
                let tail = CGPoint(
                    x: prev.x + (point.x - prev.x) * t,
                    y: prev.y + (point.y - prev.y) * t
                )
                trimmed.append(tail)
                break
            } else {
                total += dist
                trimmed.append(point)
            }
        }

        snakePath = trimmed
    }

    private func distancePointToSegment(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let ap = CGPoint(x: p.x - a.x, y: p.y - a.y)
        let abLen2 = ab.x * ab.x + ab.y * ab.y
        if abLen2 == 0 { return p.distance(to: a) }
        let t = max(0, min(1, (ap.x * ab.x + ap.y * ab.y) / abLen2))
        let closest = CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
        return p.distance(to: closest)
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
