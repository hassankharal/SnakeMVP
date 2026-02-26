import Foundation
import QuartzCore
import SwiftUI

final class GameModel: ObservableObject {
    @Published private(set) var level: Level
    @Published private(set) var state: GameState
    @Published private(set) var snakePath: [CGPoint]
    @Published private(set) var food: CGPoint
    @Published private(set) var obstacles: [Obstacle]
    @Published private(set) var score: Int
    @Published private(set) var foodEaten: Int

    let headRadius: CGFloat
    let bodyRadius: CGFloat
    let foodRadius: CGFloat

    private let engine: GameEngine
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    init(engine: GameEngine = GameEngine()) {
        self.engine = engine

        self.level = engine.level
        self.state = engine.state
        self.snakePath = engine.snakePath
        self.food = engine.food
        self.obstacles = engine.obstacles
        self.score = engine.score
        self.foodEaten = engine.foodEaten

        self.headRadius = engine.headRadius
        self.bodyRadius = engine.bodyRadius
        self.foodRadius = engine.foodRadius
    }

    deinit {
        stopLoop()
    }

    func startNewGame() {
        stopLoop()
        engine.startNewGame()
        syncFromEngine()
        startLoopIfPlaying()
    }

    func pauseGame() {
        engine.pauseGame()
        syncFromEngine()
        if state == .paused {
            stopLoop()
        }
    }

    func resumeGame() {
        engine.resumeGame()
        syncFromEngine()
        startLoopIfPlaying()
    }

    func nextLevel() {
        stopLoop()
        engine.nextLevel()
        syncFromEngine()
        startLoopIfPlaying()
    }

    func endToHome() {
        stopLoop()
        engine.endToHome()
        syncFromEngine()
    }

    func updateInput(_ vector: CGVector) {
        engine.updateInput(vector)
    }

    private func startLoopIfPlaying() {
        guard engine.state == .playing else { return }

        stopLoop()
        lastTimestamp = 0

        let link = CADisplayLink(target: self, selector: #selector(handleFrame))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopLoop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
    }

    @objc private func handleFrame(link: CADisplayLink) {
        guard engine.state == .playing else { return }

        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        let delta = CGFloat(link.timestamp - lastTimestamp)
        lastTimestamp = link.timestamp

        engine.advance(by: min(delta, 0.05))
        syncFromEngine()

        if state != .playing {
            stopLoop()
        }
    }

    private func syncFromEngine() {
        level = engine.level
        state = engine.state
        snakePath = engine.snakePath
        food = engine.food
        obstacles = engine.obstacles
        score = engine.score
        foodEaten = engine.foodEaten
    }
}
