package fr.skyost.bonsoir

import android.net.nsd.NsdManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * Allows to execute a network action.
 *
 * @param id The listener identifier.
 * @param action The action.
 * @param printLogs Whether to print debug logs.
 * @param onDispose Triggered when this instance is being disposed.
 * @param nsdManager The NSD manager instance.
 * @param messenger The Flutter binary messenger.
 */
abstract class BonsoirAction(
    protected val id: Int,
    private val action: String,
    private val printLogs: Boolean,
    private val onDispose: Runnable,
    protected val nsdManager: NsdManager,
    messenger: BinaryMessenger,
) {
    companion object {
        /**
         * The log tag.
         */
        private const val tag: String = "bonsoir"
    }

    /**
     * The current event channel.
     */
    private val eventChannel: EventChannel = EventChannel(messenger, "${BonsoirPlugin.channel}.$action.$id")

    /**
     * The current event sink.
     */
    private var eventSink: EventChannel.EventSink? = null

    /**
     * Whether the discovery is active.
     */
    var isActive = false
        private set

    /**
     * Initializes this instance.
     */
    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                this@BonsoirAction.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    /**
     * Triggered when a success occurs.
     *
     * @param eventId The event id.
     * @param message The message.
     * @param service The service involved.
     */
    fun onSuccess(eventId: String, message: String? = null, service: BonsoirService? = null) {
        if (message != null) {
            log(message)
        }
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject(eventId, service).toJson())
        }
    }

    /**
     * Triggered when an error occurs.
     *
     * @param message The message.
     * @param details The error details.
     */
    fun onError(message: String, details: Any? = null) {
        log(message)
        Handler(Looper.getMainLooper()).post {
            eventSink?.error("${action}Error", message, details)
        }
    }

    /**
     * Makes this action active.
     */
    fun makeActive() {
        isActive = true
    }

    /**
     * Makes this action unactive.
     */
    fun makeUnactive() {
        isActive = false
    }

    /**
     * Stops this action.
     */
    abstract fun stop()

    /**
     * Disposes the current class instance.
     *
     * @param notify Whether to notify listeners.
     */
    open fun dispose(notify: Boolean = isActive) {
        if (isActive) {
            isActive = false
            stop()
        }
        if (notify) {
            onDispose.run()
        }
    }

    /**
     * Logs the given message to the console, if enabled.
     *
     * @param message The message.
     */
    fun log(message: String) {
        if (printLogs) {
            Log.d(tag, "[$id] $message")
        }
    }
}