import SwiftUI

// MARK: - DevToolsView

struct DevToolsView: View {
    @State private var portText: String = ""
    @State private var statusMessage: String = ""
    @State private var showStatus: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DashTheme.itemSpacing) {
            SectionHeader(title: "Dev Tools", icon: "wrench.and.screwdriver")

            // Port killer row
            HStack(spacing: DashTheme.itemSpacing) {
                TextField("Port", text: $portText)
                    .textFieldStyle(.plain)
                    .font(DashTheme.monoSmall)
                    .foregroundColor(DashTheme.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: DashTheme.cornerRadius)
                            .fill(DashTheme.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DashTheme.cornerRadius)
                            .stroke(DashTheme.accent.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 80)
                    .onSubmit { killPort() }

                Button("Kill Port") { killPort() }
                    .buttonStyle(DashButtonStyle(color: DashTheme.danger))
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DashTheme.itemSpacing),
                GridItem(.flexible(), spacing: DashTheme.itemSpacing),
            ], spacing: DashTheme.itemSpacing) {
                Button("Restart Dock") { runAction { await SystemService.shared.restartDock() } }
                    .buttonStyle(DashButtonStyle())

                Button("Purge Memory") { runAction { await SystemService.shared.purgeMemory() } }
                    .buttonStyle(DashButtonStyle(color: DashTheme.warning))

                Button("Rebuild Spotlight") { runAction { await SystemService.shared.rebuildSpotlight() } }
                    .buttonStyle(DashButtonStyle(color: DashTheme.warning))
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

    private func killPort() {
        guard let port = Int(portText), port > 0, port <= 65535 else {
            showFeedback("Invalid port number")
            return
        }
        Task {
            let result = await SystemService.shared.killPort(port)
            await MainActor.run { showFeedback(result) }
        }
    }

    private func runAction(_ action: @escaping @Sendable () async -> String) {
        Task {
            let result = await action()
            await MainActor.run { showFeedback(result) }
        }
    }

    private func showFeedback(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            statusMessage = message
            showStatus = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showStatus = false
                }
            }
        }
    }
}
