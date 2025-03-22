import SwiftUI

struct ILearningCredentialsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ILearningCredentialsViewModel()
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Layout.spacing) {
                // 導航欄
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("返回")
                                .font(.system(size: Theme.FontSize.regular))
                        }
                        .foregroundColor(Theme.Colors.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 大標題
                Text("iLearning 帳號")
                    .font(.system(size: Theme.FontSize.extraLarge, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 帳號密碼設定
                        SettingSection(title: "帳號設定") {
                            VStack(spacing: 0) {
                                // 帳號
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("帳號")
                                        .font(.system(size: Theme.FontSize.regular))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "person")
                                            .font(.system(size: Theme.Layout.iconSize))
                                            .foregroundColor(Theme.Colors.iconColor)
                                        
                                        TextField("請輸入您的學號", text: $viewModel.username)
                                            .font(.system(size: Theme.FontSize.regular))
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled(true)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 52)
                                    .background(Theme.Colors.cardBackground)
                                    .cornerRadius(Theme.Layout.cornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                                            .stroke(Theme.Colors.border, lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // 密碼
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("密碼")
                                        .font(.system(size: Theme.FontSize.regular))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "lock")
                                            .font(.system(size: Theme.Layout.iconSize))
                                            .foregroundColor(Theme.Colors.iconColor)
                                        
                                        SecureField("請輸入您的密碼", text: $viewModel.password)
                                            .font(.system(size: Theme.FontSize.regular))
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled(true)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 52)
                                    .background(Theme.Colors.cardBackground)
                                    .cornerRadius(Theme.Layout.cornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                                            .stroke(Theme.Colors.border, lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                        
                        // 提示訊息
                        Text("請輸入您的 iLearning 帳號密碼，系統會將其安全地儲存在您的裝置中。")
                            .font(.system(size: Theme.FontSize.small))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // 儲存按鈕
                VStack {
                    Button(action: { viewModel.saveCredentials() }) {
                        HStack {
                            Text("儲存")
                                .font(.system(size: Theme.FontSize.regular, weight: .medium))
                                .foregroundColor(.white)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.leading, 8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Theme.Colors.primary)
                        .cornerRadius(Theme.Layout.cornerRadius)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)
                    .padding(.bottom, 34)
                }
                .background(Theme.Colors.cardBackground)
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.isSuccess ? "成功" : "錯誤"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("確定")) {
                    if viewModel.isSuccess {
                        dismiss()
                    }
                }
            )
        }
        .onAppear {
            viewModel.loadCredentials()
        }
    }
}

// MARK: - ViewModel
class ILearningCredentialsViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false
    @Published var isLoading = false
    
    func saveCredentials() {
        guard !username.isEmpty else {
            showAlert(message: "請輸入帳號", isSuccess: false)
            return
        }
        
        guard !password.isEmpty else {
            showAlert(message: "請輸入密碼", isSuccess: false)
            return
        }
        
        isLoading = true
        
        DispatchQueue.global().async { [weak self] in
            do {
                try KeychainManager.standard.saveCredentials(
                    username: self?.username ?? "",
                    password: self?.password ?? ""
                )
                
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.showAlert(message: "帳號密碼儲存成功", isSuccess: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.showAlert(message: "儲存失敗：\(error.localizedDescription)", isSuccess: false)
                }
            }
        }
    }
    
    func loadCredentials() {
        do {
            let credentials = try KeychainManager.standard.getCredentials()
            username = credentials.username
            password = credentials.password
        } catch {
            print("無法載入帳號密碼：\(error.localizedDescription)")
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool) {
        alertMessage = message
        self.isSuccess = isSuccess
        showAlert = true
    }
}

#Preview {
    NavigationView {
        ILearningCredentialsView()
    }
} 