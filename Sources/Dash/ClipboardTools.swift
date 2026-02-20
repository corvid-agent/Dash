import SwiftUI

// MARK: - ClipboardTools View

struct ClipboardTools: View {
    @State private var statusMessage: String = ""
    @State private var showStatus: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DashTheme.itemSpacing) {
            SectionHeader(title: "Clipboard", icon: "doc.on.clipboard")

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DashTheme.itemSpacing),
                GridItem(.flexible(), spacing: DashTheme.itemSpacing),
            ], spacing: DashTheme.itemSpacing) {
                Button("Copy Path") { copyPath() }
                    .buttonStyle(DashButtonStyle())

                Button("Copy IP") { copyIP() }
                    .buttonStyle(DashButtonStyle())

                Button("Gen UUID") { generateAndCopyUUID() }
                    .buttonStyle(DashButtonStyle())

                Button("Copy Host") { copyHostname() }
                    .buttonStyle(DashButtonStyle())
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

    // MARK: - Actions

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

    private func copyPath() {
        Task {
            let path = await SystemService.shared.currentPath()
            await SystemService.shared.copyToClipboard(path)
            await MainActor.run { showFeedback("Copied: \(path)") }
        }
    }

    private func copyIP() {
        Task {
            let ip = await SystemService.shared.ipAddress()
            await SystemService.shared.copyToClipboard(ip)
            await MainActor.run { showFeedback("Copied: \(ip)") }
        }
    }

    private func generateAndCopyUUID() {
        Task {
            let uuid = await SystemService.shared.generateUUID()
            await SystemService.shared.copyToClipboard(uuid)
            await MainActor.run { showFeedback("UUID copied") }
        }
    }

    private func copyHostname() {
        Task {
            let host = await SystemService.shared.hostname()
            await SystemService.shared.copyToClipboard(host)
            await MainActor.run { showFeedback("Copied: \(host)") }
        }
    }
}
