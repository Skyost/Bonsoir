#pragma once

#include "bonsoir_action.h"

namespace bonsoir_windows {
  class BonsoirDiscovery : public BonsoirAction {
   public:
    std::string type;
    std::list<std::shared_ptr<BonsoirService>> services;
    std::map<std::shared_ptr<BonsoirService>, PDNS_SERVICE_CANCEL> resolvingServices = std::map<std::shared_ptr<BonsoirService>, PDNS_SERVICE_CANCEL>{};

    BonsoirDiscovery(
      int _id,
      bool _printLogs,
      flutter::BinaryMessenger *_binaryMessenger,
      std::string type
    );

    ~BonsoirDiscovery();

    void start() override;

    std::shared_ptr<BonsoirService> findService(std::string serviceName, std::string serviceType);

    void resolveService(std::string serviceName, std::string serviceType);

    void dispose() override;
  };

  void browseCallback(DWORD status, PVOID context, PDNS_RECORD dnsRecord);

  void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance);
}  // namespace bonsoir_windows
