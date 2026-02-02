import SwiftUI

struct GameBoardView: View {
    @ObservedObject var model: GameModel
    let theme: GameTheme

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let boardRect = CGRect(
                x: (proxy.size.width - size) / 2,
                y: (proxy.size.height - size) / 2,
                width: size,
                height: size
            )

            Canvas { context, _ in
                let palette = theme.palette
                let world = model.level.worldSize
                let scale = size / world

                let boardPath = RoundedRectangle(cornerRadius: 28).path(in: boardRect)
                context.fill(boardPath, with: .color(palette.board))
                context.stroke(boardPath, with: .color(palette.boardOutline), lineWidth: 1)

                // Obstacles
                for obstacle in model.obstacles {
                    let rect = CGRect(
                        x: boardRect.minX + obstacle.center.x * scale - obstacle.radius * scale,
                        y: boardRect.minY + obstacle.center.y * scale - obstacle.radius * scale,
                        width: obstacle.radius * 2 * scale,
                        height: obstacle.radius * 2 * scale
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(palette.obstacle))
                }

                // Food
                let foodRect = CGRect(
                    x: boardRect.minX + model.food.x * scale - model.foodRadius * scale,
                    y: boardRect.minY + model.food.y * scale - model.foodRadius * scale,
                    width: model.foodRadius * 2 * scale,
                    height: model.foodRadius * 2 * scale
                )
                context.drawLayer { layer in
                    layer.addFilter(.shadow(color: palette.food.opacity(0.75), radius: model.foodRadius * scale * 0.8, x: 0, y: 0))
                    layer.fill(Path(ellipseIn: foodRect), with: .color(palette.food))
                }

                // Snake body
                if model.snakePath.count > 1 {
                    var path = Path()
                    let start = model.snakePath[0]
                    path.move(to: CGPoint(x: boardRect.minX + start.x * scale, y: boardRect.minY + start.y * scale))
                    for point in model.snakePath.dropFirst() {
                        path.addLine(to: CGPoint(x: boardRect.minX + point.x * scale, y: boardRect.minY + point.y * scale))
                    }
                    context.stroke(
                        path,
                        with: .color(palette.snakeBody),
                        style: StrokeStyle(lineWidth: model.bodyRadius * 2 * scale, lineCap: .round, lineJoin: .round)
                    )
                }

                // Snake head
                if let head = model.snakePath.first {
                    let headRect = CGRect(
                        x: boardRect.minX + head.x * scale - model.headRadius * scale,
                        y: boardRect.minY + head.y * scale - model.headRadius * scale,
                        width: model.headRadius * 2 * scale,
                        height: model.headRadius * 2 * scale
                    )
                    context.fill(Path(ellipseIn: headRect), with: .color(palette.snakeHead))

                    let highlight = CGRect(
                        x: headRect.midX - model.headRadius * 0.3 * scale,
                        y: headRect.midY - model.headRadius * 0.3 * scale,
                        width: model.headRadius * 0.6 * scale,
                        height: model.headRadius * 0.6 * scale
                    )
                    context.fill(Path(ellipseIn: highlight), with: .color(Color.white.opacity(0.65)))
                }
            }
            .frame(width: size, height: size)
        }
        .padding(.horizontal, 8)
        .aspectRatio(1, contentMode: .fit)
    }
}
