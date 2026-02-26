import CoreGraphics
import Foundation

protocol RandomSource: AnyObject {
    func nextCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat
}

final class SystemRandomSource: RandomSource {
    func nextCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        CGFloat.random(in: range)
    }
}

final class SeededRandomSource: RandomSource {
    private var state: UInt64

    init(seed: UInt64) {
        let defaultSeed: UInt64 = 0x9E37_79B9_7F4A_7C15
        self.state = seed == 0 ? defaultSeed : seed
    }

    func nextCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        let raw = nextUnitInterval()
        return range.lowerBound + (range.upperBound - range.lowerBound) * raw
    }

    private func nextUnitInterval() -> CGFloat {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        z = z ^ (z >> 31)

        let fraction = Double(z >> 11) / Double(1 << 53)
        return CGFloat(fraction)
    }
}

final class SequenceRandomSource: RandomSource {
    private let values: [CGFloat]
    private var index = 0

    init(values: [CGFloat]) {
        self.values = values.isEmpty ? [0.5] : values
    }

    func nextCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        let value = values[index % values.count]
        index += 1
        let clamped = min(max(value, 0), 1)
        return range.lowerBound + (range.upperBound - range.lowerBound) * clamped
    }
}
