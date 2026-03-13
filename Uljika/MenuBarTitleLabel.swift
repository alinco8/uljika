import SwiftUI
import AppKit

struct MenuBarTitleLabel: View {
    let title: String
    let referenceTitle: String
    
    // 好きなフォントがある場合はここで指定できるよ
    
    private func styledText(from string: String) -> Text {
        let regex = /[0-9]+:[0-9]{2}/
        var result = Text("")
        
        var currentIndex = string.startIndex
        for match in string.matches(of: regex) {
            result = result + Text(String(string[currentIndex..<match.range.lowerBound]))
            // 数字部分だけ等幅にする
            result = result + Text(String(string[match.range])).monospacedDigit()
            currentIndex = match.range.upperBound
        }
        
        result = result + Text(String(string[currentIndex...]))
        return result
    }

    @MainActor
    private func renderImage() -> NSImage? {
        let layout = ZStack(alignment: .center) {
            styledText(from: referenceTitle)
                .hidden()

            styledText(from: title)
                .lineLimit(1)
        }
        .fixedSize()

        let renderer = ImageRenderer(content: layout)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2.0

        if let nsImage = renderer.nsImage {
            nsImage.isTemplate = true
            return nsImage
        }
        return nil
    }

    var body: some View {
        if let nsImage = renderImage() {
            Image(nsImage: nsImage)
        } else {
            Text(title)
        }
    }
}
