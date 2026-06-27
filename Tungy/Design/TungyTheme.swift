import SwiftUI

enum TungyTheme {
    static let primaryHex: UInt32 = 0x0060AA
    static let primaryContainerHex: UInt32 = 0x58A6FF
    static let tertiaryContainerHex: UInt32 = 0x11BB62
    static let backgroundHex: UInt32 = 0xF7F9FB
    static let surfaceContainerHex: UInt32 = 0xECEEF0
    static let surfaceContainerLowHex: UInt32 = 0xF2F4F6
    static let secondaryHex: UInt32 = 0x93465B
    static let secondaryContainerHex: UInt32 = 0xFD9DB4
    static let errorHex: UInt32 = 0xBA1A1A
    static let onSurfaceHex: UInt32 = 0x191C1E
    static let outlineHex: UInt32 = 0x717783

    static let primary = color(hex: primaryHex)
    static let primaryContainer = color(hex: primaryContainerHex)
    static let tertiaryContainer = color(hex: tertiaryContainerHex)
    static let background = color(hex: backgroundHex)
    static let surfaceContainer = color(hex: surfaceContainerHex)
    static let surfaceContainerLow = color(hex: surfaceContainerLowHex)
    static let secondary = color(hex: secondaryHex)
    static let secondaryContainer = color(hex: secondaryContainerHex)
    static let error = color(hex: errorHex)
    static let onSurface = color(hex: onSurfaceHex)
    static let outline = color(hex: outlineHex)

    static func color(hex: UInt32) -> Color {
        let components = rgbComponents(hex)
        return Color(red: components.red, green: components.green, blue: components.blue)
    }

    static func rgbComponents(_ hex: UInt32) -> (red: Double, green: Double, blue: Double) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return (red, green, blue)
    }
}
