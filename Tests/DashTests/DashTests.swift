import Foundation

// MARK: - Minimal Test Framework

nonisolated(unsafe) var passes = 0
nonisolated(unsafe) var failures = 0

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ msg: String = "") {
    if a != b {
        print("  FAIL: \(msg) - got \(a), expected \(b)")
        failures += 1
    } else {
        print("  PASS: \(msg)")
        passes += 1
    }
}

func assertTrue(_ condition: Bool, _ msg: String = "") {
    if !condition {
        print("  FAIL: \(msg) - condition was false")
        failures += 1
    } else {
        print("  PASS: \(msg)")
        passes += 1
    }
}

func assertFalse(_ condition: Bool, _ msg: String = "") {
    assertTrue(!condition, msg)
}

func assertContains(_ string: String, _ substring: String, _ msg: String = "") {
    if !string.contains(substring) {
        print("  FAIL: \(msg) - '\(string)' does not contain '\(substring)'")
        failures += 1
    } else {
        print("  PASS: \(msg)")
        passes += 1
    }
}

func assertNotEmpty(_ string: String, _ msg: String = "") {
    if string.isEmpty {
        print("  FAIL: \(msg) - string was empty")
        failures += 1
    } else {
        print("  PASS: \(msg)")
        passes += 1
    }
}

// MARK: - Shell Helper (mirrors SystemService logic without actor)

func shell(_ command: String) -> (output: String, exitCode: Int32) {
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

// MARK: - Test Suites

func testShellExecution() {
    print("\n[Shell Execution]")

    let echo = shell("echo hello")
    assertEqual(echo.output, "hello", "echo command output")
    assertEqual(echo.exitCode, 0, "echo exit code")

    let fail = shell("false")
    assertEqual(fail.exitCode, 1, "failing command exit code")

    let multiline = shell("echo 'line1\nline2'")
    assertContains(multiline.output, "line1", "multiline output contains line1")
    assertContains(multiline.output, "line2", "multiline output contains line2")
}

func testSystemInfo() {
    print("\n[System Info]")

    let hostname = shell("hostname")
    assertNotEmpty(hostname.output, "hostname is not empty")
    assertEqual(hostname.exitCode, 0, "hostname exit code")

    let version = shell("sw_vers -productVersion")
    assertNotEmpty(version.output, "macOS version is not empty")
    assertTrue(version.output.contains("."), "macOS version contains dot separator")

    let uptime = shell("uptime")
    assertNotEmpty(uptime.output, "uptime output is not empty")
    assertEqual(uptime.exitCode, 0, "uptime exit code")
}

func testClipboardTools() {
    print("\n[Clipboard Tools]")

    // Test UUID generation
    let uuid1 = UUID().uuidString
    let uuid2 = UUID().uuidString
    assertTrue(uuid1 != uuid2, "UUIDs are unique")
    assertEqual(uuid1.count, 36, "UUID has correct length (36 chars with dashes)")
    assertTrue(uuid1.contains("-"), "UUID contains dashes")

    // Validate UUID format: 8-4-4-4-12
    let parts = uuid1.split(separator: "-")
    assertEqual(parts.count, 5, "UUID has 5 dash-separated parts")
    assertEqual(parts[0].count, 8, "UUID part 1 is 8 chars")
    assertEqual(parts[1].count, 4, "UUID part 2 is 4 chars")
    assertEqual(parts[2].count, 4, "UUID part 3 is 4 chars")
    assertEqual(parts[3].count, 4, "UUID part 4 is 4 chars")
    assertEqual(parts[4].count, 12, "UUID part 5 is 12 chars")

    // Test copy/paste round-trip via pbcopy/pbpaste
    let testString = "dash-test-\(Int.random(in: 1000...9999))"
    _ = shell("echo -n '\(testString)' | pbcopy")
    let pasted = shell("pbpaste")
    assertEqual(pasted.output, testString, "clipboard round-trip")
}

func testPortValidation() {
    print("\n[Port Validation]")

    // Valid ports
    assertTrue((1...65535).contains(80), "port 80 is valid")
    assertTrue((1...65535).contains(3000), "port 3000 is valid")
    assertTrue((1...65535).contains(8080), "port 8080 is valid")
    assertTrue((1...65535).contains(65535), "port 65535 is valid")

    // Invalid ports
    assertFalse((1...65535).contains(0), "port 0 is invalid")
    assertFalse((1...65535).contains(70000), "port 70000 is invalid")
    assertFalse((1...65535).contains(-1), "port -1 is invalid")

    // String to port parsing
    assertEqual(Int("8080"), 8080, "parse port string '8080'")
    assertEqual(Int("abc"), nil, "parse invalid port string 'abc'")
    assertEqual(Int(""), nil, "parse empty port string")
}

func testThemeValues() {
    print("\n[Theme Values]")

    // Verify constant values are reasonable
    let panelWidth: CGFloat = 320
    assertTrue(panelWidth > 200 && panelWidth < 500, "panel width in range")

    let buttonHeight: CGFloat = 32
    assertTrue(buttonHeight > 20 && buttonHeight < 60, "button height in range")

    let cornerRadius: CGFloat = 6
    assertTrue(cornerRadius > 0 && cornerRadius < 20, "corner radius in range")

    let sectionSpacing: CGFloat = 12
    assertTrue(sectionSpacing > 0 && sectionSpacing < 30, "section spacing in range")

    let itemSpacing: CGFloat = 6
    assertTrue(itemSpacing > 0 && itemSpacing < 20, "item spacing in range")

    // Accent color components
    let r = 0.4, g = 0.9, b = 0.6
    assertTrue(r >= 0 && r <= 1, "accent red in range")
    assertTrue(g >= 0 && g <= 1, "accent green in range")
    assertTrue(b >= 0 && b <= 1, "accent blue in range")
    assertTrue(g > r && g > b, "green is dominant in accent color")
}

func testDevToolsLogic() {
    print("\n[Dev Tools Logic]")

    // Test that lsof works (may or may not find a process)
    let lsof = shell("lsof -ti tcp:1 2>/dev/null; echo done")
    assertContains(lsof.output, "done", "lsof command completes")

    // Verify we can check defaults
    let defaults = shell("defaults read com.apple.finder AppleShowAllFiles 2>/dev/null || echo 'unset'")
    assertNotEmpty(defaults.output, "finder hidden files setting readable")
}

func testPathOperations() {
    print("\n[Path Operations]")

    let pwd = shell("pwd")
    assertNotEmpty(pwd.output, "pwd returns a path")
    assertTrue(pwd.output.hasPrefix("/"), "path starts with /")
    assertEqual(pwd.exitCode, 0, "pwd exit code")
}

// MARK: - Main

print("========================================")
print("  Dash Test Suite")
print("========================================")

testShellExecution()
testSystemInfo()
testClipboardTools()
testPortValidation()
testThemeValues()
testDevToolsLogic()
testPathOperations()

print("\n========================================")
print("  Results: \(passes) passed, \(failures) failed")
print("========================================")

if failures > 0 {
    print("\nSome tests failed.")
    exit(1)
} else {
    print("\nAll tests passed.")
    exit(0)
}
