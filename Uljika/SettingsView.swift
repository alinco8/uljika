import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @Bindable var calculator: TimeCalculator

    var body: some View {
        TabView {
            Tab("一般", systemImage: "gear") {
                Form {
                    Picker("通学コース", selection: $calculator.course) {
                        Text("週5").tag(5)
                        Text("週3").tag(3)
                        Text("週1").tag(1)
                    }
                    Picker("表示形式", selection: $calculator.renderStyle) {
                        Text("ノーマル").tag(RenderStyle.Normal)
                        Text("コンパクト").tag(RenderStyle.Compact)
                    }
                    TextField(text: $calculator.fallbackText) {
                        Text("予定がないときの文字")
                    }
                    LaunchAtLogin.Toggle("ログイン時にを起動")
                }
            }
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}
