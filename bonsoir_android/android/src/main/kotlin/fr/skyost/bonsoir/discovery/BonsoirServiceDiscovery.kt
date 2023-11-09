package fr.skyost.bonsoir.discovery

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.os.Handler
import android.os.Looper
import android.util.Log
import fr.skyost.bonsoir.BonsoirPlugin
import fr.skyost.bonsoir.BonsoirService
import fr.skyost.bonsoir.SuccessObject
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Allows to find NSD services on local network.
 *
 * @param id The listener identifier.
 * @param printLogs Whether to print debug logs.
 * @param onDispose Triggered when this instance is being disposed.
 * @param nsdManager The NSD manager instance.
 * @param messenger The Flutter binary messenger.
 * @param type The services type to discover.
 */
class BonsoirServiceDiscovery(
    private val id: Int,
    private val printLogs: Boolean,
    private val onDispose: Runnable,
    private val nsdManager: NsdManager,
    messenger: BinaryMessenger,
    private val type: String,
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
     * Whether the discovery is active.
     */
    private var isActive = false

    companion object {
        /**
         * Whether the resolver is currently busy.
         */
        private val isResolverBusy: AtomicBoolean = AtomicBoolean(false)

        /**
         * All services pending for resolution.
         */
        private val pendingServices =
            ConcurrentLinkedQueue<Pair<NsdServiceInfo, BonsoirDiscoveryResolveListener>>()
    }

    /**
     * Initializes this instance.
     */
    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                this@BonsoirServiceDiscovery.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    /**
     * Starts the discovery.
     */
    fun start() {
        if (!isActive) {
            nsdManager.discoverServices(type, NsdManager.PROTOCOL_DNS_SD, this)
        }
    }

    override fun onDiscoveryStarted(regType: String) {
        isActive = true
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery started : $regType")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discoveryStarted").toJson())
        }
    }

    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir failed to start discovery : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.error("discoveryError", "Bonsoir failed to start discovery", errorCode)
        }
        dispose(true)
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        val bonsoirService = BonsoirService(service)
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has found a service : $bonsoirService")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discoveryServiceFound", bonsoirService).toJson())
        }
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        val bonsoirService = BonsoirService(service)
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] A Bonsoir service has been lost : $bonsoirService")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discoveryServiceLost", bonsoirService).toJson())
        }
    }

    override fun onDiscoveryStopped(serviceType: String) {
        val wasActive = isActive
        isActive = false
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery stopped : $serviceType")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discoveryStopped").toJson())
        }
        dispose(wasActive)
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
     * Resolves the given service.
     */
    fun resolveService(name: String, type: String) {
        val service = NsdServiceInfo().apply {
            serviceName = name
            serviceType = type
        }
        val listener = BonsoirDiscoveryResolveListener(
            id,
            { _: NsdServiceInfo, errorCode: Int ->
                if (printLogs) {
                    Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has failed to resolve a service : $errorCode")
                }

                Handler(Looper.getMainLooper()).post {
                    eventSink?.success(
                        SuccessObject("discoveryServiceResolveFailed", BonsoirService(service)).toJson()
                    )
                }
                resolveNextInQueue()
            },
            { resolvedService: NsdServiceInfo ->
                val bonsoirService = BonsoirService(resolvedService)
                if (printLogs) {
                    Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has resolved a service : $bonsoirService")
                }

                Handler(Looper.getMainLooper()).post {
                    eventSink?.success(
                        SuccessObject("discoveryServiceResolved", bonsoirService).toJson()
                    )
                }
                resolveNextInQueue()
            },
        )
        if (isResolverBusy.compareAndSet(false, true)) {
            forceServiceResolution(service, listener)
        } else {
            pendingServices.add(Pair(service, listener))
        }
    }

    /**
     * Resolves the next NSD service pending resolution.
     */
    private fun resolveNextInQueue() {
        val nextService: Pair<NsdServiceInfo, BonsoirDiscoveryResolveListener>? = pendingServices.poll()
        if (nextService == null) {
            isResolverBusy.set(false)
        } else {
            forceServiceResolution(nextService.first, nextService.second)
        }
    }

    /**
     * Forces a service resolution.
     *
     * @param service The service.
     * @param listener The resolve listener.
     */
    private fun forceServiceResolution(
        service: NsdServiceInfo,
        listener: BonsoirDiscoveryResolveListener
    ) {
        nsdManager.resolveService(service, listener)
    }

    /**
     * Disposes the current class instance.
     */
    fun dispose(notify: Boolean = isActive) {
        val iterator = pendingServices.iterator()
        while (iterator.hasNext()) {
            if (iterator.next().second.discoveryId == id) {
                iterator.remove()
            }
        }
        if (pendingServices.isEmpty()) {
            isResolverBusy.set(false)
        }
        if (isActive) {
            isActive = false
            nsdManager.stopServiceDiscovery(this)
        }
        if (notify) {
            onDispose.run()
        }
    }
}

/**
 * Allows to listen to resolve events.
 */
private class BonsoirDiscoveryResolveListener(
    val discoveryId: Int,
    val resolveFailedCallback: (NsdServiceInfo, Int) -> Unit,
    val serviceResolvedCallback: (NsdServiceInfo) -> Unit
): NsdManager.ResolveListener {
    override fun onServiceResolved(service: NsdServiceInfo) {
        serviceResolvedCallback(service)
    }

    override fun onResolveFailed(service: NsdServiceInfo, errorCode: Int) {
        resolveFailedCallback(service, errorCode)
    }
}
