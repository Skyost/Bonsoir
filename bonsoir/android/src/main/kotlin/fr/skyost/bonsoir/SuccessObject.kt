package fr.skyost.bonsoir

import android.net.nsd.NsdServiceInfo
import fr.skyost.bonsoir.discovery.ResolvedServiceInfo
import kotlin.collections.HashMap

/**
 * Sent to the event channel when there is no error.
 *
 * @param id The response id.
 * @param service The response service.
 */
data class SuccessObject(private val id: String, private val service: NsdServiceInfo? = null) {
    /**
     * Converts the current instance into a map.
     *
     * @param resolvedServiceInfo The resolved service info (if any).
     *
     * @return The map.
     */
    fun toJson(resolvedServiceInfo: ResolvedServiceInfo? = null): Map<String, Any> {
        val json: HashMap<String, Any> = HashMap()
        json["id"] = id
        if(service != null) {
            json["service"] = serviceToJson(service, resolvedServiceInfo ?: ResolvedServiceInfo(service))
        }
        return json
    }

    /**
     * Converts a given service to a map.
     *
     * @param service The service.
     * @param resolvedServiceInfo The resolved service info.
     *
     * @return The map.
     */
    private fun serviceToJson(service: NsdServiceInfo, resolvedServiceInfo: ResolvedServiceInfo = ResolvedServiceInfo(service)): Map<String, Any?> {
        return mapOf(
                "service.name" to service.serviceName,
                "service.type" to service.serviceType,
                "service.port" to resolvedServiceInfo.port,
                "service.ip" to resolvedServiceInfo.ip,
                "service.attributes" to getAttributes(service)
        )
    }

    /**
     * Returns the service attributes (if supported by Android).
     *
     * @param service The service.
     *
     * @return The attributes.
     */
    private fun getAttributes(service: NsdServiceInfo): Map<String, String> {
        val result = HashMap<String, String>();
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.LOLLIPOP) {
            return result
        }

        for(entry in service.attributes.entries) {
            result[entry.key] = String(entry.value)
        }
        return result
    }
}
