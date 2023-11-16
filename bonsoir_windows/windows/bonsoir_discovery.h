#pragma once

#include "bonsoir_action.h"
#include "bonsoir_service.h"

namespace bonsoir_windows {
    class BonsoirDiscovery : public BonsoirAction {
    public:
        std::string type;
        std::list<BonsoirService> services;
        std::map<BonsoirService *, PDNS_SERVICE_CANCEL> resolving_services = std::map < BonsoirService *, PDNS_SERVICE_CANCEL
        >{};

        BonsoirDiscovery(int _id, bool _print_logs, flutter::BinaryMessenger *_binary_messenger, std::function<void()>, std::string type);

        void start() override;

        BonsoirService *findService(std::string service_name, std::string service_type);

        void resolveService(std::string service_name, std::string service_type);

        void dispose() override;
    };

    void browseCallback(DWORD status, PVOID context, PDNS_RECORD dnsRecord);

    void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance);
} // namespace bonsoir_windows
