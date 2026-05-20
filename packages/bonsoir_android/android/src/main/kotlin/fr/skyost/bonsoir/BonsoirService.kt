package fr.skyost.bonsoir

import android.annotation.SuppressLint
import android.net.nsd.NsdServiceInfo
import android.os.Build
import android.os.ext.SdkExtensions
import org.json.JSONObject
import java.net.InetAddress

private fun supportsHostnameCompat(): Boolean {
    return Build.VERSION.SDK_INT >= 36 ||
            (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && SdkExtensions.getExtensionVersion(Build.VERSION_CODES.TIRAMISU) >= 17)
}

@SuppressLint("NewApi")
private fun NsdServiceInfo.getHostnameCompat(): String? {
    return if (supportsHostnameCompat()) {
        return if (hostname == null || hostname!!.endsWith(".local") || hostname!!.endsWith(".local.")) hostname else "${hostname!!}.local"
    } else {
        null
    }
}

@SuppressLint("NewApi")
private fun NsdServiceInfo.getHostAddressesCompat(): List<String> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        hostAddresses.map { it.hostAddress }
    } else {
        listOfNotNull(host?.hostAddress)
    }
}

/**
 * Represents a Bonsoir service.
 *
 * @param name The service name.
 * @param type The service type.
 * @param port The service port.
 * @param hostAddresses The service host addresses.
 * @param hostname The service mDNS hostname.
 * @param attributes The service attributes.
 */
data class BonsoirService(
    var name: String,
    val type: String,
    var port: Int,
    var hostAddresses: List<String>,
    var hostname: String?,
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
        service.getHostAddressesCompat(),
        service.getHostnameCompat(),
        hashMapOf(),
    ) {
        for (attribute in service.attributes.entries) {
            attributes[attribute.key] = if (attribute.value == null) "" else String(attribute.value)
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
            "${prefix}hostAddresses" to hostAddresses,
            "${prefix}hostname" to hostname,
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
        val resolvedHostAddresses = if (hostAddresses.isNotEmpty()) hostAddresses else listOfNotNull(hostname)
        if (resolvedHostAddresses.isNotEmpty()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                service.hostAddresses = resolvedHostAddresses.map { InetAddress.getByName(it) }
            } else {
                service.host = InetAddress.getByName(resolvedHostAddresses.first())
            }
        }
        for (entry in attributes.entries) {
            service.setAttribute(entry.key, entry.value)
        }
        return service
    }

    override fun toString(): String {
        return JSONObject(toJson("")).toString()
    }
}
