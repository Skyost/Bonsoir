package fr.skyost.bonsoir

import android.content.Context
import android.net.wifi.WifiManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

/**
 * The main plugin Kotlin class.
 */
public class BonsoirPlugin : FlutterPlugin {
    companion object {
        /**
         * The log tag.
         */
        const val tag: String = "bonsoir"

        /**
         * The plugin channel.
         */
        const val channel: String = "fr.skyost.bonsoir"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = BonsoirPlugin()
            plugin.startListening(registrar.context(), registrar.messenger())
            registrar.addViewDestroyListener {
                plugin.stopListening()
                false
            }
        }
    }

    /**
     * The current method channel instance.
     */
    private lateinit var channel: MethodChannel

    /**
     * The current method call handler instance.
     */
    private lateinit var methodCallHandler: MethodCallHandler

    /**
     * The current multicast lock instance.
     */
    private lateinit var multicastLock: WifiManager.MulticastLock

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        startListening(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        stopListening()
    }

    private fun startListening(applicationContext: Context, messenger: BinaryMessenger) {
        multicastLock =
            (applicationContext.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager).createMulticastLock(
                "bonsoirMulticastLock"
            )
        multicastLock.setReferenceCounted(true)

        methodCallHandler = MethodCallHandler(applicationContext, multicastLock, messenger)
        channel = MethodChannel(messenger, BonsoirPlugin.channel)
        channel.setMethodCallHandler(methodCallHandler)
    }

    private fun stopListening() {
        methodCallHandler.dispose()
        channel.setMethodCallHandler(null)
    }
}
