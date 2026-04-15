import Combine
import Foundation
import SwiftData
import SwiftUI
import ZIPFoundation

private let poller = ExtensionPoller(interval: .seconds(60))

@main
struct UljikaApp: App {

    @State private var calculator: TimeCalculator
    @State private var settings: AppSettings

    init() {
        let settings = AppSettings()

        self.settings = settings
        self.calculator = TimeCalculator(settings: settings)

        poller.onUpdate = { text in
            Task {

                let appSupport = FileManager.default.urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                ).first!
                let dir = appSupport.appendingPathComponent(
                    "\(Bundle.main.bundleIdentifier!)/N-Extension"
                )

                if FileManager.default.fileExists(atPath: dir.path) {
                    try FileManager.default.removeItem(at: dir)
                }
                try FileManager.default.createDirectory(
                    at: dir,
                    withIntermediateDirectories: true
                )

                let (data, _) = try await URLSession.shared.data(
                    from: URL(
                        string:
                            "https://alinco8.github.io/n-extension/N-Extension.zip"
                    )!
                )

                let tmpZip = dir.appendingPathComponent("tmp.zip")
                try data.write(to: tmpZip)
                try FileManager.default.unzipItem(at: tmpZip, to: dir)
                try FileManager.default.removeItem(at: tmpZip)
                
                let defaults = UserDefaults(suiteName: "dev.alinco8.uljika")!
                defaults.set(poller.latestVersion, forKey: "latestVersion")
            }
        }
        poller.start()
    }

    var body: some Scene {
        Settings {
            SettingsView(
                settings: settings
            ).onAppear(perform: NSApp.activate)
        }.defaultLaunchBehavior(.suppressed)
        MenuBarExtra {
            Button("更新を確認", action: UpdateManager.shared.checkForUpdates)
            SettingsLink { Text("設定") }
                .keyboardShortcut(",", modifiers: .command)
            Button("アプリを終了") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)
        } label: {
            Text(calculator.title)
        }
    }
}
