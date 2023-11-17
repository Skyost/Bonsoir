#pragma once

#include "bonsoir_action.h"

namespace bonsoir_windows {
  class BonsoirDiscovery : public BonsoirAction {
   public:
    std::string type;
    std::list<BonsoirService> services;
    std::map<BonsoirService *, PDNS_SERVICE_CANCEL> resolvingServices = std::map<BonsoirService *, PDNS_SERVICE_CANCEL>{};

    BonsoirDiscovery(
      int _id,
      bool _printLogs,
      flutter::BinaryMessenger *_binaryMessenger,
      std::function<void()> onDispose,
      std::string type
    );

    void start() override;

    BonsoirService *findService(std::string serviceName, std::string serviceType);

    void resolveService(std::string serviceName, std::string serviceType);

    void dispose() override;
  };

  void browseCallback(DWORD status, PVOID context, PDNS_RECORD dnsRecord);

  void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance);
}  // namespace bonsoir_windows
