import SwiftUI

// MARK: - SystemInfoView

struct SystemInfoView: View {
    @State private var ipAddress: String = "..."
    @State private var hostname: String = "..."
    @State private var macOSVersion: String = "..."
    @State private var uptimeStr: String = "..."

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            SectionHeader(title: "System Info", icon: "info.circle")

            VStack(spacing: 0) {
                InfoRow(label: "IP", value: ipAddress)
                InfoRow(label: "Host", value: hostname)
                InfoRow(label: "macOS", value: macOSVersion)
                InfoRow(label: "Uptime", value: uptimeStr)
            }
            .background(
                RoundedRectangle(cornerRadius: DashTheme.cornerRadius)
                    .fill(DashTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DashTheme.cornerRadius)
                    .stroke(DashTheme.accent.opacity(0.15), lineWidth: 1)
            )
        }
        .task { await loadInfo() }
    }

    private func loadInfo() async {
        async let ip = SystemService.shared.ipAddress()
        async let host = SystemService.shared.hostname()
        async let version = SystemService.shared.macOSVersion()
        async let up = SystemService.shared.uptime()

        let results = await (ip, host, version, up)
        ipAddress = results.0
        hostname = results.1
        macOSVersion = results.2
        uptimeStr = results.3
    }
}
