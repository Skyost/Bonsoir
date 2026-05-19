package fr.skyost.bonsoir.discovery

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.os.Build
import android.os.ext.SdkExtensions
import fr.skyost.bonsoir.BonsoirAction
import fr.skyost.bonsoir.BonsoirService
import fr.skyost.bonsoir.Generated
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.coroutines.CoroutineContext

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
    Generated.discoveryMessages,
    printLogs,
    onDispose,
    nsdManager,
    messenger
), NsdManager.DiscoveryListener, CoroutineScope {

    companion object {
        /**
         * Whether the resolver is currently busy.
         */
        private val isResolverBusy: AtomicBoolean = AtomicBoolean(false)

        /**
         * All services pending for resolution.
         */
        private val resolveQueue = ConcurrentLinkedQueue<Pair<BonsoirService, BonsoirDiscoveryResolveListener>>()
    }

    private val scopeJob = SupervisorJob()

    override val coroutineContext: CoroutineContext
        get() = Dispatchers.IO + scopeJob

    /**
     * Contains all discovered services.
     */
    private val services: ArrayList<BonsoirService> = ArrayList()

    /**
     * Contains all active callbacks.
     */
    private val activeCallbacks = ConcurrentHashMap<String, NsdManager.ServiceInfoCallback>()

    /**
     * Executor used by service info callbacks.
     */
    private val serviceInfoCallbackExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    /**
     * Starts the discovery.
     */
    fun start() {
        if (!isActive) {
            nsdManager.discoverServices(type, NsdManager.PROTOCOL_DNS_SD, this)
        }
    }

    /**
     * Finds a service instance in the discovered services.
     *
     * @param service The NSD service info instance.
     */
    private fun findService(service: NsdServiceInfo): BonsoirService? {
        val type = if (service.serviceType.endsWith(".")) service.serviceType.substring(
            0,
            service.serviceType.length - 1
        ) else service.serviceType
        return findService(service.serviceName, type)
    }

    /**
     * Finds a service instance in the discovered services.
     *
     * @param name The service name.
     * @param type The service type.
     */
    private fun findService(name: String, type: String? = null): BonsoirService? {
        for (service in ArrayList(services)) {
            if (name == service.name && (type == null || type == service.type)) {
                return service
            }
        }
        return null
    }

    override fun onDiscoveryStarted(regType: String) {
        makeActive()
        onSuccess(Generated.discoveryStarted, parameters = listOf(regType))
    }

    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
        onError(parameters = listOf(serviceType, errorCode), details = errorCode)
        dispose(true)
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        var bonsoirService = findService(service)
        if (bonsoirService != null) {
            return
        }
        bonsoirService = BonsoirService(service)
        services.add(bonsoirService)
        onSuccess(Generated.discoveryServiceFound, bonsoirService)
        queryTxtRecord(bonsoirService)
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        val bonsoirService = findService(service)
        if (bonsoirService != null) {
            services.remove(bonsoirService)
            val callbackKey = callbackKey(bonsoirService)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && SdkExtensions.getExtensionVersion(Build.VERSION_CODES.TIRAMISU) >= 7 && activeCallbacks.containsKey(callbackKey)) {
                val callback = activeCallbacks[callbackKey]!!
                try {
                    nsdManager.unregisterServiceInfoCallback(callback)
                } catch (ex: Exception) {
                    ex.printStackTrace()
                }
                activeCallbacks.remove(callbackKey)
            }
            onSuccess(Generated.discoveryServiceLost, bonsoirService)
        }
    }

    override fun onDiscoveryStopped(serviceType: String) {
        val wasActive = isActive
        makeUnactive()
        onSuccess(Generated.discoveryStopped, parameters = listOf(serviceType))
        dispose(wasActive)
    }

    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
        onError(
            "Bonsoir has encountered an error while stopping the discovery : %s (error : %s).",
            listOf(type, errorCode),
            errorCode
        )
    }

    /**
     * Queries the TXT record of a service.
     *
     * @param
     */
    private fun queryTxtRecord(service: BonsoirService) {
        launch {
            val data = TxtRecord.resolveTxtRecord(service)
            if (data == null) {
                onServiceTxtRecordNotFound(service)
            } else {
                onServiceTxtRecordFound(service, data)
            }
        }
    }

    /**
     * Triggered when a Bonsoir service TXT record has been found.
     *
     * @param service The Bonsoir service instance.
     * @param txtRecord The TXT record data instance.
     */
    private fun onServiceTxtRecordFound(service: BonsoirService, txtRecord: TxtRecordData) {
        val currentService = findService(service.name, service.type) ?: return
        if (currentService.attributes != txtRecord.dictionary) {
            log(
                logMessages[Generated.discoveryTxtResolved]!!,
                listOf(currentService, txtRecord.dictionary)
            )
            currentService.attributes = txtRecord.dictionary
            onSuccess(Generated.discoveryServiceUpdated, currentService)
        }
    }

    /**
     * Triggered when a Bonsoir service TXT record has not been found.
     *
     * @param service The Bonsoir service instance.
     */
    private fun onServiceTxtRecordNotFound(service: BonsoirService) {
        log(logMessages[Generated.discoveryTxtResolveFailed]!!, listOf(service, "null"))
    }

    /**
     * Resolves the given service.
     *
     * @param name The service name.
     * @param type The service type.
     */
    fun resolveService(name: String, type: String) {
        val bonsoirService = findService(name, type)
        if (bonsoirService == null) {
            onError(
                logMessages[Generated.discoveryUndiscoveredServiceResolveFailed]!!,
                listOf(name, type)
            )
            return
        }
        val listener = BonsoirDiscoveryResolveListener(
            id,
            { _: NsdServiceInfo, errorCode: Int ->
                onSuccess(
                    Generated.discoveryServiceResolveFailed,
                    bonsoirService,
                    parameters = listOf(errorCode)
                )
                resolveNextInQueue()
            },
            { resolvedService: NsdServiceInfo ->
                val resolvedBonsoirService = BonsoirService(resolvedService)
                bonsoirService.hostAddresses = resolvedBonsoirService.hostAddresses
                bonsoirService.hostname = resolvedBonsoirService.hostname
                bonsoirService.port = resolvedBonsoirService.port
                bonsoirService.attributes = resolvedBonsoirService.attributes
                onSuccess(Generated.discoveryServiceResolved, bonsoirService)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && SdkExtensions.getExtensionVersion(Build.VERSION_CODES.TIRAMISU) >= 7) {
                    val callbackKey = callbackKey(bonsoirService)
                    if (activeCallbacks.containsKey(callbackKey)) {
                        val callback = activeCallbacks[callbackKey]!!
                        try {
                            nsdManager.unregisterServiceInfoCallback(callback)
                        } catch (ex: Exception) {
                            ex.printStackTrace()
                        }
                        activeCallbacks.remove(callbackKey)
                    }
                    val serviceInfoCallback = object : NsdManager.ServiceInfoCallback {
                        override fun onServiceInfoCallbackRegistrationFailed(error: Int) {
                            onError("Failed to register service info callback (error $error).", listOf(error))
                            activeCallbacks.remove(callbackKey)
                        }

                        override fun onServiceUpdated(service: NsdServiceInfo) {
                            val updatedBonsoirService = BonsoirService(service)
                            bonsoirService.hostAddresses = updatedBonsoirService.hostAddresses
                            bonsoirService.hostname = updatedBonsoirService.hostname
                            bonsoirService.port = updatedBonsoirService.port
                            bonsoirService.attributes = updatedBonsoirService.attributes
                            onSuccess(Generated.discoveryServiceUpdated, bonsoirService)
                        }

                        override fun onServiceLost() {
                            // Already handled in `BonsoirServiceDiscovery.onServiceLost`.
                        }

                        override fun onServiceInfoCallbackUnregistered() {
                            activeCallbacks.remove(callbackKey)
                        }
                    }
                    activeCallbacks[callbackKey] = serviceInfoCallback
                    nsdManager.registerServiceInfoCallback(
                        NsdServiceInfo().apply {
                            serviceName = bonsoirService.name
                            serviceType = bonsoirService.type
                        },
                        serviceInfoCallbackExecutor,
                        serviceInfoCallback,
                    )
                }
                resolveNextInQueue()
            },
        )
        if (isResolverBusy.compareAndSet(false, true)) {
            forceServiceResolution(bonsoirService, listener)
        } else {
            resolveQueue.add(Pair(bonsoirService, listener))
        }
    }

    /**
     * Resolves the next NSD service pending resolution.
     */
    private fun resolveNextInQueue() {
        val nextService: Pair<BonsoirService, BonsoirDiscoveryResolveListener>? =
            resolveQueue.poll()
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
        service: BonsoirService,
        listener: BonsoirDiscoveryResolveListener
    ) {
        nsdManager.resolveService(NsdServiceInfo().apply {
            serviceName = service.name
            serviceType = service.type
        }, listener)
    }

    private fun callbackKey(service: BonsoirService): String {
        return "${service.name}.${service.type}"
    }

    override fun stop() {
        scopeJob.cancel()
        nsdManager.stopServiceDiscovery(this)
    }

    override fun dispose(notify: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && SdkExtensions.getExtensionVersion(Build.VERSION_CODES.TIRAMISU) >= 7) {
            for (value in activeCallbacks.values) {
                try {
                    nsdManager.unregisterServiceInfoCallback(value)
                } catch (ex: Exception) {
                    ex.printStackTrace()
                }
            }
        }
        activeCallbacks.clear()
        serviceInfoCallbackExecutor.shutdownNow()
        val iterator = resolveQueue.iterator()
        while (iterator.hasNext()) {
            if (iterator.next().second.discoveryId == id) {
                iterator.remove()
            }
        }
        if (resolveQueue.isEmpty()) {
            isResolverBusy.set(false)
        }
        services.clear()
        super.dispose(notify)
    }
}

/**
 * Allows to listen to resolve events.
 *
 * @param discoveryId The identifier.
 * @param resolveFailedCallback Called when the resolving has failed.
 * @param serviceResolvedCallback Called when the resolving has succeeded.
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
