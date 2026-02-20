import SwiftUI

// MARK: - Dash Theme

enum DashTheme {
    // Brand colors
    static let accent = Color(red: 0.4, green: 0.9, blue: 0.6)
    static let accentDim = Color(red: 0.3, green: 0.7, blue: 0.5)
    static let background = Color(red: 0.1, green: 0.1, blue: 0.12)
    static let surface = Color(red: 0.15, green: 0.15, blue: 0.18)
    static let surfaceHover = Color(red: 0.2, green: 0.2, blue: 0.24)
    static let textPrimary = Color(red: 0.93, green: 0.93, blue: 0.95)
    static let textSecondary = Color(red: 0.6, green: 0.6, blue: 0.65)
    static let danger = Color(red: 0.95, green: 0.4, blue: 0.4)
    static let warning = Color(red: 0.95, green: 0.75, blue: 0.3)

    // Fonts
    static let monoSmall = Font.system(size: 11, design: .monospaced)
    static let monoBody = Font.system(size: 12, design: .monospaced)
    static let monoTitle = Font.system(size: 13, design: .monospaced).weight(.semibold)
    static let sectionHeader = Font.system(size: 10, design: .monospaced).weight(.bold)

    // Layout
    static let cornerRadius: CGFloat = 6
    static let panelWidth: CGFloat = 320
    static let buttonHeight: CGFloat = 32
    static let sectionSpacing: CGFloat = 12
    static let itemSpacing: CGFloat = 6
}

// MARK: - Reusable Button Style

struct DashButtonStyle: ButtonStyle {
    var color: Color = DashTheme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DashTheme.monoSmall)
            .foregroundColor(configuration.isPressed ? color : DashTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DashTheme.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: DashTheme.cornerRadius)
                    .fill(configuration.isPressed ? color.opacity(0.2) : DashTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DashTheme.cornerRadius)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(DashTheme.accent)
            Text(title.uppercased())
                .font(DashTheme.sectionHeader)
                .foregroundColor(DashTheme.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(DashTheme.monoSmall)
                .foregroundColor(DashTheme.textSecondary)
            Spacer()
            Text(value)
                .font(DashTheme.monoSmall)
                .foregroundColor(DashTheme.textPrimary)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
