import NetService
import Socket

class BonsoirServiceDelegate: NetServiceDelegate {
    let id: Int
    let printLogs: Bool

    func netServiceWillPublish(_ sender: NetService) {
        if printLogs {
            print("[\(id)] Bonsoir service registered : \(sender)")
        }
    }

    func netServiceDidPublish(_ sender: NetService) {
        if printLogs {
            print("[\(id)] Bonsoir service broadcasted : \(sender)")
        }
    }

    func netService(_ sender: NetService, didNotPublish error: Error) {
        if printLogs {
            print("[\(id)] Bonsoir service failed to broadcast : \(sender), error code : \(error)")
        }
    }

    func netServiceDidStop(_ sender: NetService) {
        if printLogs {
            print("[\(id)] Bonsoir service broadcast stopped : \(sender)")
        }
    }
}