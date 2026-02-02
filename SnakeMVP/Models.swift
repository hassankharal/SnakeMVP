import Foundation
import CoreGraphics

struct Level {
    let index: Int
    let worldSize: CGFloat
    let targetFood: Int
    let speed: CGFloat
    let obstacleCount: Int
}

enum GameState: Equatable {
    case home
    case playing
    case paused
    case levelComplete
    case gameOver
}
