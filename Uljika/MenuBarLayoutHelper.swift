import AppKit

struct MenuBarLayoutHelper {
    private static let measureFont = NSFont.monospacedDigitSystemFont(
        ofSize: NSFont.systemFontSize,
        weight: .regular
    )
    
    private static let widestScheduleLabel: String = {
        let labels = TimeCalculator.schedules.map(\.0)
        return labels.max {
            measuredWidth(of: $0) < measuredWidth(of: $1)
        } ?? ""
    }()
    
    private static let dummyLeftTime = "000:00"
    // 念の為000:00　必要に応じて変更してください
    
    static func referenceTitle(for renderStyle: RenderStyle, fallbackText: String) -> String {
        let styleReference: String
        
        switch renderStyle {
        case .Normal:
            styleReference = "\(widestScheduleLabel)まで\(dummyLeftTime)"
        case .Compact:
            styleReference = dummyLeftTime
        case .Custom(let format):
            styleReference = format
                .replacingOccurrences(of: "{next.label}", with: widestScheduleLabel)
                .replacingOccurrences(of: "{next.leftTime}", with: dummyLeftTime)
        }
        
        return widestTitle(in: [styleReference, fallbackText], fallback: fallbackText)
    }

    private static func widestTitle(in titles: [String], fallback: String) -> String {
        titles.max { measuredWidth(of: $0) < measuredWidth(of: $1) } ?? fallback
    }

    private static func measuredWidth(of title: String) -> CGFloat {
        (title as NSString).size(withAttributes: [.font: measureFont]).width
    }
}
