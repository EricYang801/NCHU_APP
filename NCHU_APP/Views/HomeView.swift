import SwiftUI

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var assignmentManager: AssignmentManager
    @AppStorage("userName") private var userName: String = "你好"
    
    private let functionButtons: [FunctionButtonModel] = [
        FunctionButtonModel(
            title: "單一入口",
            url: URL(string: "https://ccidp.nchu.edu.tw/login")!
        ),
        FunctionButtonModel(
            title: "iLearning",
            url: URL(string: "https://lms2020.nchu.edu.tw/index/login?next=%2Fdashboard")!
        ),
        FunctionButtonModel(
            title: "中興大學行事曆",
            url: URL(string: "https://www.nchu.edu.tw/calendar/")!
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    // 歡迎訊息
                    Text("Hi, \(userName)!")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if assignmentManager.assignments.isEmpty && !appManager.isLoading {
                        VStack(spacing: 8) {
                            Text("目前沒有作業")
                                .font(.headline)
                            Text("點擊右上角重新整理按鈕更新")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 32)
                    } else {
                        // 作業列表（最多顯示4個）
                        ForEach(Array(assignmentManager.assignments.prefix(3))) { assignment in
                            NavigationLink(destination: AssignmentDetailsView(assignment: assignment)) {
                                AssignmentCard(assignment: assignment)
                            }
                        }
                        
                        // 如果有超過4個作業，顯示查看全部按鈕
                        if assignmentManager.assignments.count > 4 {
                            NavigationLink(destination: AllAssignmentsView()) {
                                HStack {
                                    Text("查看全部作業")
                                        .font(.headline)
                                    Image(systemName: "chevron.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // 功能按鈕
                    ForEach(functionButtons) { button in
                        LinkButton(
                            title: button.title,
                            icon: "link"
                        ) {
                            UIApplication.shared.open(button.url)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await appManager.refreshAssignments()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if appManager.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("錯誤", isPresented: .constant(appManager.errorMessage != nil)) {
                Button("確定", role: .cancel) {
                    appManager.errorMessage = nil
                }
            } message: {
                Text(appManager.errorMessage ?? "")
            }
            .task {
                if assignmentManager.assignments.isEmpty {
                    await appManager.refreshAssignments()
                }
            }
        }
    }
}

// 新增顯示全部作業的視圖
struct AllAssignmentsView: View {
    @EnvironmentObject var assignmentManager: AssignmentManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(assignmentManager.assignments) { assignment in
                    NavigationLink(destination: AssignmentDetailsView(assignment: assignment)) {
                        AssignmentCard(assignment: assignment)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("全部作業")
    }
}

struct AssignmentCard: View {
    let assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(assignment.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(assignment.source)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("繳交期限：\(assignment.deadline)")
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - TabBarButton
struct TabBarButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: Theme.FontSize.regular))
            Text(text)
                .font(.system(size: Theme.FontSize.small))
        }
        .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textSecondary)
    }
}

// MARK: - Models
struct FunctionButtonModel: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

#Preview {
    HomeView()
        .environmentObject(AppManager.shared)
        .environmentObject(AssignmentManager.shared)
}
