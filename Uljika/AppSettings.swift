import SwiftUI

private let compactModePrefix = "compact;"
enum RenderStyle: Identifiable, Hashable {
    case Normal
    case Compact
    case Custom(format: String)

    var id: String {
        switch self {
        case .Normal:
            "ノーマル"
        case .Compact:
            "コンパクト"
        case .Custom(_):
            "カスタム"
        }
    }
    
    func toString() -> String {
        switch self {
        case .Normal: "normal"
        case .Compact: "compact"
        case .Custom(format: let format): "\(compactModePrefix)\(format)"
        }
    }
    
    static func fromString(string: String) -> Self? {
        return switch string {
        case "normal": .Normal
        case "compact": .Compact
        default:
            if string.hasPrefix(compactModePrefix) {
                Self.Custom(format: String(string.dropFirst(compactModePrefix.count)))
            } else {
                nil
            }
        }
    }
}

@Observable
class AppSettings {
    var course: Int {
        didSet { UserDefaults.standard.set(course, forKey: "course") }
    }
    var fallbackText: String {
        didSet {
            UserDefaults.standard.set(fallbackText, forKey: "fallbackText")
        }
    }
    var renderStyle: RenderStyle {
        didSet {
            UserDefaults.standard.set(renderStyle.toString(), forKey: "renderStyle")
        }
    }

    init() {
        self.course =
            UserDefaults.standard.object(forKey: "course") as? Int ?? 5
        self.fallbackText =
            UserDefaults.standard.object(forKey: "fallbackText") as? String
            ?? "(:3_ヽ)_"
        self.renderStyle = RenderStyle.fromString(
            string: UserDefaults.standard.object(forKey: "renderStyle") as? String ?? ""
        ) ?? RenderStyle.Normal
        print(UserDefaults.standard.object(forKey: "renderStyle"))
        print(self.renderStyle.id)
    }

    func reset() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)  // Sparkle系も消える
        }

        self.course = 5
        self.fallbackText = "(:3_ヽ)_"
        self.renderStyle = RenderStyle.Normal
    }
}
