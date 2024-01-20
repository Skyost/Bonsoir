package fr.skyost.bonsoir

import android.net.nsd.NsdServiceInfo
import org.json.JSONObject
import java.net.InetAddress

/**
 * Represents a Bonsoir service.
 *
 * @param name The service name.
 * @param type The service type.
 * @param port The service port.
 * @param host The service host.
 * @param attributes The service attributes.
 */
data class BonsoirService(
    var name: String,
    val type: String,
    var port: Int,
    var host: String?,
    var attributes: MutableMap<String, String>
) {
    /**
     * Creates a Bonsoir service from a NSD service.
     *
     * @param service The NSD service.
     */
    constructor(service: NsdServiceInfo) : this(
        service.serviceName,
        if (service.serviceType.endsWith(".")) service.serviceType.substring(0, service.serviceType.length - 1) else service.serviceType,
        service.port,
        service.host?.hostAddress,
        hashMapOf(),
    ) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            for (attribute in service.attributes.entries) {
                attributes[attribute.key] = if (attribute.value == null) "" else String(attribute.value)
            }
        }
    }

    /**
     * Converts the current instance into a map.
     *
     * @param prefix The keys prefix.
     *
     * @return The map.
     */
    fun toJson(prefix: String = "service."): Map<String, Any?> {
        return mapOf(
            "${prefix}name" to name,
            "${prefix}type" to type,
            "${prefix}port" to port,
            "${prefix}host" to host,
            "${prefix}attributes" to attributes,
        )
    }

    /**
     * Converts this instance to a NSD service.
     *
     * @return The NSD service.
     */
    fun toNsdService(): NsdServiceInfo {
        val service = NsdServiceInfo().apply {
            serviceName = name
            serviceType = type
            port = this@BonsoirService.port
        }
        if (host != null) {
            service.host = InetAddress.getByName(host)
        }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            for (entry in attributes.entries) {
                service.setAttribute(entry.key, entry.value)
            }
        }
        return service
    }

    override fun toString(): String {
        return JSONObject(toJson("")).toString()
    }
}