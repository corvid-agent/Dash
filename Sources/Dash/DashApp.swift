import SwiftUI

// MARK: - DashApp

@main
struct DashApp: App {
    var body: some Scene {
        MenuBarExtra {
            DashView()
        } label: {
            Label("Dash", systemImage: "bolt.square.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
