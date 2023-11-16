#pragma once

#include <windows.h>

#include "bonsoir_discovery.h"
#include "utilities.h"

using namespace flutter;

namespace bonsoir_windows {
    BonsoirDiscovery::BonsoirDiscovery(int _id, bool _print_logs, BinaryMessenger *_binary_messenger, std::function<void()> _on_dispose, std::string _type) : BonsoirAction("discovery", _id,
                                                                                                                                                                            _print_logs,
                                                                                                                                                                            _binary_messenger,
                                                                                                                                                                            _on_dispose), type(_type) {}

    void BonsoirDiscovery::start() {
        auto queryName = toUtf16(type + ".local");
        DNS_SERVICE_BROWSE_REQUEST browseRequest{};
        browseRequest.Version = DNS_QUERY_REQUEST_VERSION1;
        browseRequest.InterfaceIndex = 0;
        browseRequest.QueryName = queryName.c_str();
        browseRequest.pBrowseCallback = browseCallback;
        browseRequest.pQueryContext = this;
        DNS_STATUS status = DnsServiceBrowse(&browseRequest, &cancelHandle);
        if (status == DNS_REQUEST_PENDING) {
            on_success("discoveryStarted", "Bonsoir discovery started : " + type);
        } else {
            on_error("Bonsoir has encountered an error during discovery : " + std::to_string(status), EncodableValue(std::to_string(status)));
            dispose();
        }
    }

    BonsoirService *BonsoirDiscovery::findService(std::string service_name, std::string service_type) {
        for (auto &found_service: services) {
            if (found_service.name == service_name && found_service.type == service_type) {
                return &found_service;
            }
        }
        return nullptr;
    }

    void BonsoirDiscovery::resolveService(std::string service_name, std::string service_type) {
        BonsoirService *service = findService(service_name, service_type);
        if (service == nullptr) {
            on_error("Trying to resolve an undiscovered service : " + service_name, EncodableValue(service_name));
            return;
        }

        auto queryName = toUtf16(service_name + "." + service_type + ".local");
        DNS_SERVICE_RESOLVE_REQUEST resolveRequest{};
        DNS_SERVICE_CANCEL resolveCancelHandle{};
        resolveRequest.Version = DNS_QUERY_REQUEST_VERSION1;
        resolveRequest.InterfaceIndex = 0;
        resolveRequest.QueryName = const_cast<PWSTR>(queryName.c_str());
        resolveRequest.pResolveCompletionCallback = resolveCallback;
        resolveRequest.pQueryContext = this;
        DNS_STATUS status = DnsServiceResolve(&resolveRequest, &resolveCancelHandle);
        if (status == DNS_REQUEST_PENDING) {
            resolving_services[service] = &resolveCancelHandle;
        } else {
            on_error("Bonsoir has failed to resolve a service : " + std::to_string(status), EncodableValue(status));
        }
    }

    void BonsoirDiscovery::dispose() {
        for (auto const &[key, value]: resolving_services) {
            DnsServiceResolveCancel(value);
        }
        resolving_services.clear();
        services.clear();
        DnsServiceBrowseCancel(&cancelHandle);
        log("Bonsoir discovery stopped : " + type);
        BonsoirAction::dispose();
    }

    void browseCallback(DWORD status, PVOID context, PDNS_RECORD dnsRecord) {
        auto discovery = (BonsoirDiscovery *) context;
        std::string nameHost = toUtf8(dnsRecord->Data.PTR.pNameHost);
        auto parts = split(nameHost, '.');
        std::string name = parts[0];
        std::string type = parts[1] + "." + parts[2];

        BonsoirService *service = discovery->findService(name, type);
        if (dnsRecord->dwTtl <= 0 && service) {
            discovery->services.remove(*service);
            discovery->on_success("discoveryServiceLost", "A Bonsoir service has been lost : " + service->get_description(), service);
        } else if (!service) {
            BonsoirService newService = BonsoirService(name, type, 0, std::optional<std::string>(), std::map<std::string, std::string>());
            PDNS_RECORD txtRecord = dnsRecord;
            while (txtRecord != nullptr) {
                if (txtRecord->wType == DNS_TYPE_TEXT) {
                    DNS_TXT_DATAW *pData = &txtRecord->Data.TXT;
                    for (DWORD s = 0; s < pData->dwStringCount; s++) {
                        std::string record = toUtf8(std::wstring(pData->pStringArray[s]));
                        int splitIndex = static_cast<int>(record.find("="));
                        if (splitIndex != std::string::npos) {
                            newService.attributes.insert({record.substr(0, splitIndex), record.substr(splitIndex + 1, record.length())});
                        }
                    }
                }
                txtRecord = txtRecord->pNext;
            }
            discovery->services.push_back(newService);
            discovery->on_success("discoveryServiceFound", "Bonsoir has found a service : " + newService.get_description(), &newService);
        }
        DnsRecordListFree(dnsRecord, DnsFreeRecordList);
    }

    void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance) {
        auto discovery = (BonsoirDiscovery *) context;
        BonsoirService *service = nullptr;
        std::string name = "";
        if (serviceInstance && serviceInstance->pszInstanceName) {
            std::string nameHost = toUtf8(serviceInstance->pszInstanceName);
            auto parts = split(nameHost, '.');
            name = parts[0];
            std::string type = parts[1] + "." + parts[2];
            service = discovery->findService(name, type);
        }
        std::cout << status << std::endl;
        if (status != ERROR_SUCCESS) {
            if (service) {
                discovery->on_success("discoveryServiceResolveFailed", "Bonsoir has failed to resolve a service : " + service->get_description(), service);
            } else {
                discovery->on_error("Bonsoir has failed to resolve a service : " + std::to_string(status), EncodableValue(std::to_string(status)));
            }
            DnsServiceFreeInstance(serviceInstance);
            return;
        }
        if (!service) {
            discovery->on_error("Trying to resolve an undiscovered service : " + name, EncodableValue(name));
            DnsServiceFreeInstance(serviceInstance);
            return;
        }
        service->host = toUtf8(serviceInstance->pszHostName);
        service->port = serviceInstance->wPort;
        DnsServiceFreeInstance(serviceInstance);
        discovery->resolving_services.erase(service);
        discovery->on_success("discoveryServiceResolved", "Bonsoir has resolved a service : " + service->get_description(), service);
    }
} // namespace bonsoir_windows
