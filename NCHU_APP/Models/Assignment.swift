import Foundation

struct Assignment: Identifiable, Codable {
    let id: UUID
    let title: String
    let titleLink: String
    let source: String
    let sourceLink: String
    let deadline: String
    let lastUpdated: Date
    
    init(from event: DashboardEvent) {
        self.id = UUID()
        self.title = event.title
        self.titleLink = event.titleLink
        self.source = event.source
        self.sourceLink = event.sourceLink
        self.deadline = event.deadline
        self.lastUpdated = Date()
    }
}

// Assignment 管理器
class AssignmentManager: ObservableObject {
    @Published private(set) var assignments: [Assignment] = []
    private let userDefaults = UserDefaults.standard
    private let assignmentsKey = "savedAssignments"
    
    static let shared = AssignmentManager()
    
    private init() {
        loadAssignments()
    }
    
    func updateAssignments(from events: [DashboardEvent]) {
        let newAssignments = events.map { Assignment(from: $0) }
        assignments = newAssignments
        saveAssignments()
    }
    
    private func saveAssignments() {
        if let encoded = try? JSONEncoder().encode(assignments) {
            userDefaults.set(encoded, forKey: assignmentsKey)
        }
    }
    
    private func loadAssignments() {
        if let data = userDefaults.data(forKey: assignmentsKey),
           let decoded = try? JSONDecoder().decode([Assignment].self, from: data) {
            assignments = decoded
        }
    }
    
    func clearAssignments() {
        assignments = []
        saveAssignments()
    }
} 
