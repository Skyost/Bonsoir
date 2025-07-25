// Generated file that contains some variables used by the platform channel.

#pragma once

#include <map>
#include <string>

namespace bonsoir_windows {
  class Generated {
    public:
      // Contains the broadcast messages.
      static const std::map<std::string, std::string> broadcastMessages;

      // broadcastStarted
      static const std::string broadcastStarted;
      // broadcastNameAlreadyExists
      static const std::string broadcastNameAlreadyExists;
      // broadcastStopped
      static const std::string broadcastStopped;
      // broadcastInitialized
      static const std::string broadcastInitialized;
      // broadcastError
      static const std::string broadcastError;


      // Contains the discovery messages.
      static const std::map<std::string, std::string> discoveryMessages;

      // discoveryStarted
      static const std::string discoveryStarted;
      // discoveryServiceFound
      static const std::string discoveryServiceFound;
      // discoveryServiceResolved
      static const std::string discoveryServiceResolved;
      // discoveryServiceUpdated
      static const std::string discoveryServiceUpdated;
      // discoveryServiceResolveFailed
      static const std::string discoveryServiceResolveFailed;
      // discoveryServiceLost
      static const std::string discoveryServiceLost;
      // discoveryStopped
      static const std::string discoveryStopped;
      // discoveryUndiscoveredServiceResolveFailed
      static const std::string discoveryUndiscoveredServiceResolveFailed;
      // discoveryTxtResolved
      static const std::string discoveryTxtResolved;
      // discoveryTxtResolveFailed
      static const std::string discoveryTxtResolveFailed;
      // discoveryError
      static const std::string discoveryError;

  };
}
