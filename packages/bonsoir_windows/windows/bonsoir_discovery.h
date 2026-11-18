#pragma once

#include "bonsoir_action.h"

namespace bonsoir_windows {
  class BonsoirDiscovery : public BonsoirAction {
   public:
    std::string type;
    // Services are never modified once listed: queued events serialize them on the platform thread.
    std::list<std::shared_ptr<BonsoirService>> services;
    std::mutex servicesMutex;

    BonsoirDiscovery(
      int _id,
      bool _printLogs,
      flutter::BinaryMessenger *_binaryMessenger,
      std::string type
    );

    ~BonsoirDiscovery();

    void start() override;

    void stop() override;

    std::shared_ptr<BonsoirService> findService(std::string serviceName, std::string serviceType);

    // Puts newService where oldService was; false if oldService is no longer listed.
    bool replaceService(std::shared_ptr<BonsoirService> oldService, std::shared_ptr<BonsoirService> newService);

    void resolveService(std::string serviceName, std::string serviceType);

    void dispose() override;
  };

  void browseCallback(DWORD status, PVOID context, PDNS_RECORD dnsRecord);

  void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance);
}  // namespace bonsoir_windows
