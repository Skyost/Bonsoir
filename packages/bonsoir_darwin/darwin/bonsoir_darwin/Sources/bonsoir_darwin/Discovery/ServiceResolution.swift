import Darwin
import Foundation

/// Turns the C answers `DNSServiceResolve` and `DNSServiceGetAddrInfo` hand back
/// into Swift values.
///
/// These are deliberately free of any Flutter or `NWBrowser` dependency: the
/// plugin target itself can only be built as part of a Flutter app, so keeping
/// the pure part separate is what lets it be unit tested on its own. See
/// `packages/bonsoir_darwin/darwin/Package.swift`.
enum ServiceResolution {
    /// Converts a socket address to a numeric IP address string.
    ///
    /// The returned string owns its storage, so it stays valid after `address`
    /// is gone — DNSSD only guarantees the pointer for the duration of the
    /// callback it came from.
    static func ipAddress(from address: UnsafePointer<sockaddr>) -> String? {
        var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let result = getnameinfo(address, socklen_t(address.pointee.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
        return result == 0 ? String(cString: host) : nil
    }

    /// Allows to unescape services FQDN.
    ///
    /// mDNSResponder quotes `.` and `\` with a backslash and escapes bytes up to
    /// 0x20 as `\DDD`; everything from 0x7F up is passed through as raw UTF-8.
    /// Registering `Café Тест.A\B 机` and resolving it produces the label
    /// `Café\032Тест\.A\\B\032机` — the accented and CJK bytes untouched, the
    /// spaces escaped, the dot and the backslash quoted.
    ///
    /// The `\\` case is what this has to get right. Without it a backslash was
    /// re-emitted and the position advanced by one, so the second backslash was
    /// then emitted on its own and one came back as two. The resolved name is
    /// what `findService` matches the browsed service by, so a service whose
    /// name contains a backslash matched nothing and could never resolve.
    ///
    /// Decoding runs over bytes rather than characters, and the sequence is read
    /// back as UTF-8 once at the end: an escape encodes a single byte, and the
    /// unescaped bytes around it are already UTF-8 that must be left alone.
    static func unescapeAscii(_ inputString: String) -> String {
        let input = Array(inputString.utf8)
        let backslash = UInt8(ascii: "\\")
        let zero = UInt8(ascii: "0")
        let nine = UInt8(ascii: "9")

        var bytes: [UInt8] = []
        bytes.reserveCapacity(input.count)

        var i = 0
        while i < input.count {
            guard input[i] == backslash, i + 1 < input.count else {
                bytes.append(input[i])
                i += 1
                continue
            }

            let next = input[i + 1]
            guard next >= zero, next <= nine else {
                // `\.` and `\\`: the following character stands for itself.
                bytes.append(next)
                i += 2
                continue
            }

            // Up to three decimal digits, encoding a single byte.
            var value = 0
            var end = i + 1
            while end < input.count, end - i <= 3, input[end] >= zero, input[end] <= nine {
                value = value * 10 + Int(input[end] - zero)
                end += 1
            }
            guard value <= Int(UInt8.max) else {
                // Not something mDNSResponder can have produced; keep it as is.
                bytes.append(input[i])
                i += 1
                continue
            }
            bytes.append(UInt8(value))
            i = end
        }

        return String(decoding: bytes, as: UTF8.self)
    }

    /// Parses a Bonjour FQDN.
    static func parseBonjourFqdn(_ fqdn: String) -> (String, String)? {
        let regexPattern = "^(.*?)\\._(.*?)\\.?(?:local)?\\.?$"
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
        if let match = regex.firstMatch(in: fqdn, options: [], range: NSRange(location: 0, length: fqdn.utf16.count)) {
            let serviceName = (fqdn as NSString).substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            let serviceType = "_\((fqdn as NSString).substring(with: match.range(at: 2)))"
            return (serviceName, serviceType)
        }
        return nil
    }
}
