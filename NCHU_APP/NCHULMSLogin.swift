import Foundation
import SwiftSoup

class NCHULMSLogin {
    private let session: URLSession
    private let baseURL = "https://lms2020.nchu.edu.tw"
    private let loginURL: String
    private let captchaURL: String
    private let headers: [String: String]
    private let keychainManager = KeychainManager.standard
    private let maxRetries = 3
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
        self.loginURL = "\(baseURL)/index/login"
        self.captchaURL = "\(baseURL)/sys/libs/class/capcha/secimg.php?charLens=6&codeType=num"
        self.headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        ]
    }
    
    // MARK: - Keychain Operations
    func saveCredentials(account: String, password: String) throws {
        try keychainManager.saveCredentials(username: account, password: password)
    }
    
    func getCredentials() throws -> (username: String, password: String) {
        return try keychainManager.getCredentials()
    }
    
    func deleteCredentials() throws {
        try keychainManager.deleteCredentials()
    }
    
    // MARK: - Login Operations
    func loginWithSavedCredentials() async throws -> LoginResult {
        let credentials = try getCredentials()
        return try await login(account: credentials.username, password: credentials.password)
    }
    
    func getCaptcha() async throws -> Data {
        return try await withRetry {
            var request = URLRequest(url: URL(string: captchaURL)!)
            headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
            
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw AppError.captchaFailed
            }
            return data
        }
    }
    
    func login(account: String, password: String) async throws -> LoginResult {
        return try await withRetry {
            // Get login page and CSRF token
            let (_, csrfToken) = try await getLoginPageAndToken()
            
            // Get and process captcha
            let captcha = try await processCaptchaForLogin()
            
            // Submit login form
            return try await submitLoginForm(account: account, password: password, csrfToken: csrfToken, captcha: captcha)
        }
    }
    
    // MARK: - Dashboard Operations
    func getDashboardLastEvent() async throws -> DashboardResult {
        return try await withRetry {
            var request = URLRequest(url: URL(string: "\(baseURL)/dashboard/latestEvent")!)
            headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
            
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let html = String(data: data, encoding: .utf8) else {
                throw AppError.invalidResponse
            }
            
            return try parseDashboardEvents(from: html)
        }
    }
    
    // MARK: - Private Helper Methods
    private func withRetry<T>(operation: () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? AppError.unknownError
    }
    
    private func getLoginPageAndToken() async throws -> (html: String, token: String) {
        var request = URLRequest(url: URL(string: loginURL)!)
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let html = String(data: data, encoding: .utf8) else {
            throw AppError.invalidResponse
        }
        
        guard let csrfToken = extractCSRFToken(from: html) else {
            throw AppError.csrfTokenNotFound
        }
        
        return (html, csrfToken)
    }
    
    private func processCaptchaForLogin() async throws -> String {
        let captchaData = try await getCaptcha()
        OCRCaptcha.setCaptchaData(captchaData)
        return try OCRCaptcha.processCaptcha()
    }
    
    private func submitLoginForm(account: String, password: String, csrfToken: String, captcha: String) async throws -> LoginResult {
        var loginRequest = URLRequest(url: URL(string: loginURL)!)
        loginRequest.httpMethod = "POST"
        headers.forEach { loginRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        loginRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let loginData: [String: String] = [
            "account": account,
            "password": password,
            "csrf-t": csrfToken,
            "_fmSubmit": "yes",
            "formVer": "3.0",
            "formId": "login_form",
            "next": "/dashboard",
            "captcha": captcha
        ]
        
        loginRequest.httpBody = loginData
            .map { "\($0.key)=\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (responseData, response) = try await session.data(for: loginRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let ret = json["ret"] as? [String: Any] else {
            throw AppError.invalidResponse
        }
        
        if ret["status"] as? String == "true" {
            let cookies = HTTPCookieStorage.shared.cookies ?? []
            let phpsessid = cookies.first { $0.name == "PHPSESSID" }?.value
            
            return LoginResult(
                success: true,
                message: "登入成功",
                phpsessid: phpsessid
            )
        } else {
            let errorMsg = (ret["msg"] as? String) ?? "登入失敗"
            return LoginResult(
                success: false,
                message: errorMsg,
                phpsessid: nil
            )
        }
    }
    
    private func extractCSRFToken(from html: String) -> String? {
        do {
            let doc = try SwiftSoup.parse(html)
            return try doc.select("input[name=csrf-t]").first()?.attr("value")
        } catch {
            return nil
        }
    }
    
    private func parseDashboardEvents(from html: String) throws -> DashboardResult {
        do {
            let doc = try SwiftSoup.parse(html)
            let table = try doc.select("#recentEventTable tbody tr")
            
            let events = try table.map { row -> DashboardEvent in
                let cols = try row.select("td")
                
                let titleElement = try cols[0].select("a")
                let title = try titleElement.select("span.text").text()
                let titleLink = try titleElement.attr("href")
                
                let sourceElement = try cols[1].select("a")
                let source = try sourceElement.select("span.text").text()
                let sourceLink = try sourceElement.attr("href")
                
                let deadlineElement = try cols[2].select("div.text-overflow")
                let deadline = try deadlineElement.hasAttr("title") ?
                deadlineElement.attr("title") :
                deadlineElement.text()
                
                return DashboardEvent(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    titleLink: baseURL + titleLink,
                    source: source.trimmingCharacters(in: .whitespacesAndNewlines),
                    sourceLink: baseURL + sourceLink,
                    deadline: deadline.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            
            return DashboardResult(success: true, events: events)
        } catch {
            return DashboardResult(success: false, events: [])
        }
    }
}

// MARK: - Data Structures
struct LoginResult {
    let success: Bool
    let message: String
    let phpsessid: String?
}

struct DashboardEvent {
    let title: String
    let titleLink: String
    let source: String
    let sourceLink: String
    let deadline: String
}

struct DashboardResult {
    let success: Bool
    let events: [DashboardEvent]
}
