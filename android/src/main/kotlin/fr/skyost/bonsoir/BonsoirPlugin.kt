package fr.skyost.bonsoir

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar


public class BonsoirPlugin : FlutterPlugin {
    companion object {
        const val tag: String = "bonsoir"
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

    private lateinit var channel: MethodChannel
    private lateinit var methodCallHandler: MethodCallHandler

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        startListening(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger);
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        stopListening();
    }

    private fun startListening(applicationContext: Context, messenger: BinaryMessenger) {
        methodCallHandler = MethodCallHandler(applicationContext, messenger)
        channel = MethodChannel(messenger, BonsoirPlugin.channel)
        channel.setMethodCallHandler(methodCallHandler)
    }

    private fun stopListening() {
        methodCallHandler.dispose()
        channel.setMethodCallHandler(null)
    }
}
