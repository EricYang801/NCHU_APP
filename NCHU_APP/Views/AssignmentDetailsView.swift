import SwiftUI

struct AssignmentDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var assignmentStore: AssignmentStore
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationBarView(
                    title: "作業列表",
                    onBack: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(spacing: Theme.Layout.spacing) {
                        ForEach(assignmentStore.assignments) { assignment in
                            AssignmentCard(assignment: assignment)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
}

#Preview {
    AssignmentDetailsView(assignmentStore: AssignmentStore())
}
