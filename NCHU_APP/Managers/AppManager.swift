import Foundation
import SwiftUI

class AppManager: ObservableObject {
    static let shared = AppManager()
    private let lmsLogin = NCHULMSLogin()
    private let assignmentManager = AssignmentManager.shared
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var lastRefreshTime: Date?
    private let minimumRefreshInterval: TimeInterval = 300 // 5 分鐘
    
    private init() {}
    
    @MainActor
    func refreshAssignments() async {
        // 檢查是否需要更新
        if let lastTime = lastRefreshTime,
           Date().timeIntervalSince(lastTime) < minimumRefreshInterval {
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 嘗試使用已儲存的憑證登入
            let loginResult = try await lmsLogin.loginWithSavedCredentials()
            
            if loginResult.success {
                // 獲取最新事件
                let dashboardResult = try await lmsLogin.getDashboardLastEvent()
                if dashboardResult.success {
                    // 更新作業列表
                    assignmentManager.updateAssignments(from: dashboardResult.events)
                    lastRefreshTime = Date()
                } else {
                    errorMessage = "無法獲取最新事件"
                }
            } else {
                errorMessage = loginResult.message
            }
        } catch KeychainManager.KeychainError.itemNotFound {
            errorMessage = "請先登入並儲存帳號密碼"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func scheduleBackgroundRefresh() {
        // 這裡可以添加背景更新的邏輯
        // 例如使用 BackgroundTasks 框架
    }
} 
