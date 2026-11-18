#pragma once

#include "bonsoir_action.h"

#include <set>

namespace bonsoir_windows {
  class BonsoirDiscovery;

  // One DnsServiceResolve call. Freed by whoever takes it out of pendingResolves.
  struct ResolveRequest {
    BonsoirDiscovery *discovery;
    DNS_SERVICE_CANCEL cancelHandle{};
    bool registered = false;  // DnsServiceResolve has returned DNS_REQUEST_PENDING.
    bool completed = false;   // The callback has run.
  };

  class BonsoirDiscovery : public BonsoirAction {
   public:
    std::string type;
    std::list<std::shared_ptr<BonsoirService>> services;
    std::set<ResolveRequest *> pendingResolves;
    // Never held across a DNS API call: cancelling waits for running callbacks, which take this mutex.
    std::mutex pendingResolvesMutex;

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

    void resolveService(std::string serviceName, std::string serviceType);

    void dispose() override;
  };

  void browseCallback(DWORD status, PVOID context, PDNS_RECORD dnsRecord);

  void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance);
}  // namespace bonsoir_windows
