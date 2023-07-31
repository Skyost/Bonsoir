package fr.skyost.bonsoir.discovery

import android.net.nsd.NsdManager
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
    private val eventChannel: EventChannel =
        EventChannel(messenger, "${BonsoirPlugin.channel}.discovery.$id")

    /**
     * The current event sink.
     */
    private var eventSink: EventChannel.EventSink? = null

    /**
     * The current resolver instance.
     */
    private val resolver: Resolver

    /**
     * Whether the discovery is currently active.
     */
    private var isDiscoveryActive: Boolean = false

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
        resolver = Resolver(nsdManager, ::onServiceResolved, ::onFailedToResolveService)
    }

    fun discoverServices(type: String) {
        nsdManager.discoverServices(type, NsdManager.PROTOCOL_DNS_SD, this)
    }

    override fun onDiscoveryStarted(regType: String) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery started : $regType")
        }

        isDiscoveryActive = true
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discoveryStarted").toJson())
        }
    }

    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir failed to start discovery : $errorCode")
        }

        isDiscoveryActive = false
        Handler(Looper.getMainLooper()).post {
            eventSink?.error("discoveryError", "Bonsoir failed to start discovery", errorCode)
        }
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has found a service : $service")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(
                SuccessObject(
                    "discoveryServiceFound",
                    service
                ).toJson(resolver.getResolvedServiceIpAddress(service))
            )
        }
    }

    fun resolveService(name: String, type: String) {
        val service = NsdServiceInfo().apply {
            serviceName = name
            serviceType = type
        }
        resolver.resolveWhenPossible(service)
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        val resolvedServiceInfo: ResolvedServiceInfo = resolver.getResolvedServiceIpAddress(service)
        resolver.onServiceLost(service)

        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] A Bonsoir service has been lost : $service")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(
                SuccessObject("discoveryServiceLost", service).toJson(
                    resolvedServiceInfo
                )
            )
        }
    }

    override fun onDiscoveryStopped(serviceType: String) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery stopped : $serviceType")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discoveryStopped").toJson())
        }
    }

    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
        if (printLogs) {
            Log.d(
                BonsoirPlugin.tag,
                "[$id] Bonsoir has encountered an error while stopping the discovery : $errorCode"
            )
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.error(
                "discoveryError",
                "Bonsoir has encountered an error while stopping the discovery",
                errorCode
            )
        }
    }

    /**
     * Triggered when a service has been resolved.
     */
    private fun onServiceResolved(service: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has resolved a service : $service")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(
                SuccessObject(
                    "discoveryServiceResolved",
                    service
                ).toJson(resolver.getResolvedServiceIpAddress(service))
            )
        }
    }

    /**
     * Triggered when a service failed to resolve.
     */
    private fun onFailedToResolveService(service: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has failed to resolve a service : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(
                SuccessObject("discoveryServiceResolveFailed", service).toJson(
                    resolver.getResolvedServiceIpAddress(service)
                )
            )
        }
    }

    /**
     * Disposes the current class instance.
     */
    fun dispose(stopDiscovery: Boolean = true) {
        if (stopDiscovery && isDiscoveryActive) {
            nsdManager.stopServiceDiscovery(this)
            isDiscoveryActive = false
        }
        resolver.dispose()
        onDispose.run()
    }
}
