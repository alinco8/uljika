import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                            Text("カスタム").tag(
                                RenderStyle.Custom(
                                    format: "{next.label}: {next.leftTime}"
                                )
                            )
                        }

                    }
                    switch settings.renderStyle {
                    case .Custom(let format):
                        TextField(
                            "カスタムフォーマット",
                            text: Binding<String>(
                                get: { format },
                                set: { newValue in
                                    settings.renderStyle = .Custom(
                                        format: newValue
                                    )
                                }
                            )
                        ).help(
                            "以下の文字列が置き換えられます:\n{next.label} -> 次の予定の名前\n{next.leftTime} -> 次の予定までの残り時間"
                        )
                    default: EmptyView()
                    }
                    TextField("予定がないときの文字", text: $settings.fallbackText)
                    NavigationLink("スケジュール") {
                        SchedulesView()
                    }
                    LaunchAtLogin.Toggle("ログイン時に起動")
                } footer: {
                    HStack {
                        Spacer()
                        Button(
                            "すべての設定をリセット",
                            role: .destructive,
                            action: settings.reset
                        )
                    }
                }
            }
            .navigationTitle("Uljika 設定")
            .formStyle(.grouped)
        }
        .frame(width: 450, height: 250)
    }
}

#Preview {
    SettingsView(settings: AppSettings())
}
