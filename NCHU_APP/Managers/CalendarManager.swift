import Foundation
import EventKit
import SwiftUI

@MainActor // 確保所有屬性更新都在主線程
class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    
    @Published var errorMessage: String?
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    private init() {
        if #available(iOS 17.0, *) {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        } else {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
    }
    
    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            let granted = await withCheckedContinuation { continuation in
                eventStore.requestWriteOnlyAccessToEvents { granted, error in
                    continuation.resume(returning: granted)
                }
            }
            if granted {
                authorizationStatus = .writeOnly
            } else {
                authorizationStatus = .denied
            }
            return granted
        } else {
            let granted = await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    continuation.resume(returning: granted)
                }
            }
            if granted {
                authorizationStatus = .authorized
            } else {
                authorizationStatus = .denied
            }
            return granted
        }
    }
    
    func addAssignmentToCalendar(assignment: Assignment) async -> Bool {
        // 檢查權限狀態
        if authorizationStatus == .notDetermined {
            _ = await requestAccess()
        }
        
        // 檢查權限狀態
        if #available(iOS 17.0, *) {
            guard authorizationStatus == .fullAccess || authorizationStatus == .writeOnly else {
                errorMessage = "需要日曆權限才能新增作業截止日期提醒"
                return false
            }
        } else {
            guard authorizationStatus == .authorized else {
                errorMessage = "需要日曆權限才能新增作業截止日期提醒"
                return false
            }
        }
        
        // 解析截止日期字串
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_TW")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        
        // 嘗試不同的日期格式
        let dateFormats = [
            // 完整格式（包含秒）
            "yyyy-MM-dd HH:mm:ss",
            "yyyy/MM/dd HH:mm:ss",
            "yyyy年MM月dd日 HH:mm:ss",
            
            // 不含秒的格式
            "yyyy/MM/dd HH:mm",
            "yyyy-MM-dd HH:mm",
            "yyyy年MM月dd日 HH:mm",
            
            // 只有日期的格式
            "yyyy/MM/dd",
            "yyyy-MM-dd",
            "yyyy年MM月dd日",
            
            // 簡化格式
            "yyyy/M/d HH:mm:ss",
            "yyyy-M-d HH:mm:ss",
            "yyyy年M月d日 HH:mm:ss",
            "yyyy/M/d HH:mm",
            "yyyy-M-d HH:mm",
            "yyyy年M月d日 HH:mm",
            "yyyy/M/d",
            "yyyy-M-d",
            "yyyy年M月d日"
        ]
        
        var dueDate: Date?
        var usedFormat: String?
        
        for format in dateFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: assignment.deadline) {
                dueDate = date
                usedFormat = format
                break
            }
        }
        
        guard let dueDate = dueDate else {
            errorMessage = "無法解析截止日期：\(assignment.deadline)"
            return false
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "📚 作業截止：\(assignment.title)"
        event.notes = """
        課程：\(assignment.source)
        連結：\(assignment.titleLink)
        原始截止日期：\(assignment.deadline)
        """
        
        // 設定截止時間
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        if !usedFormat!.contains(":") {
            // 如果原始格式沒有時間，設為當天晚上 23:59
            components.hour = 23
            components.minute = 59
        }
        
        event.startDate = Calendar.current.date(from: components) ?? dueDate
        event.endDate = event.startDate.addingTimeInterval(60) // 持續1分鐘
        
        // 設定提醒
        event.addAlarm(EKAlarm(relativeOffset: -86400)) // 提前一天
        event.addAlarm(EKAlarm(relativeOffset: -3600))  // 提前一小時
        
        // 獲取預設日曆
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
            errorMessage = "無法獲取預設日曆"
            return false
        }
        
        event.calendar = defaultCalendar
        
        // 儲存事件
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            errorMessage = "無法新增到日曆：\(error.localizedDescription)"
            return false
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            Task { @MainActor in
                await UIApplication.shared.open(url)
            }
        }
    }
} 
