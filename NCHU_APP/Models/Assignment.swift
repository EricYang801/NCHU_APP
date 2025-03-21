import Foundation

struct Assignment: Identifiable {
    let id = UUID()
    let title: String
    let courseName: String
    let dueDate: String
    let description: String
}

class AssignmentStore: ObservableObject {
    @Published var assignments: [Assignment] = [
        Assignment(
            title: "數學作業 #1",
            courseName: "程式設計",
            dueDate: "2024/03/20",
            description: "請完成第1章習題"
        ),
        Assignment(
            title: "英文作業 #2",
            courseName: "程式設計",
            dueDate: "2024/03/22",
            description: "請完成第2章習題"
        ),
        Assignment(
            title: "英文作業 #3",
            courseName: "程式設計",
            dueDate: "2024/03/22",
            description: "請完成第3章習題"
        ),
        Assignment(
            title: "英文作業 #3",
            courseName: "程式設計",
            dueDate: "2024/03/22",
            description: "請完成第3章習題"
        ),
        Assignment(
            title: "英文作業 #3",
            courseName: "程式設計",
            dueDate: "2024/03/22",
            description: "請完成第3章習題"
        )
    ]
} 
