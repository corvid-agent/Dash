import SwiftUI

// MARK: - QuickActionsView

struct QuickActionsView: View {
    @State private var statusMessage: String = ""
    @State private var showStatus: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DashTheme.itemSpacing) {
            SectionHeader(title: "Quick Actions", icon: "bolt.fill")

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DashTheme.itemSpacing),
                GridItem(.flexible(), spacing: DashTheme.itemSpacing),
            ], spacing: DashTheme.itemSpacing) {
                Button("Open Terminal") { runAction { await SystemService.shared.openTerminal(); return "Terminal opened" } }
                    .buttonStyle(DashButtonStyle())

                Button("Clear DNS") { runAction { await SystemService.shared.clearDNSCache() } }
                    .buttonStyle(DashButtonStyle())

                Button("Restart Finder") { runAction { await SystemService.shared.restartFinder() } }
                    .buttonStyle(DashButtonStyle())

                Button("Toggle Hidden") { runAction { await SystemService.shared.toggleHiddenFiles() } }
                    .buttonStyle(DashButtonStyle())

                Button("Empty Trash") { runAction { await SystemService.shared.emptyTrash() } }
                    .buttonStyle(DashButtonStyle(color: DashTheme.danger))
            }

            if showStatus {
                Text(statusMessage)
                    .font(DashTheme.monoSmall)
                    .foregroundColor(DashTheme.accent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity)
            }
        }
    }

    private func runAction(_ action: @escaping @Sendable () async -> String) {
        Task {
            let result = await action()
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    statusMessage = result
                    showStatus = true
                }
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showStatus = false
                }
            }
        }
    }
}
