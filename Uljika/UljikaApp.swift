import Combine
import SwiftData
import SwiftUI

@Observable
class TimeCalculator {
    static let schedules: [(String, Int)] = [
        ("朝礼", 9 * 3600 + 31 * 60),
        ("1限目", 9 * 3600 + 45 * 60),
        ("休憩1", 10 * 3600 + 35 * 60),
        ("2限目", 10 * 3600 + 45 * 60),
        ("休憩2", 11 * 3600 + 35 * 60),
        ("3限目", 11 * 3600 + 45 * 60),
        ("昼休憩", 12 * 3600 + 35 * 60),
        ("4限目", 13 * 3600 + 15 * 60),
        ("休憩4", 14 * 3600 + 5 * 60),
        ("5限目", 14 * 3600 + 15 * 60),
        ("休憩5", 15 * 3600 + 5 * 60),
        ("6限目", 15 * 3600 + 15 * 60),
        ("終礼", 16 * 3600 + 5 * 60),
        ("放課後", 16 * 3600 + 15 * 60),
    ]
    static let calendar = Calendar.current

    private var timer: AnyCancellable?
    private var nextSchedule: (String, Int)?

    var settings: AppSettings
    var title = "??まで--:--"

    init(settings: AppSettings) {
        self.settings = settings
        
        let date = Date()
        let components = Self.calendar.dateComponents(
            [.hour, .minute, .second],
            from: date
        )

        refreshNextSchedule(
            nowSecs: (components.hour ?? 0) * 3600 + (components.minute ?? 0)
                * 60
        )
        do {
            try updateRemainingTime()
        } catch {
            print("タイマー更新中にエラーが発生: \(error)")
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            MainActor.assumeIsolated {
                do {
                    try self?.updateRemainingTime()
                } catch {
                    print("タイマー更新中にエラーが発生: \(error)")
                }
            }
        }
    }

    private func updateRemainingTime() throws {
        let now = Date()
        let components = Self.calendar.dateComponents(
            [.hour, .minute, .second, .weekday],
            from: now
        )
        let schoolDay =
            {
                let weekday = components.weekday ?? 1
                return switch settings.course {
                case 1: weekday == 5
                case 3: weekday % 2 == 0
                default: 2 <= weekday && weekday <= 6
                }
            }()
        if !schoolDay {
            title = settings.fallbackText
            return
        }

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let nowSecs = hour * 3600 + minute * 60 + second

        if second == 0 {
            refreshNextSchedule(nowSecs: nowSecs)
        }

        if let (label, nextSecs) = nextSchedule {
            let leftSecs = nextSecs - nowSecs
            let leftMinutes = leftSecs / 60
            let leftSeconds = leftSecs % 60
            let newTitle =
                switch settings.renderStyle {
                case .Normal:
                    "\(label)まで\(String(format: "%02d", leftMinutes)):\(String(format: "%02d", leftSeconds))"
                case .Compact:
                    "\(String(format: "%02d", leftMinutes)):\(String(format: "%02d", leftSeconds))"
                }
            if newTitle != title {
                title = newTitle
            }
        } else {
            title = settings.fallbackText
        }
    }
    private func refreshNextSchedule(nowSecs: Int) {
        nextSchedule = Self.schedules.first {
            return nowSecs < $0.1
        }
    }
}

@main
struct UljikaApp: App {

    @State private var calculator: TimeCalculator
    @State private var updateManager: UpdateManager
    @State private var settings: AppSettings
    
    init() {
        let settings = AppSettings()
        
        self.settings = settings
        self.calculator = TimeCalculator(settings: settings)
        self.updateManager = UpdateManager()
    }

    var body: some Scene {
        Settings {
            SettingsView(
                settings: settings
            ).onAppear(perform: NSApp.activate)
        }.defaultLaunchBehavior(.suppressed)
        MenuBarExtra {
            Button("更新を確認", action: updateManager.checkForUpdates)
            SettingsLink { Text("設定") }
                .keyboardShortcut(",", modifiers: .command)
            Button("アプリを終了") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)
        } label: {
            Text(calculator.title)
        }
    }
}
