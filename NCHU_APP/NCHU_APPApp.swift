//
//  NCHU_APPApp.swift
//  NCHU_APP
//
//  Created by Eric Yang on 3/21/25.
//

import SwiftUI

@main
struct NCHU_APPApp: App {
    @StateObject private var appManager = AppManager.shared
    @StateObject private var assignmentManager = AssignmentManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appManager)
                .environmentObject(assignmentManager)
        }
    }
}
