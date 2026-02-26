import SwiftUI

struct GameBoardView: View {
    @ObservedObject var model: GameModel
    let theme: GameTheme

    var body: some View {
        GeometryReader { proxy in
            let boardSize = min(proxy.size.width, proxy.size.height)
            let boardRect = CGRect(
                x: (proxy.size.width - boardSize) / 2,
                y: (proxy.size.height - boardSize) / 2,
                width: boardSize,
                height: boardSize
            )

            Canvas { context, _ in
                let palette = theme.palette
                let scale = boardSize / model.level.worldSize

                drawBoardBase(in: boardRect, palette: palette, context: &context)
                drawObstacles(in: boardRect, scale: scale, palette: palette, context: &context)
                drawFood(in: boardRect, scale: scale, palette: palette, context: &context)
                drawSnake(in: boardRect, scale: scale, palette: palette, context: &context)
            }
            .frame(width: boardSize, height: boardSize)
        }
        .padding(.horizontal, 8)
        .aspectRatio(1, contentMode: .fit)
    }

    private func drawBoardBase(in rect: CGRect, palette: ThemePalette, context: inout GraphicsContext) {
        let boardPath = RoundedRectangle(cornerRadius: 28).path(in: rect)
        context.fill(boardPath, with: .color(palette.board))
        context.stroke(boardPath, with: .color(palette.boardOutline), lineWidth: 1)
    }

    private func drawObstacles(
        in boardRect: CGRect,
        scale: CGFloat,
        palette: ThemePalette,
        context: inout GraphicsContext
    ) {
        for obstacle in model.obstacles {
            let radius = obstacle.radius * scale
            let center = boardPoint(for: obstacle.center, boardRect: boardRect, scale: scale)
            let rect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            context.fill(Path(ellipseIn: rect), with: .color(palette.obstacle))
        }
    }

    private func drawFood(
        in boardRect: CGRect,
        scale: CGFloat,
        palette: ThemePalette,
        context: inout GraphicsContext
    ) {
        let radius = model.foodRadius * scale
        let center = boardPoint(for: model.food, boardRect: boardRect, scale: scale)
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.drawLayer { layer in
            layer.addFilter(.shadow(color: palette.food.opacity(0.75), radius: radius * 0.8, x: 0, y: 0))
            layer.fill(Path(ellipseIn: rect), with: .color(palette.food))
        }
    }

    private func drawSnake(
        in boardRect: CGRect,
        scale: CGFloat,
        palette: ThemePalette,
        context: inout GraphicsContext
    ) {
        guard let head = model.snakePath.first else { return }

        if model.snakePath.count > 1 {
            var bodyPath = Path()
            bodyPath.move(to: boardPoint(for: head, boardRect: boardRect, scale: scale))

            for point in model.snakePath.dropFirst() {
                bodyPath.addLine(to: boardPoint(for: point, boardRect: boardRect, scale: scale))
            }

            context.stroke(
                bodyPath,
                with: .color(palette.snakeBody),
                style: StrokeStyle(
                    lineWidth: model.bodyRadius * 2 * scale,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }

        drawSnakeHead(at: head, in: boardRect, scale: scale, palette: palette, context: &context)
    }

    private func drawSnakeHead(
        at worldHead: CGPoint,
        in boardRect: CGRect,
        scale: CGFloat,
        palette: ThemePalette,
        context: inout GraphicsContext
    ) {
        let radius = model.headRadius * scale
        let headCenter = boardPoint(for: worldHead, boardRect: boardRect, scale: scale)

        let headRect = CGRect(
            x: headCenter.x - radius,
            y: headCenter.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.fill(Path(ellipseIn: headRect), with: .color(palette.snakeHead))

        let highlightRect = CGRect(
            x: headRect.midX - radius * 0.3,
            y: headRect.midY - radius * 0.3,
            width: radius * 0.6,
            height: radius * 0.6
        )

        context.fill(Path(ellipseIn: highlightRect), with: .color(Color.white.opacity(0.65)))
    }

    private func boardPoint(for worldPoint: CGPoint, boardRect: CGRect, scale: CGFloat) -> CGPoint {
        CGPoint(
            x: boardRect.minX + worldPoint.x * scale,
            y: boardRect.minY + worldPoint.y * scale
        )
    }
}
