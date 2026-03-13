import SwiftUI
import AppKit

struct MenuBarTitleLabel: View {
    let title: String
    let referenceTitle: String

    private static let renderer = MenuBarImageRenderer()

    var body: some View {
        if let nsImage = Self.renderer.render(title: title, referenceTitle: referenceTitle) {
            Image(nsImage: nsImage)
        } else {
            Text(title)
        }
    }
}

final class MenuBarImageRenderer {
    private var cachedTitle: String = ""
    private var cachedImage: NSImage? = nil
    private let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    private let monoFont = NSFont.monospacedDigitSystemFont(
        ofSize: NSFont.systemFontSize,
        weight: .regular
    )

    func render(title: String, referenceTitle: String) -> NSImage? {
        if title == cachedTitle, let image = cachedImage {
            return image
        }

        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        let refSize = attributedString(from: referenceTitle).size()
        let titleAttr = attributedString(from: title)
        let titleSize = titleAttr.size()
        let width = max(refSize.width, titleSize.width)
        let height = max(refSize.height, titleSize.height)
        let size = NSSize(width: ceil(width), height: ceil(height))

        let image = NSImage(size: size)
        image.isTemplate = true

        image.lockFocus()
        let drawRect = NSRect(
            x: (size.width - titleSize.width) / 2,
            y: (size.height - titleSize.height) / 2,
            width: titleSize.width,
            height: titleSize.height
        )
        titleAttr.draw(in: drawRect)
        image.unlockFocus()

        if let rep = image.representations.first as? NSBitmapImageRep {
            rep.size = NSSize(width: size.width / scale, height: size.height / scale)
        }

        cachedTitle = title
        cachedImage = image
        return image
    }

    private let timeRegex = /[0-9]+:[0-9]{2}/

    private func attributedString(from string: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        var currentIndex = string.startIndex

        for match in string.matches(of: timeRegex) {
            let prefix = String(string[currentIndex..<match.range.lowerBound])
            if !prefix.isEmpty {
                result.append(NSAttributedString(
                    string: prefix,
                    attributes: [.font: font]
                ))
            }
            result.append(NSAttributedString(
                string: String(string[match.range]),
                attributes: [.font: monoFont]
            ))
            currentIndex = match.range.upperBound
        }

        let suffix = String(string[currentIndex...])
        if !suffix.isEmpty {
            result.append(NSAttributedString(
                string: suffix,
                attributes: [.font: font]
            ))
        }

        return result
    }
}
