import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        ScrollView {
            Form {
                Picker("通学コース", selection: $settings.course) {
                    Text("週5").tag(5)
                    Text("週3").tag(3)
                    Text("週1").tag(1)
                }
                Picker("表示形式", selection: $settings.renderStyle) {
                    Text("標準").tag(RenderStyle.Normal)
                    Text("コンパクト").tag(RenderStyle.Compact)

                    if case .Custom(let format) = settings.renderStyle {
                        Text("カスタム").tag(RenderStyle.Custom(format: format))
                    } else {
                        Text("カスタム").tag(RenderStyle.Custom(format: "{next.label}: {next.leftTime}"))
                    }

                }
                switch settings.renderStyle {
                case .Custom(let format):
                    TextField(
                        "カスタムフォーマット",
                        text: Binding<String>(
                            get: { format },
                            set: { newValue in
                                settings.renderStyle = .Custom(format: newValue)
                            }
                        )
                    )
                default: EmptyView()
                }
                TextField("予定がないときの文字", text: $settings.fallbackText)
                    .help(
                        "下記のように置き換えられます:\n{next.label} -> 次の予定の名前\n{next.leftTime} -> 次の予定までの残り時間"
                    )
                LaunchAtLogin.Toggle("ログイン時に起動")
            }
            .formStyle(.grouped)
            .scrollDisabled(true)

            HStack {
                Spacer()
                Button("すべての設定をリセット", role: .destructive) {
                    settings.reset()
                }
            }.padding([.horizontal], 20)
        }
        .frame(width: 450, height: 260)
    }
}

#Preview {
    SettingsView(settings: AppSettings())
}
