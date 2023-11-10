package fr.skyost.bonsoir.broadcast

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
import io.flutter.plugin.common.EventChannel.EventSink

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
    private val id: Int,
    private val printLogs: Boolean,
    private val onDispose: Runnable,
    private val nsdManager: NsdManager,
    messenger: BinaryMessenger,
    private val service: BonsoirService
) : NsdManager.RegistrationListener {

    /**
     * The current event channel.
     */
    private val eventChannel: EventChannel =
        EventChannel(messenger, "${BonsoirPlugin.channel}.broadcast.$id")

    /**
     * The current event sink.
     */
    private var eventSink: EventSink? = null

    /**
     * Whether the broadcast is active.
     */
    private var isActive = false

    /**
     * Initializes this instance.
     */
    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventSink) {
                this@BonsoirServiceBroadcast.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    /**
     * Starts the service registration.
     */
    fun start() {
        if (!isActive) {
            nsdManager.registerService(service.toNsdService(), NsdManager.PROTOCOL_DNS_SD, this)
        }
    }

    override fun onServiceRegistered(service: NsdServiceInfo) {
        isActive = true
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service registered : ${this.service}")
        }
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("broadcastStarted", this.service).toJson())
        }
    }

    override fun onRegistrationFailed(service: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(
                BonsoirPlugin.tag,
                "[$id] Bonsoir service registration failed : ${this.service}, error code : $errorCode"
            )
        }
        Handler(Looper.getMainLooper()).post {
            eventSink?.error("broadcastError", "Bonsoir service registration failed.", errorCode)
        }
        dispose()
    }

    override fun onServiceUnregistered(service: NsdServiceInfo) {
        val wasActive = isActive
        isActive = false
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service broadcast stopped : ${this.service}")
        }
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("broadcastStopped", this.service).toJson())
        }
        dispose(wasActive)
    }

    override fun onUnregistrationFailed(service: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(
                BonsoirPlugin.tag,
                "[$id] Bonsoir service unregistration failed : ${this.service}, error code : $errorCode"
            )
        }
        Handler(Looper.getMainLooper()).post {
            eventSink?.error("broadcastError", "Bonsoir service unregistration failed.", errorCode)
        }
    }

    /**
     * Disposes the current class instance.
     */
    fun dispose(notify: Boolean = isActive) {
        if (isActive) {
            isActive = false
            nsdManager.unregisterService(this)
        }
        if (notify) {
            onDispose.run()
        }
    }
}