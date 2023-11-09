package fr.skyost.bonsoir

import kotlin.collections.HashMap

/**
 * Sent to the event channel when there is no error.
 *
 * @param id The response id.
 * @param service The response service.
 */
data class SuccessObject(private val id: String, private val service: BonsoirService? = null) {
    /**
     * Converts the current instance into a map.
     *
     * @return The map.
     */
    fun toJson(): Map<String, Any> {
        val json: HashMap<String, Any> = HashMap()
        json["id"] = id
        if (service != null) {
            json["service"] = service.toJson()
        }
        return json
    }
}
