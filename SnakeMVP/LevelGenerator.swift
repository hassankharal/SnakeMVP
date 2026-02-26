import Foundation
import CoreGraphics

struct Obstacle: Identifiable {
    let id = UUID()
    let center: CGPoint
    let radius: CGFloat
}

enum LevelGenerator {
    private enum Constants {
        static let baseWorldSize: CGFloat = 900
        static let maxWorldSize: CGFloat = 1200
        static let worldGrowthPerLevel: CGFloat = 30

        static let baseSpeed: CGFloat = 140
        static let maxSpeed: CGFloat = 300
        static let speedGrowthPerLevel: CGFloat = 10

        static let baseTargetFood = 5
        static let targetFoodGrowthPerLevel = 2

        static let baseObstacleCount = 4
        static let obstacleGrowthPerLevel = 2
        static let maxObstacleCount = 30

        static let obstacleRadius: CGFloat = 18
        static let obstaclePadding: CGFloat = 18
        static let maxPlacementAttempts = 2000
        static let obstacleSpacingMultiplier: CGFloat = 2.4
    }

    static func generate(after previous: Level?) -> Level {
        let index = (previous?.index ?? 0) + 1

        let worldSize = min(
            Constants.maxWorldSize,
            Constants.baseWorldSize + CGFloat(index - 1) * Constants.worldGrowthPerLevel
        )

        let speed = min(
            Constants.maxSpeed,
            Constants.baseSpeed + CGFloat(index - 1) * Constants.speedGrowthPerLevel
        )

        let targetFood = Constants.baseTargetFood + (index * Constants.targetFoodGrowthPerLevel)
        let obstacleCount = min(
            Constants.maxObstacleCount,
            Constants.baseObstacleCount + (index * Constants.obstacleGrowthPerLevel)
        )

        return Level(
            index: index,
            worldSize: worldSize,
            targetFood: targetFood,
            speed: speed,
            obstacleCount: obstacleCount
        )
    }

    static func generateObstacles(
        level: Level,
        blocked: [CGPoint],
        snakeRadius: CGFloat,
        randomSource: RandomSource
    ) -> [Obstacle] {
        guard level.obstacleCount > 0 else { return [] }

        var obstacles: [Obstacle] = []
        let worldSize = level.worldSize
        let obstacleRadius = Constants.obstacleRadius
        let spawnPadding = snakeRadius + obstacleRadius + Constants.obstaclePadding

        var attempts = 0
        while obstacles.count < level.obstacleCount && attempts < Constants.maxPlacementAttempts {
            attempts += 1

            let candidate = CGPoint(
                x: randomSource.nextCGFloat(in: spawnPadding...(worldSize - spawnPadding)),
                y: randomSource.nextCGFloat(in: spawnPadding...(worldSize - spawnPadding))
            )

            let isTooCloseToBlocked = blocked.contains { $0.distance(to: candidate) < spawnPadding }
            if isTooCloseToBlocked {
                continue
            }

            let minObstacleDistance = obstacleRadius * Constants.obstacleSpacingMultiplier
            let isTooCloseToObstacle = obstacles.contains { $0.center.distance(to: candidate) < minObstacleDistance }
            if isTooCloseToObstacle {
                continue
            }

            obstacles.append(Obstacle(center: candidate, radius: obstacleRadius))
        }

        return obstacles
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
