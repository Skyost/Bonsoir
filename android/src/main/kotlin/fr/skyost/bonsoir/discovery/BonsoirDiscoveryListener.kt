package fr.skyost.bonsoir.discovery

import android.net.nsd.NsdManager
import android.net.nsd.NsdManager.ResolveListener
import android.net.nsd.NsdServiceInfo
import android.os.Handler
import android.os.Looper
import android.util.Log
import fr.skyost.bonsoir.BonsoirPlugin
import fr.skyost.bonsoir.SuccessObject
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * Allows to find NSD services on local network.
 *
 * @param id The listener identifier.
 * @param printLogs Whether to print debug logs.
 * @param onDispose Triggered when this instance is being disposed.
 * @param nsdManager The NSD manager.
 * @param messenger The Flutter binary messenger.
 */
class BonsoirDiscoveryListener(
        private val id: Int,
        private val printLogs: Boolean,
        private val onDispose: Runnable,
        private val nsdManager: NsdManager,
        messenger: BinaryMessenger
) : NsdManager.DiscoveryListener {

    /**
     * The current event channel.
     */
    private val eventChannel: EventChannel = EventChannel(messenger, "${BonsoirPlugin.channel}.discovery.$id")

    /**
     * The current event sink.
     */
    private var eventSink: EventChannel.EventSink? = null

    /**
     * Initializes this instance.
     */
    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                this@BonsoirDiscoveryListener.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onDiscoveryStarted(regType: String) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery started : $regType")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_started").toJson())
        }
    }

    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir failed to start discovery : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.error("discovery_error", "Bonsoir failed to start discovery", errorCode)
        }
        dispose()
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        nsdManager.resolveService(service, object : ResolveListener {
            override fun onServiceResolved(service: NsdServiceInfo) {
                if (printLogs) {
                    Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has discovered a service : $service")
                }

                Handler(Looper.getMainLooper()).post {
                    eventSink?.success(SuccessObject("discovery_service_found", serviceToJson(service)).toJson())
                }
            }

            override fun onResolveFailed(service: NsdServiceInfo, errorCode: Int) {
                if (printLogs) {
                    Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has discovered a service but failed to resolve it : $service")
                }

                Handler(Looper.getMainLooper()).post {
                    eventSink?.success(SuccessObject("discovery_service_found", serviceToJson(service)).toJson())
                }
            }
        })
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        nsdManager.resolveService(service, object : ResolveListener {
            override fun onServiceResolved(service: NsdServiceInfo) {
                if (printLogs) {
                    Log.d(BonsoirPlugin.tag, "[$id] A Bonsoir discovered service has been lost : $service")
                }

                Handler(Looper.getMainLooper()).post {
                    eventSink?.success(SuccessObject("discovery_service_lost", serviceToJson(service)).toJson())
                }
            }

            override fun onResolveFailed(service: NsdServiceInfo, errorCode: Int) {
                if (printLogs) {
                    Log.d(BonsoirPlugin.tag, "[$id] A Bonsoir discovered service has been lost and Bonsoir failed to resolve it : $service")
                }

                Handler(Looper.getMainLooper()).post {
                    eventSink?.success(SuccessObject("discovery_service_lost", serviceToJson(service)).toJson())
                }
            }
        })
    }

    override fun onDiscoveryStopped(serviceType: String) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery stopped : $serviceType")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_stopped").toJson())
        }
        dispose(false)
    }

    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has encountered an error while stopping the discovery : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.error("discovery_error", "Bonsoir has encountered an error while stopping the discovery", errorCode)
        }
        dispose()
    }

    /**
     * Disposes the current class instance.
     */
    fun dispose(stopDiscovery: Boolean = true) {
        if(stopDiscovery) {
            nsdManager.stopServiceDiscovery(this)
        }
        onDispose.run()
    }

    /**
     * Converts a given server to a map.
     *
     * @return Them map.
     */
    private fun serviceToJson(service: NsdServiceInfo): Map<String, Any?> {
        return mapOf(
                "service.name" to service.serviceName,
                "service.type" to service.serviceType,
                "service.port" to service.port,
                "service.ip" to service.host?.hostAddress
        )
    }
}