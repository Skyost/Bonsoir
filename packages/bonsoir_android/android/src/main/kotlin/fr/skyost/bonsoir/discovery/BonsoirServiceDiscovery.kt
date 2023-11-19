package fr.skyost.bonsoir.discovery

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import fr.skyost.bonsoir.BonsoirAction
import fr.skyost.bonsoir.BonsoirService
import io.flutter.plugin.common.BinaryMessenger
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
    id: Int,
    printLogs: Boolean,
    onDispose: Runnable,
    nsdManager: NsdManager,
    messenger: BinaryMessenger,
    private val type: String,
) : BonsoirAction(
    id,
    "discovery",
    printLogs,
    onDispose,
    nsdManager,
    messenger
), NsdManager.DiscoveryListener {

    companion object {
        /**
         * Whether the resolver is currently busy.
         */
        private val isResolverBusy: AtomicBoolean = AtomicBoolean(false)

        /**
         * All services pending for resolution.
         */
        private val pendingServices = ConcurrentLinkedQueue<Pair<NsdServiceInfo, BonsoirDiscoveryResolveListener>>()
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
        makeActive()
        onSuccess("discoveryStarted", "Bonsoir discovery started : $regType")
    }

    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
        onError("Bonsoir failed to start discovery : $errorCode", errorCode)
        dispose(true)
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        val bonsoirService = BonsoirService(service)
        onSuccess("discoveryServiceFound", "Bonsoir has found a service : $bonsoirService", bonsoirService)

        val txtRecord = DiscoveryUtils.resolveTXTRecord((service.serviceName + "." + service.serviceType) + "local")
        if (txtRecord != null) {
            log("Bonsoir has found the attributes of a service : $bonsoirService")
            bonsoirService.attributes.clear()
            bonsoirService.attributes.putAll(txtRecord.dict)
            onSuccess(eventId = "discoveryServiceLost", service = bonsoirService)
            onSuccess(eventId = "discoveryServiceFound", service = bonsoirService)
        }
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        val bonsoirService = BonsoirService(service)
        onSuccess("discoveryServiceLost", "A Bonsoir service has been lost : $bonsoirService", bonsoirService)
    }

    override fun onDiscoveryStopped(serviceType: String) {
        val wasActive = isActive
        makeUnactive()
        onSuccess("discoveryStopped", "Bonsoir discovery stopped : $serviceType")
        dispose(wasActive)
    }

    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
        onError("Bonsoir has encountered an error while stopping the discovery : $errorCode", errorCode)
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
                this@BonsoirServiceDiscovery.onSuccess("discoveryServiceResolveFailed", "Bonsoir has failed to resolve a service : $errorCode", BonsoirService(service))
                resolveNextInQueue()
            },
            { resolvedService: NsdServiceInfo ->
                val bonsoirService = BonsoirService(resolvedService)
                this@BonsoirServiceDiscovery.onSuccess("discoveryServiceResolved", "Bonsoir has resolved a service : $bonsoirService", bonsoirService)
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

    override fun stop() {
        nsdManager.stopServiceDiscovery(this)
    }

    override fun dispose(notify: Boolean) {
        val iterator = pendingServices.iterator()
        while (iterator.hasNext()) {
            if (iterator.next().second.discoveryId == id) {
                iterator.remove()
            }
        }
        if (pendingServices.isEmpty()) {
            isResolverBusy.set(false)
        }
        super.dispose(notify)
    }
}

/**
 * Allows to listen to resolve events.
 */
private class BonsoirDiscoveryResolveListener(
    val discoveryId: Int,
    val resolveFailedCallback: (NsdServiceInfo, Int) -> Unit,
    val serviceResolvedCallback: (NsdServiceInfo) -> Unit
) : NsdManager.ResolveListener {
    override fun onServiceResolved(service: NsdServiceInfo) {
        serviceResolvedCallback(service)
    }

    override fun onResolveFailed(service: NsdServiceInfo, errorCode: Int) {
        resolveFailedCallback(service, errorCode)
    }
}
