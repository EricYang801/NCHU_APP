import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = "你好"
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Layout.spacing) {
                    // 大標題
                    Text("設定")
                        .font(.system(size: Theme.FontSize.extraLarge, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 40)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // 個人設定
                            SettingSection(title: "個人設定") {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("名稱")
                                            .font(.system(size: Theme.FontSize.regular))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                        Spacer()
                                        TextField("", text: $userName)
                                            .multilineTextAlignment(.trailing)
                                            .font(.system(size: Theme.FontSize.regular))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 52)
                                }
                            }
                            
                            // 系統設定
                            SettingSection(title: "系統設定") {
                                NavigationLink(destination: ILearningCredentialsView()) {
                                    HStack {
                                        Image(systemName: "person.circle")
                                            .font(.system(size: Theme.Layout.iconSize))
                                            .foregroundColor(Theme.Colors.iconColor)
                                        Text("iLearning 帳號設定")
                                            .font(.system(size: Theme.FontSize.regular))
                                            .foregroundColor(Theme.Colors.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: Theme.FontSize.small))
                                            .foregroundColor(Theme.Colors.iconColor)
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 52)
                                }
                            }
                            
                            // 其他資訊
                            SettingSection(title: "其他資訊") {
                                VStack(spacing: 0) {
                                    SettingRow(
                                        icon: "info.circle",
                                        title: "版本",
                                        value: "1.0 (1)"
                                    )
                                    
                                    Divider()
                                        .padding(.horizontal, 16)
                                    
                                    SettingRow(
                                        icon: "person.fill",
                                        title: "開發者",
                                        value: "Eric Yang"
                                    )
                                    
                                    Divider()
                                        .padding(.horizontal, 16)
                                    
                                    Button(action: {
                                        // 開啟意見回饋
                                        if let url = URL(string: "mailto:eric@example.com") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "envelope")
                                                .font(.system(size: Theme.Layout.iconSize))
                                                .foregroundColor(Theme.Colors.iconColor)
                                            Text("意見回饋")
                                                .font(.system(size: Theme.FontSize.regular))
                                                .foregroundColor(Theme.Colors.textPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: Theme.FontSize.small))
                                                .foregroundColor(Theme.Colors.iconColor)
                                        }
                                        .padding(.horizontal, 16)
                                        .frame(height: 52)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Setting Row
private struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: Theme.Layout.iconSize))
                .foregroundColor(Theme.Colors.iconColor)
            Text(title)
                .font(.system(size: Theme.FontSize.regular))
                .foregroundColor(Theme.Colors.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: Theme.FontSize.regular))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
}

#Preview {
    SettingsView()
}
