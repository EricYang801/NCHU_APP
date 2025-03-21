import SwiftUI

struct AssignmentDetailsView: View {
    @EnvironmentObject var assignmentManager: AssignmentManager
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
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
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
