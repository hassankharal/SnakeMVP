import Foundation
import CoreGraphics

struct Obstacle: Identifiable {
    let id = UUID()
    let center: CGPoint
    let radius: CGFloat
}

enum LevelGenerator {
    static func generate(after previous: Level?) -> Level {
        let index = (previous?.index ?? 0) + 1

        let baseWorld: CGFloat = 900
        let world = min(1200, baseWorld + CGFloat(index - 1) * 30)

        let baseSpeed: CGFloat = 140
        let speed = min(300, baseSpeed + CGFloat(index - 1) * 10)

        let targetFood = 5 + (index * 2)
        let obstacleCount = min(30, 4 + (index * 2))

        return Level(
            index: index,
            worldSize: world,
            targetFood: targetFood,
            speed: speed,
            obstacleCount: obstacleCount
        )
    }

    static func generateObstacles(level: Level, blocked: [CGPoint], snakeRadius: CGFloat) -> [Obstacle] {
        guard level.obstacleCount > 0 else { return [] }

        var obstacles: [Obstacle] = []
        let world = level.worldSize
        let radius: CGFloat = 18
        let padding = snakeRadius + radius + 18

        var attempts = 0
        while obstacles.count < level.obstacleCount && attempts < 2000 {
            attempts += 1
            let point = CGPoint(
                x: CGFloat.random(in: padding..<(world - padding)),
                y: CGFloat.random(in: padding..<(world - padding))
            )

            if blocked.contains(where: { $0.distance(to: point) < padding }) {
                continue
            }

            if obstacles.contains(where: { $0.center.distance(to: point) < radius * 2.4 }) {
                continue
            }

            obstacles.append(Obstacle(center: point, radius: radius))
        }

        return obstacles
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
