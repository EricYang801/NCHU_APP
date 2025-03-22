import SwiftUI

struct AssignmentDetailsView: View {
    @EnvironmentObject var assignmentManager: AssignmentManager
    @StateObject private var calendarManager = CalendarManager.shared
    @State private var showingAlert = false
    @State private var showingPermissionAlert = false
    let assignment: Assignment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(assignment.title)
                    .font(.title)
                    .padding(.bottom, 8)
                
                Group {
                    InfoRow(title: "課程名稱", value: assignment.source)
                    InfoRow(title: "繳交期限", value: assignment.deadline)
                }
                .padding(.horizontal)
                
                Divider()
                
                // 作業連結
                Link(destination: URL(string: assignment.titleLink)!) {
                    HStack {
                        Text("查看作業詳情")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // 加入行事曆按鈕
                Button(action: {
                    Task {
                        if calendarManager.authorizationStatus == .denied {
                            showingPermissionAlert = true
                        } else {
                            let success = await calendarManager.addAssignmentToCalendar(assignment: assignment)
                            if success {
                                showingAlert = true
                            }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("加入行事曆")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("成功", isPresented: $showingAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("已將作業截止日期加入行事曆")
        }
        .alert("需要行事曆權限", isPresented: $showingPermissionAlert) {
            Button("取消", role: .cancel) { }
            Button("前往設定") {
                calendarManager.openSettings()
            }
        } message: {
            Text("請在設定中允許應用程式存取行事曆，以便新增作業截止日期提醒")
        }
        .onChange(of: calendarManager.errorMessage) { oldValue, newValue in
            if newValue != nil {
                showingAlert = true
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

#Preview {
    NavigationView {
        AssignmentDetailsView(
            assignment: Assignment(
                from: DashboardEvent(
                    title: "測試作業",
                    titleLink: "https://example.com",
                    source: "測試課程",
                    sourceLink: "https://example.com",
                    deadline: "2024/03/22"
                )
            )
        )
        .environmentObject(AssignmentManager.shared)
    }
}
