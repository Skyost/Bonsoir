package fr.skyost.bonsoir

import java.util.*

/**
 * Sent to the event channel when there is no error.
 *
 * @param id The response id.
 * @param result The response result.
 */
data class SuccessObject(val id: String, val result: Any? = null) {
    /**
     * Converts the current instance into a map.
     *
     * @return The map.
     */
    fun toJson(): Map<String, Any> {
        val json: HashMap<String, Any> = HashMap()
        json["id"] = id
        if(result != null) {
            json["result"] = result
        }
        return json
    }
}
