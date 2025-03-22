import Foundation

enum AppError: Error {
    case captchaFailed
    case csrfTokenNotFound
    case invalidResponse
    case captchaProcessFailed
    case unknownError
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .captchaFailed:
            return "驗證碼獲取失敗"
        case .csrfTokenNotFound:
            return "CSRF Token 未找到"
        case .invalidResponse:
            return "伺服器回應無效"
        case .captchaProcessFailed:
            return "驗證碼處理失敗"
        case .unknownError:
            return "未知錯誤"
        }
    }
} 