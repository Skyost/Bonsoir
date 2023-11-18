#pragma once

#include "bonsoir_discovery.h"

#include "utilities.h"

using namespace flutter;

namespace bonsoir_windows {
  BonsoirDiscovery::BonsoirDiscovery(
    int _id,
    bool _printLogs,
    BinaryMessenger *_binaryMessenger,
    std::string _type
  )
    : BonsoirAction("discovery", _id, _printLogs, _binaryMessenger),
      type(_type) {}

  BonsoirDiscovery::~BonsoirDiscovery() {
    dispose();
  }

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
      BonsoirAction::start();
      onSuccess("discoveryStarted", "Bonsoir discovery started : " + type);
    } else {
      onError("Bonsoir has encountered an error during discovery : " + std::to_string(status), EncodableValue(std::to_string(status)));
      dispose();
    }
  }

  BonsoirService *BonsoirDiscovery::findService(std::string serviceName, std::string serviceType) {
    for (auto &found_service : this->services) {
      if (found_service.name == serviceName && found_service.type == serviceType) {
        return &found_service;
      }
    }
    return nullptr;
  }

  void BonsoirDiscovery::resolveService(std::string serviceName, std::string serviceType) {
    BonsoirService *service = findService(serviceName, serviceType);
    if (service == nullptr) {
      onError("Trying to resolve an undiscovered service : " + serviceName, EncodableValue(serviceName));
      return;
    }

    auto queryName = toUtf16(service->name + "." + service->type + ".local");
    DNS_SERVICE_RESOLVE_REQUEST resolveRequest{};
    DNS_SERVICE_CANCEL resolveCancelHandle{};
    resolveRequest.Version = DNS_QUERY_REQUEST_VERSION1;
    resolveRequest.InterfaceIndex = 0;
    resolveRequest.QueryName = const_cast<PWSTR>(queryName.c_str());
    resolveRequest.pResolveCompletionCallback = resolveCallback;
    resolveRequest.pQueryContext = this;
    DNS_STATUS status = DnsServiceResolve(&resolveRequest, &resolveCancelHandle);
    if (status == DNS_REQUEST_PENDING) {
      resolvingServices[service] = &resolveCancelHandle;
    } else {
      onError("Bonsoir has failed to resolve a service : " + std::to_string(status), EncodableValue(status));
    }
  }

  void BonsoirDiscovery::dispose() {
    BonsoirAction::stop();
    onSuccess("discoveryStopped", "Bonsoir discovery stopped : " + type);
    for (auto const &[key, value] : resolvingServices) {
      DnsServiceResolveCancel(value);
    }
    resolvingServices.clear();
    services.clear();
    DnsServiceBrowseCancel(&cancelHandle);
    BonsoirAction::dispose();
  }

  void browseCallback(DWORD status, PVOID context, PDNS_RECORD dnsRecord) {
    auto discovery = (BonsoirDiscovery *)context;
    if (status == ERROR_SUCCESS) {
      std::string nameHost = toUtf8(dnsRecord->Data.PTR.pNameHost);
      auto parts = split(nameHost, '.');
      std::string name = parts[0];
      std::string type = parts[1] + "." + parts[2];

      BonsoirService *service = discovery->findService(name, type);
      if (dnsRecord->dwTtl <= 0) {
        if (service) {
          discovery->onSuccess("discoveryServiceLost", "A Bonsoir service has been lost : " + service->getDescription(), service);
          discovery->services.remove(*service);
        }
        return;
      }
      if (!service) {
        BonsoirService newService =
          BonsoirService(name, type, 0, std::optional<std::string>(), std::map<std::string, std::string>());
        PDNS_RECORD txtRecord = dnsRecord;
        while (txtRecord != nullptr) {
          if (txtRecord->wType == DNS_TYPE_TEXT) {
            DNS_TXT_DATAW *pData = &txtRecord->Data.TXT;
            for (DWORD s = 0; s < pData->dwStringCount; s++) {
              std::string record = toUtf8(std::wstring(pData->pStringArray[s]));
              int splitIndex = static_cast<int>(record.find("="));
              if (splitIndex != std::string::npos) {
                newService.attributes.insert(
                  {record.substr(0, splitIndex), record.substr(splitIndex + 1, record.length())}
                );
              }
            }
          }
          txtRecord = txtRecord->pNext;
        }
        discovery->services.push_back(newService);
        discovery->onSuccess("discoveryServiceFound", "Bonsoir has found a service : " + newService.getDescription(), &newService);
      }
      DnsRecordListFree(dnsRecord, DnsFreeRecordList);
    } else if (status == ERROR_CANCELLED) {
      discovery->BonsoirAction::dispose();
    } else {
      discovery->onError("Bonsoir has encountered an error during discovery : " + std::to_string(status), EncodableValue(std::to_string(status)));
      discovery->dispose();
    }
  }

  void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance) {
    auto discovery = (BonsoirDiscovery *)context;
    BonsoirService *service = nullptr;
    std::string name = "";
    if (serviceInstance && serviceInstance->pszInstanceName) {
      std::string nameHost = toUtf8(serviceInstance->pszInstanceName);
      auto parts = split(nameHost, '.');
      name = parts[0];
      std::string type = parts[1] + "." + parts[2];
      service = discovery->findService(name, type);
    }
    if (status != ERROR_SUCCESS) {
      if (service) {
        discovery->onSuccess("discoveryServiceResolveFailed", "Bonsoir has failed to resolve a service : " + service->getDescription(), service);
      } else {
        discovery->onError("Bonsoir has failed to resolve a service : " + std::to_string(status), EncodableValue(std::to_string(status)));
      }
      if (serviceInstance) {
        DnsServiceFreeInstance(serviceInstance);
      }
      return;
    }
    if (!service) {
      discovery->onError("Trying to resolve an undiscovered service : " + name, EncodableValue(name));
      if (serviceInstance) {
        DnsServiceFreeInstance(serviceInstance);
      }
      return;
    }
    service->host = toUtf8(serviceInstance->pszHostName);
    service->port = serviceInstance->wPort;
    DnsServiceFreeInstance(serviceInstance);
    discovery->resolvingServices.erase(service);
    discovery->onSuccess("discoveryServiceResolved", "Bonsoir has resolved a service : " + service->getDescription(), service);
  }
}  // namespace bonsoir_windows
