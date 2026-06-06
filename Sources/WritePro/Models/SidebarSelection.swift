import Foundation

enum SidebarSelection: Equatable {
    case context(StyleContext)
    case tool(Tool)
}

extension SidebarSelection {
    var label: String {
        switch self {
        case .context(let c): return c.label
        case .tool(let t):    return t.label
        }
    }
    var icon: String {
        switch self {
        case .context(let c): return c.icon
        case .tool(let t):    return t.icon
        }
    }
}
