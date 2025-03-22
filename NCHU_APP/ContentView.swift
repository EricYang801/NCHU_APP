//
//  ContentView.swift
//  NCHU_APP
//
//  Created by Eric Yang on 3/21/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("首頁")
                    }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("設定")
                    }
            }
            .tint(Color(UIColor.systemBlue))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppManager.shared)
        .environmentObject(AssignmentManager.shared)
}
