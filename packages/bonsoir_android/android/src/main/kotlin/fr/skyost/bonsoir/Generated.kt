package fr.skyost.bonsoir

/*
 * Generated file that contains some variables used by the platform channel.
 */ 
class Generated {
    companion object {
        /**
         * Contains the broadcast messages.
         */
        public final var broadcastMessages: Map<String, String> = mapOf("broadcastStarted" to "Bonsoir service broadcast started : %s.", "broadcastNameAlreadyExists" to "Trying to broadcast a service with a name that already exists : %s (old name was %s).", "broadcastStopped" to "Bonsoir service broadcast stopped : %s.", "broadcastInitialized" to "Bonsoir service broadcast initialized : %s.", "broadcastError" to "Bonsoir service failed to broadcast : %s (error : %s).")

        /**
         * broadcastStarted
         */
         public final const val broadcastStarted = "broadcastStarted";
        /**
         * broadcastNameAlreadyExists
         */
         public final const val broadcastNameAlreadyExists = "broadcastNameAlreadyExists";
        /**
         * broadcastStopped
         */
         public final const val broadcastStopped = "broadcastStopped";
        /**
         * broadcastInitialized
         */
         public final const val broadcastInitialized = "broadcastInitialized";
        /**
         * broadcastError
         */
         public final const val broadcastError = "broadcastError";


        /**
         * Contains the discovery messages.
         */
        public final var discoveryMessages: Map<String, String> = mapOf("discoveryStarted" to "Bonsoir discovery started : %s.", "discoveryServiceFound" to "Bonsoir has found a service : %s.", "discoveryServiceResolved" to "Bonsoir has resolved a service : %s.", "discoveryServiceResolveFailed" to "Bonsoir has failed to resolve a service : %s (error : %s).", "discoveryServiceLost" to "A Bonsoir service has been lost : %s.", "discoveryStopped" to "Bonsoir discovery stopped : %s.", "discoveryUndiscoveredServiceResolveFailed" to "Trying to resolve an undiscovered service : %s of type %s.", "discoveryTxtResolved" to "Bonsoir has found the attributes of a service : %s (new attributes are : %s).", "discoveryTxtResolveFailed" to "Bonsoir has failed to get the TXT record of a service : %s (error %s).", "discoveryError" to "Bonsoir has encountered an error during discovery : %s (error %s).")

        /**
         * discoveryStarted
         */
         public final const val discoveryStarted = "discoveryStarted";
        /**
         * discoveryServiceFound
         */
         public final const val discoveryServiceFound = "discoveryServiceFound";
        /**
         * discoveryServiceResolved
         */
         public final const val discoveryServiceResolved = "discoveryServiceResolved";
        /**
         * discoveryServiceResolveFailed
         */
         public final const val discoveryServiceResolveFailed = "discoveryServiceResolveFailed";
        /**
         * discoveryServiceLost
         */
         public final const val discoveryServiceLost = "discoveryServiceLost";
        /**
         * discoveryStopped
         */
         public final const val discoveryStopped = "discoveryStopped";
        /**
         * discoveryUndiscoveredServiceResolveFailed
         */
         public final const val discoveryUndiscoveredServiceResolveFailed = "discoveryUndiscoveredServiceResolveFailed";
        /**
         * discoveryTxtResolved
         */
         public final const val discoveryTxtResolved = "discoveryTxtResolved";
        /**
         * discoveryTxtResolveFailed
         */
         public final const val discoveryTxtResolveFailed = "discoveryTxtResolveFailed";
        /**
         * discoveryError
         */
         public final const val discoveryError = "discoveryError";

    }
}
