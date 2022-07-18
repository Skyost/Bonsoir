package fr.skyost.bonsoir

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.net.wifi.WifiManager
import androidx.annotation.NonNull
import fr.skyost.bonsoir.broadcast.BonsoirBroadcastListener
import fr.skyost.bonsoir.discovery.BonsoirDiscoveryListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

/**
 * Allows to handle method calls.
 *
 * @param applicationContext The application context.
 * @param multicastLock The current multicast lock.
 * @param messenger The binary messenger.
 */
class MethodCallHandler(
        private val applicationContext: Context,
        private val multicastLock: WifiManager.MulticastLock,
        private val messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {
    /**
     * Contains all registration listeners (Broadcast).
     */
    private val registrationListeners: HashMap<Int, BonsoirBroadcastListener> = HashMap()

    /**
     * Contains all discovery listeners (Discovery).
     */
    private val discoveryListeners: HashMap<Int, BonsoirDiscoveryListener> = HashMap()

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        val nsdManager: NsdManager = applicationContext.getSystemService(Context.NSD_SERVICE) as NsdManager
        val id: Int = call.argument<Int>("id")!!
        when (call.method) {
            "broadcast.initialize" -> {
                registrationListeners[id] = BonsoirBroadcastListener(id, call.argument<Boolean>("printLogs")!!, Runnable {
                    multicastLock.release()
                    registrationListeners.remove(id)
                }, nsdManager, messenger)
                result.success(true)
            }
            "broadcast.start" -> {
                multicastLock.acquire()

                val service = NsdServiceInfo()
                service.serviceName = call.argument<String>("service.name")
                service.serviceType = call.argument<String>("service.type")
                service.port = call.argument<Int>("service.port")!!

                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                    val attributes: Map<String, String> = call.argument<Map<String, String>>("service.attributes")!!
                    for(entry in attributes.entries) {
                        service.setAttribute(entry.key, entry.value)
                    }
                }

                registrationListeners[id]?.registerService(service)
                result.success(true)
            }
            "broadcast.stop" -> {
                registrationListeners[id]?.dispose()
                result.success(true)
            }
            "discovery.initialize" -> {
                discoveryListeners[id] = BonsoirDiscoveryListener(id, call.argument<Boolean>("printLogs")!!, Runnable {
                    multicastLock.release()
                    discoveryListeners.remove(id)
                }, nsdManager, messenger)
                result.success(true)
            }
            "discovery.start" -> {
                multicastLock.acquire()

                discoveryListeners[id]?.discoverServices(call.argument<String>("type")!!)
                result.success(true)
            }
            "discovery.stop" -> {
                discoveryListeners[id]?.dispose()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Disposes the current instance.
     */
    fun dispose() {
        for (registrationListener in ArrayList(registrationListeners.values)) {
            registrationListener.dispose()
        }
        for (discoveryListener in ArrayList(discoveryListeners.values)) {
            discoveryListener.dispose()
        }
    }
}