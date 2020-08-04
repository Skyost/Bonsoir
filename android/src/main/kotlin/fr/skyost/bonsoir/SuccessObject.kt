package fr.skyost.bonsoir

import java.util.*

data class SuccessObject(val id: String, val result: Any? = null) {
    fun toJson(): Map<String, Any> {
        val json: HashMap<String, Any> = HashMap()
        json["id"] = id
        if(result != null) {
            json["result"] = result
        }
        return json
    }
}
