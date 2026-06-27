import XCTest
@testable import Tungy

final class TungyStoreTests: XCTestCase {
    func testThemeHexConversion() {
        let primary = TungyTheme.rgbComponents(TungyTheme.primaryHex)
        XCTAssertEqual(primary.red, 0.0, accuracy: 0.0001)
        XCTAssertEqual(primary.green, 96.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(primary.blue, 170.0 / 255.0, accuracy: 0.0001)

        let secondaryContainer = TungyTheme.rgbComponents(TungyTheme.secondaryContainerHex)
        XCTAssertEqual(secondaryContainer.red, 253.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(secondaryContainer.green, 157.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(secondaryContainer.blue, 180.0 / 255.0, accuracy: 0.0001)
    }

    func testStoreFallsBackWhenSuiteCannotOpen() {
        let store = TungyStore(suiteName: "")
        XCTAssertTrue(store.isUsingFallbackDefaults)
        XCTAssertTrue(store.defaults === UserDefaults.standard)
    }
}
