import XCTest
@testable import SnakeMVP

final class MonetizationTests: XCTestCase {
    func testAdBannerVisibilityWhenAdsNotRemoved() {
        XCTAssertTrue(AdPlacementPolicy.shouldShowBanners(adsRemoved: false))
    }

    func testAdBannerHiddenWhenAdsRemoved() {
        XCTAssertFalse(AdPlacementPolicy.shouldShowBanners(adsRemoved: true))
    }
}
