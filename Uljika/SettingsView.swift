import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        VStack {
            Form {
                Picker("通学コース", selection: $settings.course) {
                    Text("週5").tag(5)
                    Text("週3").tag(3)
                    Text("週1").tag(1)
                }
                Picker("表示形式", selection: $settings.renderStyle) {
                    ForEach(RenderStyle.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                TextField("予定がないときの文字", text: $settings.fallbackText)
                LaunchAtLogin.Toggle("ログイン時に起動")
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            
            HStack {
                Spacer()
                Button("すべての設定をリセット", role: .destructive) {
                    settings.reset()
                }
            }.padding([.horizontal, .bottom], 20)
        }
        .frame(width: 450, height: 235)
    }
}

#Preview {
    SettingsView(settings: AppSettings())
}
