import SwiftUI

enum RenderStyle: String, Identifiable, CaseIterable {
    case Normal = "ノーマル"
    case Compact = "コンパクト"

    var id: String { self.rawValue }
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
            UserDefaults.standard.set(renderStyle, forKey: "renderStyle")
        }
    }

    init() {
        self.course =
            UserDefaults.standard.object(forKey: "course") as? Int ?? 5
        self.fallbackText =
            UserDefaults.standard.object(forKey: "fallbackText") as? String
            ?? "(:3_ヽ)_"
        self.renderStyle =
            RenderStyle(
                rawValue: UserDefaults.standard.object(forKey: "renderStyle")
                    as? String ?? ""
            ) ?? RenderStyle.Normal
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
