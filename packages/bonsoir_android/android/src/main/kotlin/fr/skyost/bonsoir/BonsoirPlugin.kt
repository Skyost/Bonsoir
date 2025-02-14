package fr.skyost.bonsoir

import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * The main plugin Kotlin class.
 */
public class BonsoirPlugin : FlutterPlugin {
    companion object {
        /**
         * The plugin channel.
         */
        const val channel: String = "fr.skyost.bonsoir"
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

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        startListening(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopListening()
    }

    private fun startListening(applicationContext: Context, messenger: BinaryMessenger) {
        val wifiManager =
            applicationContext.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        multicastLock = wifiManager.createMulticastLock("bonsoirMulticastLock")
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
