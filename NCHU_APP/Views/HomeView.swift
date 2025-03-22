import SwiftUI

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var assignmentManager: AssignmentManager
    @AppStorage("userName") private var userName: String = "你好"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    WelcomeHeader(userName: userName)
                    AssignmentSection(
                        assignments: assignmentManager.assignments,
                        isLoading: appManager.isLoading
                    )
                    FunctionButtonsSection(buttons: Constants.functionButtons)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationDestinations()
            .toolbar { refreshButton }
            .overlay { loadingOverlay }
            .errorAlert(
                isPresented: .constant(appManager.errorMessage != nil),
                message: appManager.errorMessage,
                onDismiss: { appManager.errorMessage = nil }
            )
            .task {
                if assignmentManager.assignments.isEmpty {
                    await appManager.refreshAssignments()
                }
            }
        }
    }
    
    private var refreshButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            RefreshButton {
                await appManager.refreshAssignments()
            }
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if appManager.isLoading {
                LoadingOverlay()
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func navigationDestinations() -> some View {
        self
            .navigationDestination(for: Assignment.self) { assignment in
                AssignmentDetailsView(assignment: assignment)
            }
            .navigationDestination(for: String.self) { value in
                if value == "all_assignments" {
                    AllAssignmentsView()
                }
            }
    }
    
    func errorAlert(isPresented: Binding<Bool>, message: String?, onDismiss: @escaping () -> Void) -> some View {
        alert("錯誤", isPresented: isPresented) {
            Button("確定", role: .cancel, action: onDismiss)
        } message: {
            Text(message ?? "")
        }
    }
}

// MARK: - Constants
enum Constants {
    static let functionButtons: [FunctionButtonModel] = [
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
}

// MARK: - Components
struct WelcomeHeader: View {
    let userName: String
    
    var body: some View {
        Text("Hi, \(userName)!")
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AssignmentSection: View {
    let assignments: [Assignment]
    let isLoading: Bool
    
    var body: some View {
        Group {
            if assignments.isEmpty && !isLoading {
                EmptyAssignmentView()
            } else {
                AssignmentList(assignments: assignments)
            }
        }
    }
}

struct EmptyAssignmentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("目前沒有作業")
                .font(.headline)
            Text("點擊右上角重新整理按鈕更新")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 32)
    }
}

struct AssignmentList: View {
    let assignments: [Assignment]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(assignments.prefix(3))) { assignment in
                NavigationLink(value: assignment) {
                    AssignmentCard(assignment: assignment)
                }
            }
            
            if assignments.count > 4 {
                ViewAllAssignmentsButton()
            }
        }
    }
}

struct ViewAllAssignmentsButton: View {
    var body: some View {
        NavigationLink(value: "all_assignments") {
            HStack {
                Text("查看全部作業")
                    .font(.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .stroke(Theme.Colors.border, lineWidth: 0.5)
            )
        }
    }
}

struct FunctionButtonsSection: View {
    let buttons: [FunctionButtonModel]
    
    var body: some View {
        ForEach(buttons) { button in
            LinkButton(
                title: button.title,
                icon: "link"
            ) {
                UIApplication.shared.open(button.url)
            }
        }
    }
}

struct RefreshButton: View {
    let action: () async -> Void
    
    var body: some View {
        Button(action: {
            Task { await action() }
        }) {
            Image(systemName: "arrow.clockwise")
        }
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.2))
    }
}

// MARK: - Supporting Views
struct AllAssignmentsView: View {
    @EnvironmentObject var assignmentManager: AssignmentManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(assignmentManager.assignments) { assignment in
                    NavigationLink(value: assignment) {
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
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(assignment.source)
                .font(.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text("繳交期限：\(assignment.deadline)")
                .font(.caption)
                .foregroundColor(Theme.Colors.dateText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeworkItemStyle()
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
