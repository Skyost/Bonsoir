package fr.skyost.bonsoir.broadcast

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.util.Log
import fr.skyost.bonsoir.BonsoirPlugin
import fr.skyost.bonsoir.SuccessObject
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class BonsoirRegistrationListener(
        private val id: Int,
        private val printLogs: Boolean,
        private val onDispose: Runnable,
        private val nsdManager: NsdManager,
        messenger: BinaryMessenger
) : NsdManager.RegistrationListener {

    private val eventChannel: EventChannel = EventChannel(messenger, "${BonsoirPlugin.channel}.broadcast.$id")
    private var eventSink: EventSink? = null

    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventSink) {
                this@BonsoirRegistrationListener.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onServiceRegistered(serviceInfo: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service registered : $serviceInfo")
        }
        eventSink?.success(SuccessObject("broadcast_started").toJson())
    }

    override fun onRegistrationFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service registration failed : $serviceInfo, error code : $errorCode")
        }
        eventSink?.error("broadcast_error", "Bonsoir service registration failed.", errorCode);
        dispose()
    }

    override fun onServiceUnregistered(serviceInfo: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service broadcast stopped : $serviceInfo")
        }
        eventSink?.success(SuccessObject("broadcast_stopped").toJson())
        dispose(false)
    }

    override fun onUnregistrationFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service unregistration failed : $serviceInfo, error code : $errorCode")
        }
        eventSink?.error("broadcast_error", "Bonsoir service unregistration failed.", errorCode)
        dispose()
    }

    fun dispose(unregister: Boolean = true) {
        if(unregister) {
            nsdManager.unregisterService(this)
        }
        onDispose.run()
    }
}