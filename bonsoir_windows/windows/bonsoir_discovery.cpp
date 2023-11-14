#pragma once

#include <winsock.h>

#include "include/dns_sd.h"
#include "bonsoir_action.h"
#include "bonsoir_discovery.h"

namespace bonsoir_windows {
    BonsoirDiscovery::BonsoirDiscovery(int _id, bool _print_logs, flutter::BinaryMessenger* _binary_messenger, std::function<void()> _on_dispose, std::string _type) :
        BonsoirAction("discovery", _id, _print_logs, _binary_messenger, _on_dispose),
        type(_type)
    {}

    void BonsoirDiscovery::start() {
        DNSServiceErrorType error = DNSServiceBrowse(
            &sdRef,
            0,
            0,
            type.c_str(),
            "local.",
            browseCallback,
            this
        );
        if (error == kDNSServiceErr_NoError) {
            on_event(SuccessObject("discoveryStarted", "Bonsoir discovery started : " + type));
            DNSServiceProcessResult(sdRef);
        }
        else {
            on_event(ErrorObject("Bonsoir has encountered an error during discovery : " + std::to_string(error), EncodableValue(error)));
            dispose();
        }
    }

    void BonsoirDiscovery::resolveService(std::string service_name, std::string service_type) {
        BonsoirService* service = nullptr;
        for (auto& found_service : services) {
            if (found_service.name == service_name && found_service.type == service_type) {
                service = &found_service;
                break;
            }
        }
        DNSServiceRef resolveRef = nullptr;
        DNSServiceErrorType error = DNSServiceResolve(
            &resolveRef,
            0,
            0,
            service_name.c_str(),
            service_type.c_str(),
            "local.",
            resolveCallback,
            this
        );
        if (error == kDNSServiceErr_NoError) {
            resolving_services.insert({ resolveRef, service });
            DNSServiceProcessResult(sdRef);
        }
        else {
            on_event(ErrorObject("Bonsoir has failed to resolve a service : " + std::to_string(error), EncodableValue(error)));
        }
    }

    void BonsoirDiscovery::stopResolution(DNSServiceRef resolveRef, bool remove) {
        if (remove) {
            resolving_services.erase(resolveRef);
        }
        DNSServiceRefDeallocate(resolveRef);
    }

    void BonsoirDiscovery::dispose() {
        if (print_logs) {
            log("Bonsoir discovery stopped : " + type);
        }
        for (auto const& [key, value] : resolving_services) {
            stopResolution(key, false);
        }
        resolving_services.clear();
        services.clear();
        BonsoirAction::dispose();
    }

    void browseCallback(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char* serviceName, const char* regtype, const char* replyDomain, void* context) {
        auto discovery = (BonsoirDiscovery*)context;
        std::string type = discovery->type;
        if (errorCode == kDNSServiceErr_NoError) {
            bool add = (flags & kDNSServiceFlagsAdd) != 0;
            if (add) {
                BonsoirService service = BonsoirService(serviceName, regtype, 0, std::optional<std::string>(), std::map<std::string, std::string>());
                // TODO: Handle TXT records
                discovery->services.push_back(service);
                discovery->on_event(SuccessObject("discoveryServiceFound", "Bonsoir has found a service : " + service.get_description(), service));
                DNSServiceRefDeallocate(sdRef);
            }
            else {
                BonsoirService* service = nullptr;
                for (auto& found_service : discovery->services) {
                    if (found_service.name == serviceName && found_service.type == regtype) {
                        service = &found_service;
                        break;
                    }
                }
                if (service != nullptr) {
                    discovery->services.remove(*service);
                    discovery->on_event(SuccessObject("discoveryServiceLost", "A Bonsoir service has been lost : " + service->get_description(), *service));
                }
            }
        }
        else {
            discovery->on_event(ErrorObject("Bonsoir has encountered an error during discovery : " + std::to_string(errorCode), EncodableValue(errorCode)));
        }
    }

    void resolveCallback(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char* fullname, const char* hosttarget, uint16_t port, uint16_t txtLen, const unsigned char* txtRecord, void* context) {
        auto discovery = (BonsoirDiscovery*)context;
        auto service = discovery->resolving_services.at(sdRef);
        if (errorCode == kDNSServiceErr_NoError) {
            if (hosttarget != NULL) {
                service->host = hosttarget;
            }
            service->port = ntohs(port);
            discovery->on_event(SuccessObject("discoveryServiceResolved", "Bonsoir has resolved a service : " + service->get_description(), *service));
        }
        else {
            discovery->on_event(SuccessObject("discoveryServiceResolveFailed", "Bonsoir has failed to resolve a service : " + service->get_description(), *service));
        }
        discovery->stopResolution(sdRef, sdRef != nullptr);
    }
}
