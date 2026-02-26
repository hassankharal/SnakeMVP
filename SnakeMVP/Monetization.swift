import Foundation

enum AdPlacementPolicy {
    static func shouldShowBanners(adsRemoved: Bool) -> Bool {
        !adsRemoved
    }
}
