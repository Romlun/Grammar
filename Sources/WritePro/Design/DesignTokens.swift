import SwiftUI
import AppKit

enum DesignTokens {
    // MARK: - Accent
    static let accent         = Color(red: 124/255, green: 58/255, blue: 237/255)
    static let accentSubtle   = accent.opacity(0.12)
    static let accentDisabled = accent.opacity(0.40)

    // MARK: - Sidebar (always dark, fixed values)
    static let sidebarBackground     = Color(red: 28/255, green: 28/255, blue: 30/255)
    static let sidebarSectionLabel   = Color(red: 142/255, green: 142/255, blue: 147/255)
    static let sidebarItemUnselected = Color(red: 174/255, green: 174/255, blue: 178/255)

    // MARK: - Spacing (4pt grid)
    static let sp1: CGFloat = 4
    static let sp2: CGFloat = 8
    static let sp3: CGFloat = 12
    static let sp4: CGFloat = 16
    static let sp6: CGFloat = 24

    // MARK: - Corner Radius
    static let radiusCard: CGFloat = 6
}
