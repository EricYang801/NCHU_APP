import SwiftUI

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 內容區域
                    contentArea
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Content Area
    private var contentArea: some View {
        ScrollView {
            VStack(spacing: Theme.Layout.spacing) {
                // 標題
                greetingTitle
                
                // 作業區塊
                assignmentsSection
                
                // 功能按鈕
                functionButtons
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - UI Components
    private var greetingTitle: some View {
        Text("Hi, \(viewModel.userName)!")
            .font(.system(size: Theme.FontSize.extraLarge, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
    }
    
    private var assignmentsSection: some View {
        NavigationLink(destination: AssignmentDetailsView(assignmentStore: viewModel.assignmentStore)) {
            VStack(alignment: .leading, spacing: 16) {
                // 標題和數量
                HStack {
                    Text("作業")
                        .font(.system(size: Theme.FontSize.large, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Spacer()
                    Text("\(viewModel.assignmentStore.assignments.count)")
                        .font(.system(size: Theme.FontSize.small, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Theme.Colors.primary)
                        .clipShape(Circle())
                }
                
                // 作業列表
                VStack(spacing: 12) {
                    ForEach(viewModel.limitedAssignments) { assignment in
                        HomeworkItem(assignment: assignment)
                    }
                }
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var functionButtons: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.functionButtons) { button in
                LinkButton(
                    title: button.title,
                    icon: "link",
                    action: { UIApplication.shared.open(button.url) }
                )
            }
        }
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

// MARK: - ViewModel
class HomeViewModel: ObservableObject {
    @Published var assignmentStore = AssignmentStore()
    @AppStorage("userName") var userName: String = "你好"
    
    var limitedAssignments: [Assignment] {
        Array(assignmentStore.assignments.prefix(4))
    }
    
    var functionButtons: [FunctionButtonModel] {
        [
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
}

// MARK: - Models
struct FunctionButtonModel: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

#Preview {
    HomeView()
}
