package fr.skyost.bonsoir.discovery

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import java.util.*
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.collections.HashMap

/**
 * Allows to safely resolve NSD services.
 *
 * Kudos https://stackoverflow.com/a/57998099/3608831.
 */
class Resolver(
    private val nsdManager: NsdManager,
    private val onResolved: (NsdServiceInfo) -> Unit,
    private val onFailed: (NsdServiceInfo, Int) -> Unit
) : NsdManager.ResolveListener {

    /**
     * Whether this instance has been disposed.
     */
    private var isDisposed: Boolean = false

    /**
     * Whether the resolver is currently busy.
     */
    private val isBusy: AtomicBoolean = AtomicBoolean(false)

    /**
     * All services pending for resolution.
     */
    private val pendingServices = ConcurrentLinkedQueue<NsdServiceInfo>()

    /**
     * Contains all resolved services address.
     */
    private val resolvedServices: MutableMap<String, ResolvedServiceInfo> =
        Collections.synchronizedMap(HashMap<String, ResolvedServiceInfo>())

    override fun onServiceResolved(service: NsdServiceInfo) {
        if (isDisposed) {
            return
        }

        resolvedServices[service.serviceName] = ResolvedServiceInfo(service)
        onResolved(service)
        resolveNextInQueue()
    }

    override fun onResolveFailed(service: NsdServiceInfo, errorCode: Int) {
        if (isDisposed) {
            return
        }

        onFailed(service, errorCode)
        resolveNextInQueue()
    }

    /**
     * Should be triggered when a service has been found.
     */
    fun resolveWhenPossible(service: NsdServiceInfo) {
        if (isBusy.compareAndSet(false, true)) {
            resolve(service)
        } else {
            pendingServices.add(service)
        }
    }

    /**
     * Should be triggered when a service has been lost.
     */
    fun onServiceLost(service: NsdServiceInfo) {
        val pendingServicesIterator = pendingServices.iterator()
        while (pendingServicesIterator.hasNext()) {
            if (pendingServicesIterator.next().serviceName == service.serviceName) {
                pendingServicesIterator.remove()
            }
        }

        synchronized(resolvedServices) {
            val resolvedServicesIterator = resolvedServices.iterator()
            while (resolvedServicesIterator.hasNext()) {
                if (resolvedServicesIterator.next().key == service.serviceName) {
                    resolvedServicesIterator.remove()
                }
            }
        }
    }

    /**
     * Resolves the next NSD service pending resolution.
     */
    private fun resolveNextInQueue() {
        var nextNsdService: NsdServiceInfo? = pendingServices.poll()
        while (nextNsdService != null && hasResolvedService(nextNsdService)) {
            nextNsdService = pendingServices.poll()
        }

        if (nextNsdService == null) {
            isBusy.set(false)
        } else {
            resolve(nextNsdService)
        }
    }

    /**
     * Resolves the given service if needed.
     */
    private fun resolve(service: NsdServiceInfo) {
        if (!isDisposed) {
            nsdManager.resolveService(service, this)
        }
    }

    /**
     * Returns a resolved service info.
     *
     * @param service The resolved service.
     *
     * @return The resolved service info.
     */
    fun getResolvedServiceIpAddress(service: NsdServiceInfo): ResolvedServiceInfo {
        return resolvedServices[service.serviceName] ?: ResolvedServiceInfo(service)
    }

    /**
     * Returns whether the given service has been resolved.
     *
     * @return Whether the given service has been resolved.
     */
    private fun hasResolvedService(service: NsdServiceInfo): Boolean {
        return resolvedServices.containsKey(service.serviceName)
    }

    /**
     * Disposes this instance.
     */
    fun dispose() {
        isDisposed = true
        pendingServices.clear()
    }
}

/**
 * Contains some info about a resolved NSD service.
 */
data class ResolvedServiceInfo(val port: Int?, val host: String?) {
    /**
     * Creates an object instance from a given service.
     */
    constructor(service: NsdServiceInfo) : this(service.port, service.host?.hostAddress)
}