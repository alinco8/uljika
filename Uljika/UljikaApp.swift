import SwiftUI
import AppKit

@main
struct UljikaApp: App {

    @State private var calculator: TimeCalculator
    @State private var settings: AppSettings

    init() {
        let settings = AppSettings()
        self.settings = settings
        self.calculator = TimeCalculator(settings: settings)
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
            MenuBarTitleLabel(
                title: calculator.title,
                referenceTitle: MenuBarLayoutHelper.referenceTitle(
                    for: settings.renderStyle,
                    fallbackText: settings.fallbackText
                )
            )
        }
    }
}
