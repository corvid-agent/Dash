import SwiftUI

// MARK: - DashView (Main Panel)

struct DashView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: DashTheme.sectionSpacing) {
            // Header
            header

            // Sections
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: DashTheme.sectionSpacing) {
                    SystemInfoView()
                    divider
                    QuickActionsView()
                    divider
                    DevToolsView()
                    divider
                    ClipboardTools()
                }
            }
            .frame(maxHeight: 480)

            // Footer
            footer
        }
        .padding(14)
        .frame(width: DashTheme.panelWidth)
        .background(DashTheme.background)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "bolt.square.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DashTheme.accent)
                Text("Dash")
                    .font(DashTheme.monoTitle)
                    .foregroundColor(DashTheme.textPrimary)
            }
            Spacer()
            Text("v1.0")
                .font(DashTheme.monoSmall)
                .foregroundColor(DashTheme.textSecondary)
        }
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(DashTheme.accent.opacity(0.15))
            .frame(height: 1)
            .padding(.horizontal, 4)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(DashButtonStyle(color: DashTheme.danger))
            .frame(width: 80)
        }
    }
}
