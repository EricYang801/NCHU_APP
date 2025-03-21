import Foundation

enum AppError: Error {
    case captchaFailed
    case csrfTokenNotFound
    case invalidResponse
    case captchaProcessFailed
} 