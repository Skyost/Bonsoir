// Generated file that contains some variables used by the platform channel.

#pragma once

#include "generated.h"

namespace bonsoir_windows {
  const std::map<std::string, std::string> Generated::broadcastMessages = { { "broadcastStarted", "Bonsoir service broadcast started : %s." }, { "broadcastNameAlreadyExists", "Trying to broadcast a service with a name that already exists : %s (old name was %s)." }, { "broadcastStopped", "Bonsoir service broadcast stopped : %s." }, { "broadcastInitialized", "Bonsoir service broadcast initialized : %s." }, { "broadcastError", "Bonsoir service failed to broadcast : %s (error : %s)." } };

  const std::string Generated::broadcastStarted = "broadcastStarted";
  const std::string Generated::broadcastNameAlreadyExists = "broadcastNameAlreadyExists";
  const std::string Generated::broadcastStopped = "broadcastStopped";
  const std::string Generated::broadcastInitialized = "broadcastInitialized";
  const std::string Generated::broadcastError = "broadcastError";


  const std::map<std::string, std::string> Generated::discoveryMessages = { { "discoveryStarted", "Bonsoir discovery started : %s." }, { "discoveryServiceFound", "Bonsoir has found a service : %s." }, { "discoveryServiceResolved", "Bonsoir has resolved a service : %s." }, { "discoveryServiceUpdated", "A Bonsoir service has been updated : %s." }, { "discoveryServiceResolveFailed", "Bonsoir has failed to resolve a service : %s (error : %s)." }, { "discoveryServiceLost", "A Bonsoir service has been lost : %s." }, { "discoveryStopped", "Bonsoir discovery stopped : %s." }, { "discoveryUndiscoveredServiceResolveFailed", "Trying to resolve an undiscovered service : %s of type %s." }, { "discoveryTxtResolved", "Bonsoir has found the attributes of a service : %s (new attributes are : %s)." }, { "discoveryTxtResolveFailed", "Bonsoir has failed to get the TXT record of a service : %s (error %s)." }, { "discoveryError", "Bonsoir has encountered an error during discovery : %s (error %s)." } };

  const std::string Generated::discoveryStarted = "discoveryStarted";
  const std::string Generated::discoveryServiceFound = "discoveryServiceFound";
  const std::string Generated::discoveryServiceResolved = "discoveryServiceResolved";
  const std::string Generated::discoveryServiceUpdated = "discoveryServiceUpdated";
  const std::string Generated::discoveryServiceResolveFailed = "discoveryServiceResolveFailed";
  const std::string Generated::discoveryServiceLost = "discoveryServiceLost";
  const std::string Generated::discoveryStopped = "discoveryStopped";
  const std::string Generated::discoveryUndiscoveredServiceResolveFailed = "discoveryUndiscoveredServiceResolveFailed";
  const std::string Generated::discoveryTxtResolved = "discoveryTxtResolved";
  const std::string Generated::discoveryTxtResolveFailed = "discoveryTxtResolveFailed";
  const std::string Generated::discoveryError = "discoveryError";

}
