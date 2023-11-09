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
 */
class BonsoirServiceDiscovery(
    private val id: Int,
    private val printLogs: Boolean,
    private val onDispose: Runnable,
    private val nsdManager: NsdManager,
    messenger: BinaryMessenger
) : NsdManager.DiscoveryListener, NsdManager.ResolveListener {

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
     * Whether the discovery is currently active.
     */
    private var isDiscoveryActive: Boolean = false

    companion object {
        /**
         * Whether the resolver is currently busy.
         */
        private val isResolverBusy: AtomicBoolean = AtomicBoolean(false)

        /**
         * All services pending for resolution.
         */
        private val pendingServices =
            ConcurrentLinkedQueue<Pair<NsdServiceInfo, BonsoirServiceDiscovery>>()
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

        Handler(Looper.getMainLooper()).post {
            eventSink?.error("discoveryError", "Bonsoir failed to start discovery", errorCode)
        }
        dispose(false)
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
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery stopped : $serviceType")
        }

        isDiscoveryActive = false
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
        dispose()
    }

    /**
     * Resolves the given service.
     */
    fun resolveService(name: String, type: String) {
        val service = NsdServiceInfo().apply {
            serviceName = name
            serviceType = type
        }
        if (isResolverBusy.compareAndSet(false, true)) {
            forceServiceResolution(service, this)
        } else {
            pendingServices.add(Pair(service, this))
        }
    }

    /**
     * Resolves the next NSD service pending resolution.
     */
    private fun resolveNextInQueue() {
        val nextService: Pair<NsdServiceInfo, BonsoirServiceDiscovery>? = pendingServices.poll()
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
     * @param discovery The discovery instance.
     */
    private fun forceServiceResolution(
        service: NsdServiceInfo,
        discovery: BonsoirServiceDiscovery
    ) {
        if (isDiscoveryActive) {
            nsdManager.resolveService(service, discovery)
        }
    }

    override fun onServiceResolved(service: NsdServiceInfo) {
        val bonsoirService = BonsoirService(service)
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has resolved a service : $bonsoirService")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(
                SuccessObject("discoveryServiceResolved", bonsoirService).toJson()
            )
        }
        resolveNextInQueue()
    }

    override fun onResolveFailed(service: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has failed to resolve a service : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(
                SuccessObject("discoveryServiceResolveFailed", BonsoirService(service)).toJson()
            )
        }
        resolveNextInQueue()
    }

    /**
     * Disposes the current class instance.
     */
    fun dispose(stopDiscovery: Boolean = true) {
        if (stopDiscovery && isDiscoveryActive) {
            nsdManager.stopServiceDiscovery(this)
            isDiscoveryActive = false
        }
        onDispose.run()
    }
}
