import XCTest
@testable import BonsoirDarwinCore

/// Covers the conversion of what DNSSD hands back into Swift values.
///
/// The escaping rule these tests encode was measured, not assumed: registering
/// `Café Тест.A\B 机` and resolving it on macOS 26.5 produces the label in
/// `realWorldLabel` below. mDNSResponder escapes `.` and `\` with a backslash
/// and bytes up to 0x20 as `\DDD`, and passes everything from 0x7F up through as
/// raw UTF-8.
final class ServiceResolutionTests: XCTestCase {
    /// The exact label `DNSServiceResolve` reported for a service registered as
    /// `Café Тест.A\B 机`, and the name the browser reported for the same
    /// service. The two have to agree once unescaped, because that is how
    /// `findService` matches a resolution back to a browsed service.
    private static let realWorldLabel = "Café\\032Тест\\.A\\\\B\\032机"
    private static let realWorldName = "Café Тест.A\\B 机"

    // MARK: - ipAddress(from:)

    func testReadsAnIPv4Address() {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_addr.s_addr = inet_addr("192.168.1.42")

        let resolved = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                ServiceResolution.ipAddress(from: $0)
            }
        }

        XCTAssertEqual(resolved, "192.168.1.42")
    }

    func testReadsAnIPv6Address() {
        var address = sockaddr_in6()
        address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
        address.sin6_family = sa_family_t(AF_INET6)
        XCTAssertEqual(inet_pton(AF_INET6, "2001:db8::1", &address.sin6_addr), 1)

        let resolved = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                ServiceResolution.ipAddress(from: $0)
            }
        }

        XCTAssertEqual(resolved, "2001:db8::1")
    }

    // MARK: - unescapeAscii(_:)

    func testLeavesAPlainNameAlone() {
        XCTAssertEqual(ServiceResolution.unescapeAscii("My Service"), "My Service")
    }

    func testDecodesEscapedControlBytes() {
        // Space is 0x20, so mDNSResponder escapes it; anything below is escaped too.
        XCTAssertEqual(ServiceResolution.unescapeAscii("My\\032Service"), "My Service")
        XCTAssertEqual(ServiceResolution.unescapeAscii("a\\009b"), "a\tb")
    }

    func testDecodesAnEscapedDot() {
        XCTAssertEqual(ServiceResolution.unescapeAscii("Name\\.With\\.Dots"), "Name.With.Dots")
    }

    /// The defect this rewrite exists for. `unescapeAscii` had no case for an
    /// escaped backslash: it re-emitted the first one and advanced a single
    /// character, so the second was emitted on its own and one backslash came
    /// back as two. The doubled name then matched no browsed service, and such a
    /// service could never resolve.
    func testDecodesAnEscapedBackslash() {
        XCTAssertEqual(ServiceResolution.unescapeAscii("Back\\\\Slash"), "Back\\Slash")
        XCTAssertEqual(ServiceResolution.unescapeAscii("A\\\\B\\\\C"), "A\\B\\C")
    }

    /// Bytes at 0x7F and above are NOT escaped — they arrive as raw UTF-8. So
    /// the decoder has to leave them exactly as they are, which is why it works
    /// on bytes and reassembles at the end rather than per character.
    func testPassesRawUtf8Through() {
        XCTAssertEqual(ServiceResolution.unescapeAscii("Café"), "Café")
        XCTAssertEqual(ServiceResolution.unescapeAscii("Лёня"), "Лёня")
        XCTAssertEqual(ServiceResolution.unescapeAscii("机器"), "机器")
    }

    /// The measured label from a real registration, end to end.
    func testDecodesTheLabelDnssdActuallyProduces() {
        XCTAssertEqual(ServiceResolution.unescapeAscii(Self.realWorldLabel), Self.realWorldName)
    }

    /// What the browser reports and what the resolver reports have to agree,
    /// because the resolved name is how the service is looked back up.
    func testRoundTripsEveryNameTheBrowserCanReport() {
        for name in ["plain-ascii", "iPhone Леонида", "Café", "Léonid’s iPhone", "机器 A", "Name.With.Dots", "Studio A\\B", Self.realWorldName] {
            XCTAssertEqual(
                ServiceResolution.unescapeAscii(Self.bonjourEscape(name)),
                name,
                "\(name) did not survive the round trip"
            )
        }
    }

    func testKeepsAnEscapeItCannotHaveProduced() {
        // Above 255 is not a byte, so it is not an escape mDNSResponder wrote.
        XCTAssertEqual(ServiceResolution.unescapeAscii("\\999"), "\\999")
        XCTAssertEqual(ServiceResolution.unescapeAscii("trailing\\"), "trailing\\")
    }

    // MARK: - parseBonjourFqdn(_:)

    func testSplitsAFqdnIntoNameAndType() {
        let parsed = ServiceResolution.parseBonjourFqdn("My Service._promptly._tcp.local.")
        XCTAssertEqual(parsed?.0, "My Service")
        XCTAssertEqual(parsed?.1, "_promptly._tcp")
    }

    func testSplitsAFqdnWithoutATrailingDot() {
        let parsed = ServiceResolution.parseBonjourFqdn("My Service._promptly._tcp.local")
        XCTAssertEqual(parsed?.0, "My Service")
        XCTAssertEqual(parsed?.1, "_promptly._tcp")
    }

    func testSplitsANameThatContainsDots() {
        let parsed = ServiceResolution.parseBonjourFqdn(
            ServiceResolution.unescapeAscii("Name\\.With\\.Dots._http._tcp.local.")
        )
        XCTAssertEqual(parsed?.0, "Name.With.Dots")
        XCTAssertEqual(parsed?.1, "_http._tcp")
    }

    func testRejectsSomethingThatIsNotAFqdn() {
        XCTAssertNil(ServiceResolution.parseBonjourFqdn("no-type-here"))
    }

    // MARK: - Helpers

    /// Escapes a label the way mDNSResponder does, as measured: `.` and `\` are
    /// quoted with a backslash, bytes up to 0x20 become `\DDD`, and everything
    /// else — including every byte of a multi-byte character — is left raw.
    private static func bonjourEscape(_ name: String) -> String {
        var escaped: [UInt8] = []
        for byte in Array(name.utf8) {
            if byte == UInt8(ascii: ".") || byte == UInt8(ascii: "\\") {
                escaped.append(UInt8(ascii: "\\"))
                escaped.append(byte)
            } else if byte <= 0x20 {
                escaped.append(UInt8(ascii: "\\"))
                escaped.append(contentsOf: Array(String(format: "%03d", Int(byte)).utf8))
            } else {
                escaped.append(byte)
            }
        }
        return String(decoding: escaped, as: UTF8.self)
    }
}
