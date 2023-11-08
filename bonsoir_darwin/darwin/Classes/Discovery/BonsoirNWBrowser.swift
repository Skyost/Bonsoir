#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Foundation
import Network

/// Allows to find net services on local network.
class BonsoirNWBrowser: NSObject, NWBrowser, FlutterStreamHandler {
    /// The delegate identifier.
    let id: Int

    /// Whether to print debug logs.
    let printLogs: Bool

    /// Triggered when this instance is being disposed.
    let onDispose: (Bool) -> Void

    /// The current event channel.
    var eventChannel: FlutterEventChannel?

    /// The current event sink.
    var eventSink: FlutterEventSink?
    
    /// Contains all found services.
    var services: [BonsoirService] = []
	
	/// Contains all active connections.
	var activeConnections: [NWConnection] = []

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping (Bool) -> Void, messenger: FlutterBinaryMessenger, type: String) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        self.stateUpdateHandler = stateHandler
        self.browseResultsChangedHandler = browseHandler
        super.init(for: .bonjour(type: type))
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).discovery.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }
    
    /// Handles state changes.
    func stateHandler(_ newState: NWBrowser.State) {
        switch newState {
        case .setup:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir discovery initialized : \(type)")
            }
        case .ready:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir discovery started : \(type)")
            }
            eventSink?(SuccessObject(id: "discoveryStarted").toJson())
        case .failed(let error):
            if printLogs {
                SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has encountered an error during discovery : \(error)")
            }
            eventSink?(FlutterError.init(code: "discoveryError", message: "Bonsoir has encountered an error during discovery.", details: error))
            dispose()
        case .cancelled:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir discovery stopped : \(browser)")
            }
            eventSink?(SuccessObject(id: "discoveryStopped").toJson())
            dispose(stopDiscovery: false)
        default:
            break
        }
    }

    /// Handles the browsing of services.
    func browseHandler(_ newResults: Set<NWBrowser.Result>, _ changes: Set<NWBrowser.Result.Change>) {
        for change in changes {
            switch change {
            case .added(let result):
                if case .service(let name, let type, let domain, let interface) = result.endpoint {
                    let service = BonsoirService(name: name, type: type)
                    if case .boujour(records) = result.metadata {
                        service.attributes = records.dictionary
                    }
                    if printLogs {
                        SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has found a service : \(service)")
                    }
                    eventSink?(SuccessObject(id: "discoveryServiceFound", service: service).toJson())
                    services.append(service)
                }
            case .removed(let result):
                if case .service(let name, let type, let domain, let interface) = result.endpoint {
                    let service = services.first(where: {$0.name == oldName && $0.type == oldType})
                    if printLogs {
                        SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "A Bonsoir service has been lost : \(service)")
                    }
                    eventSink?(SuccessObject(id: "discoveryServiceLost", service: service).toJson())
                    if service != nil {
                        services.remove(at: services.index(of: service))
                    }
                }
            case .changed(let old, let new, let flags):
                if case .service(let newName, let newType, let newDomain, let newInterface) = new.endpoint {
                    if case .service(let oldName, let oldType, let oldDomain, let oldInterface) = old.endpoint {
                        let service = services.first(where: {$0.name == oldName && $0.type == oldType})
                        if printLogs {
                            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "A Bonsoir service has changed : \(service)")
                        }
                        eventSink?(SuccessObject(id: "discoveryServiceLost", service: service).toJson())
                        if service != nil {
                            service.name = newName
                            service.type = newType
                            if case .boujour(newRecords) = new.metadata {
                                service.attributes = newRecords.dictionary
                            }
                        }    
                        eventSink?(SuccessObject(id: "discoveryServiceFound", service: service).toJson())
                    }
                }
            default:
                break
            }
        }
    }

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    /// Resolves a service.
    public func resolveService(name: String, type: String) -> Bool {
        for result in browseResults {
            if case .service(let name, let type, let domain, let interface) = result.endpoint {
                let service = services.first(where: {$0.name == oldName && $0.type == oldType})
                if service == nil {
                    return false
                }
                let connection = NWConnection(to: result.endpoint, using: .tcp)
                connection.stateUpdateHandler = { state in
					switch state {
                    case .ready:
                        if let innerEndpoint = connection.currentPath?.remoteEndpoint, case .hostPort(let host, let port) = innerEndpoint {
                            service.ip = host
                            service.port = port
                            if printLogs {
                                SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has resolved a service : \(service)")
                            }
                            eventSink?(SuccessObject(id: "discoveryServiceResolved", service: service).toJson())
                        }
                    case .failed:
                        if printLogs {
                            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has failed to resolve a service : \(error)")
                        }
                        eventSink?(SuccessObject(id: "discoveryServiceResolveFailed", service: service).toJson())
                    default:
                        break
                    }
					activeConnections.remove(at: services.index(of: connection))
					connection.cancel()
                }
				activeConnections.append(connection)
                connection.start(queue: .global())
                return true
            }
        }
        return false
    }

    /// Disposes the current class instance.
    public func dispose(stopDiscovery: Bool = true) {
        services.removeAll()
		for connection in activeConnections {
			connection.forceCancel()
		}
		activeConnections.removeAll()
        onDispose(stopDiscovery)
    }
}
