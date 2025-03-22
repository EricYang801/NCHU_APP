import Foundation

struct Assignment: Identifiable, Codable, Hashable {
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
        assignments = events.map { Assignment(from: $0) }
        saveAssignments()
    }
    
    private func saveAssignments() {
        guard let encoded = try? JSONEncoder().encode(assignments) else { return }
        userDefaults.set(encoded, forKey: assignmentsKey)
    }
    
    private func loadAssignments() {
        guard let data = userDefaults.data(forKey: assignmentsKey),
              let decoded = try? JSONDecoder().decode([Assignment].self, from: data) else { return }
        assignments = decoded
    }
    
    func clearAssignments() {
        assignments = []
        saveAssignments()
    }
} 
