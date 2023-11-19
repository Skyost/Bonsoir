package fr.skyost.bonsoir

import android.content.Context
import android.net.nsd.NsdManager
import android.net.wifi.WifiManager
import fr.skyost.bonsoir.broadcast.BonsoirServiceBroadcast
import fr.skyost.bonsoir.discovery.BonsoirServiceDiscovery
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
     * Contains all broadcast instances.
     */
    private val broadcasts: HashMap<Int, BonsoirServiceBroadcast> = HashMap()

    /**
     * Contains all discovery instances.
     */
    private val discoveries: HashMap<Int, BonsoirServiceDiscovery> = HashMap()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val id: Int = call.argument<Int>("id")!!
        when (call.method) {
            "broadcast.initialize" -> {
                val service = BonsoirService(
                    call.argument<String>("service.name")!!,
                    call.argument<String>("service.type")!!,
                    call.argument<Int>("service.port")!!,
                    call.argument<String>("service.host"),
                    call.argument<MutableMap<String, String>>("service.attributes")!!,
                )
                broadcasts[id] =
                    BonsoirServiceBroadcast(
                        id,
                        call.argument<Boolean>("printLogs")!!,
                        {
                            multicastLock.release()
                            broadcasts.remove(id)
                        },
                        applicationContext.getSystemService(Context.NSD_SERVICE) as NsdManager,
                        messenger,
                        service,
                    )
                result.success(true)
            }

            "broadcast.start" -> {
                multicastLock.acquire()
                broadcasts[id]?.start()
                result.success(broadcasts[id] != null)
            }

            "broadcast.stop" -> {
                broadcasts[id]?.dispose()
                result.success(broadcasts[id] != null)
            }

            "discovery.initialize" -> {
                discoveries[id] =
                    BonsoirServiceDiscovery(
                        id,
                        call.argument<Boolean>("printLogs")!!,
                        {
                            multicastLock.release()
                            discoveries.remove(id)
                        },
                        applicationContext.getSystemService(Context.NSD_SERVICE) as NsdManager,
                        messenger,
                        call.argument<String>("type")!!,
                    )
                result.success(true)
            }

            "discovery.start" -> {
                multicastLock.acquire()
                discoveries[id]?.start()
                result.success(discoveries[id] != null)
            }

            "discovery.resolveService" -> {
                discoveries[id]?.resolveService(
                    call.argument<String>("name")!!,
                    call.argument<String>("type")!!
                )
                result.success(discoveries[id] != null)
            }

            "discovery.stop" -> {
                discoveries[id]?.dispose()
                result.success(discoveries[id] != null)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Disposes the current instance.
     */
    fun dispose() {
        for (broadcast in ArrayList(broadcasts.values)) {
            broadcast.dispose()
        }
        for (discovery in ArrayList(discoveries.values)) {
            discovery.dispose()
        }
    }
}