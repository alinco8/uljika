// JSONPoller.swift

import Foundation
import ZIPFoundation

struct ExtensionManifest: Decodable {
    let version: String
}

@Observable
class ExtensionPoller {
    private let interval: Duration
    private var pollingTask: Task<Void, Never>?
    private let url = URL(
        string: "https://alinco8.github.io/n-extension/latest.txt"
    )!

    var latestVersion: String = ""
    var onUpdate: ((String) -> Void)?

    init(interval: Duration = .seconds(60 * 5)) {
        self.interval = interval

        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        let dir = appSupport.appendingPathComponent(
            "\(Bundle.main.bundleIdentifier!)/N-Extension"
        )

        let url = dir.appendingPathComponent("manifest.json")

        guard let data = try? Data(contentsOf: url),
            let manifest = try? JSONDecoder().decode(
                ExtensionManifest.self,
                from: data
            )
        else {
            return
        }

        self.latestVersion = manifest.version
    }

    func start() {
        pollingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.poll()
                try? await Task.sleep(for: self.interval)
            }
        }
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func poll() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let text = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            else { return }

            let previous = latestVersion
            if previous != text {
                latestVersion = text
                await MainActor.run {
                    onUpdate?(text)
                }
            }
        } catch {}
    }
}
