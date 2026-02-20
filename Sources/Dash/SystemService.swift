import Foundation

// MARK: - SystemService Actor

actor SystemService {
    static let shared = SystemService()

    private init() {}

    // MARK: - Shell Execution

    @discardableResult
    func run(_ command: String) async -> (output: String, exitCode: Int32) {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return (output, process.terminationStatus)
        } catch {
            return ("Error: \(error.localizedDescription)", 1)
        }
    }

    // MARK: - System Info

    func ipAddress() async -> String {
        let result = await run("ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo 'No IP'")
        return result.output
    }

    func hostname() async -> String {
        let result = await run("hostname")
        return result.output
    }

    func macOSVersion() async -> String {
        let result = await run("sw_vers -productVersion")
        return "macOS \(result.output)"
    }

    func uptime() async -> String {
        let result = await run("uptime | sed 's/.*up //' | sed 's/,.*//'")
        return result.output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func cpuUsage() async -> String {
        let result = await run("top -l 1 -n 0 | grep 'CPU usage' | awk '{print $3, $4, $5, $6}'")
        return result.output.isEmpty ? "N/A" : result.output
    }

    func memoryPressure() async -> String {
        let result = await run("memory_pressure 2>/dev/null | tail -1 | awk '{print $NF}' || echo 'N/A'")
        return result.output
    }

    // MARK: - Quick Actions

    func openTerminal() async {
        await run("open -a Terminal")
    }

    func clearDNSCache() async -> String {
        let result = await run("sudo -n dscacheutil -flushcache 2>/dev/null && echo 'DNS cache cleared' || echo 'Requires sudo'")
        return result.output
    }

    func restartFinder() async -> String {
        let result = await run("killall Finder && echo 'Finder restarted'")
        return result.output
    }

    func toggleHiddenFiles() async -> String {
        let current = await run("defaults read com.apple.finder AppleShowAllFiles 2>/dev/null")
        let isShowing = current.output.lowercased() == "true" || current.output == "1"
        let newValue = isShowing ? "false" : "true"
        await run("defaults write com.apple.finder AppleShowAllFiles -bool \(newValue) && killall Finder")
        return isShowing ? "Hidden files: OFF" : "Hidden files: ON"
    }

    func emptyTrash() async -> String {
        let result = await run("osascript -e 'tell application \"Finder\" to empty trash' 2>/dev/null && echo 'Trash emptied' || echo 'Failed'")
        return result.output
    }

    // MARK: - Dev Tools

    func killPort(_ port: Int) async -> String {
        let result = await run("lsof -ti tcp:\(port) | xargs kill -9 2>/dev/null && echo 'Killed process on port \(port)' || echo 'No process on port \(port)'")
        return result.output
    }

    func restartDock() async -> String {
        let result = await run("killall Dock && echo 'Dock restarted'")
        return result.output
    }

    func purgeMemory() async -> String {
        let result = await run("sudo -n purge 2>/dev/null && echo 'Memory purged' || echo 'Requires sudo'")
        return result.output
    }

    func rebuildSpotlight() async -> String {
        let result = await run("sudo -n mdutil -E / 2>/dev/null && echo 'Spotlight rebuilding' || echo 'Requires sudo'")
        return result.output
    }

    // MARK: - Clipboard Tools

    func currentPath() async -> String {
        let result = await run("pwd")
        return result.output
    }

    func generateUUID() -> String {
        return UUID().uuidString
    }

    func copyToClipboard(_ text: String) async {
        await run("echo '\(text.replacingOccurrences(of: "'", with: "'\\''"))' | pbcopy")
    }
}
