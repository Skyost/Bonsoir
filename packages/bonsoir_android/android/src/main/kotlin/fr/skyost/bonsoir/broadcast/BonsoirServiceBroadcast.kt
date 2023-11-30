package fr.skyost.bonsoir.broadcast

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import fr.skyost.bonsoir.BonsoirAction
import fr.skyost.bonsoir.BonsoirService
import fr.skyost.bonsoir.Generated
import io.flutter.plugin.common.BinaryMessenger

/**
 * Allows to broadcast a NSD service on local network.
 *
 * @param id The listener identifier.
 * @param printLogs Whether to print debug logs.
 * @param onDispose Triggered when this instance is being disposed.
 * @param nsdManager The NSD manager.
 * @param messenger The Flutter binary messenger.
 * @param service The Bonsoir service to broadcast.
 */
class BonsoirServiceBroadcast(
    id: Int,
    printLogs: Boolean,
    onDispose: Runnable,
    nsdManager: NsdManager,
    messenger: BinaryMessenger,
    private val service: BonsoirService
) : BonsoirAction(
    id,
    "broadcast",
    Generated.broadcastMessages,
    printLogs,
    onDispose,
    nsdManager,
    messenger
), NsdManager.RegistrationListener {

    /**
     * Starts the service registration.
     */
    fun start() {
        if (!isActive) {
            nsdManager.registerService(service.toNsdService(), NsdManager.PROTOCOL_DNS_SD, this)
        }
    }

    override fun onServiceRegistered(service: NsdServiceInfo) {
        makeActive()
        if (this.service.name != service.serviceName) {
            val oldName = this.service.name
            this.service.name = service.serviceName
            onSuccess(Generated.broadcastNameAlreadyExists, this.service, parameters = listOf(oldName))
        }
        onSuccess(Generated.broadcastStarted, this.service)
    }

    override fun onRegistrationFailed(service: NsdServiceInfo, errorCode: Int) {
        onError(parameters = listOf(this.service, errorCode), details = errorCode)
        dispose()
    }

    override fun onServiceUnregistered(service: NsdServiceInfo) {
        val wasActive = isActive
        makeUnactive()
        onSuccess(Generated.broadcastStopped, this.service)
        dispose(wasActive)
    }

    override fun onUnregistrationFailed(service: NsdServiceInfo, errorCode: Int) {
        onError("Bonsoir service unregistration failed : %s (error : %s).", listOf(this.service, errorCode), errorCode)
    }

    override fun stop() {
        nsdManager.unregisterService(this)
    }
}