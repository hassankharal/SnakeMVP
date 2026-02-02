import SwiftUI

struct JoystickView: View {
    let size: CGFloat
    let theme: GameTheme
    let onChange: (CGVector) -> Void

    @State private var knobOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let radius = min(proxy.size.width, proxy.size.height) / 2
            let knobRadius = radius * 0.38
            let maxDistance = radius - knobRadius

            ZStack {
                Circle()
                    .fill(theme.palette.joystickBase)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                Circle()
                    .fill(theme.palette.joystickKnob)
                    .frame(width: knobRadius * 2, height: knobRadius * 2)
                    .offset(knobOffset)
                    .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let center = CGPoint(x: radius, y: radius)
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        let length = hypot(dx, dy)
                        if length == 0 {
                            knobOffset = .zero
                            onChange(.zero)
                            return
                        }

                        let clamped = min(length, maxDistance)
                        let nx = dx / length
                        let ny = dy / length
                        knobOffset = CGSize(width: nx * clamped, height: ny * clamped)
                        let intensity = clamped / maxDistance
                        onChange(CGVector(dx: nx * intensity, dy: ny * intensity))
                    }
                    .onEnded { _ in
                        knobOffset = .zero
                        onChange(.zero)
                    }
            )
        }
        .frame(width: size, height: size)
    }
}
