#pragma once

#include "bonsoir_discovery.h"

#include "generated.h"
#include "utilities.h"

using namespace flutter;

namespace bonsoir_windows {
  BonsoirDiscovery::BonsoirDiscovery(
    int _id,
    bool _printLogs,
    BinaryMessenger *_binaryMessenger,
    std::string _type
  )
    : BonsoirAction("discovery", Generated::discoveryMessages, _id, _printLogs, _binaryMessenger),
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
      onSuccess(Generated::discoveryStarted, nullptr, std::list<std::string>{type});
    } else {
      onError(EncodableValue(std::to_string(status)), std::list<std::string>{std::to_string(status)});
      dispose();
    }
  }

  std::shared_ptr<BonsoirService> BonsoirDiscovery::findService(std::string serviceName, std::string serviceType) {
    for (auto &found_service : this->services) {
      if (found_service->name == serviceName && found_service->type == serviceType) {
        return found_service;
      }
    }
    return nullptr;
  }

  void BonsoirDiscovery::resolveService(std::string serviceName, std::string serviceType) {
    std::shared_ptr<BonsoirService> servicePtr = findService(serviceName, serviceType);
    if (servicePtr == nullptr) {
      onError(nullptr, std::list<std::string>{serviceName, serviceType}, logMessages.find(Generated::discoveryUndiscoveredServiceResolveFailed)->second);
      return;
    }

    auto queryName = toUtf16(servicePtr->name + "." + servicePtr->type + ".local");
    DNS_SERVICE_RESOLVE_REQUEST resolveRequest{};
    DNS_SERVICE_CANCEL resolveCancelHandle{};
    resolveRequest.Version = DNS_QUERY_REQUEST_VERSION1;
    resolveRequest.InterfaceIndex = 0;
    resolveRequest.QueryName = const_cast<PWSTR>(queryName.c_str());
    resolveRequest.pResolveCompletionCallback = resolveCallback;
    resolveRequest.pQueryContext = this;
    DNS_STATUS status = DnsServiceResolve(&resolveRequest, &resolveCancelHandle);
    if (status == DNS_REQUEST_PENDING) {
      resolvingServices[servicePtr] = &resolveCancelHandle;
    } else {
      onSuccess(Generated::discoveryServiceResolveFailed, servicePtr, std::list<std::string>{std::to_string(status)});
    }
  }

  void BonsoirDiscovery::dispose() {
    BonsoirAction::stop();
    onSuccess(Generated::discoveryStopped, nullptr, std::list<std::string>{type});
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
    if (status == ERROR_CANCELLED) {
      if (discovery->isRunning()) {
        discovery->BonsoirAction::dispose();
      }
      return;
    }

    if (status != ERROR_SUCCESS) {
      discovery->onError(EncodableValue(std::to_string(status)), std::list<std::string>{std::to_string(status)});
      discovery->dispose();
      return;
    }

    auto serviceData = parseBonjourFqdn(toUtf8(dnsRecord->Data.PTR.pNameHost));
    std::string name = std::get<0>(serviceData);
    std::string type = std::get<1>(serviceData);

    std::shared_ptr<BonsoirService> servicePtr = discovery->findService(name, type);
    if (dnsRecord->dwTtl <= 0) {
      if (servicePtr) {
        discovery->onSuccess(Generated::discoveryServiceLost, servicePtr);
        discovery->services.remove(servicePtr);
      }
      return;
    }
    if (!servicePtr) {
      std::shared_ptr<BonsoirService> newServicePtr = std::make_shared<BonsoirService>(name, type, 0, std::nullopt, std::map<std::string, std::string>());
      PDNS_RECORD txtRecord = dnsRecord;
      while (txtRecord != nullptr) {
        if (txtRecord->wType == DNS_TYPE_TEXT) {
          DNS_TXT_DATAW *pData = &txtRecord->Data.TXT;
          for (DWORD s = 0; s < pData->dwStringCount; s++) {
            std::string record = toUtf8(std::wstring(pData->pStringArray[s]));
            std::string key = record;
            std::string value = "";
            int splitIndex = static_cast<int>(record.find("="));
            if (splitIndex != std::string::npos) {
              key = record.substr(0, splitIndex);
              value = record.substr(splitIndex + 1, record.length());
            }
            if (key.rfind("=", 0) == std::string::npos && newServicePtr->attributes.find(key) == newServicePtr->attributes.end()) {
              newServicePtr->attributes.insert({key, value});
            }
          }
        }
        txtRecord = txtRecord->pNext;
      }
      discovery->services.push_back(newServicePtr);
      discovery->onSuccess(Generated::discoveryServiceFound, newServicePtr);
    }
    DnsRecordListFree(dnsRecord, DnsFreeRecordList);
  }

  void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance) {
    auto discovery = (BonsoirDiscovery *)context;
    std::shared_ptr<BonsoirService> servicePtr = nullptr;
    std::tuple<std::string, std::string> serviceData = {"NULL", "NULL"};
    if (serviceInstance && serviceInstance->pszInstanceName) {
      std::string nameHost = toUtf8(serviceInstance->pszInstanceName);
      serviceData = parseBonjourFqdn(nameHost);
      servicePtr = discovery->findService(std::get<0>(serviceData), std::get<1>(serviceData));
    }
    if (status != ERROR_SUCCESS) {
      if (servicePtr) {
        discovery->onSuccess(Generated::discoveryServiceResolveFailed, servicePtr, std::list<std::string>{std::to_string(status)});
      } else {
        discovery->onError(EncodableValue(std::to_string(status)), std::list<std::string>{"NULL", std::to_string(status)}, discovery->logMessages.find(Generated::discoveryServiceResolveFailed)->second);
      }
      if (serviceInstance) {
        DnsServiceFreeInstance(serviceInstance);
      }
      return;
    }
    if (!servicePtr) {
      discovery->onError(nullptr, std::list<std::string>{std::get<0>(serviceData), std::get<1>(serviceData)}, discovery->logMessages.find(Generated::discoveryServiceResolveFailed)->second);
      if (serviceInstance) {
        DnsServiceFreeInstance(serviceInstance);
      }
      return;
    }
    if (serviceInstance) {
      servicePtr->host = toUtf8(serviceInstance->pszHostName);
      servicePtr->port = serviceInstance->wPort;
      DnsServiceFreeInstance(serviceInstance);
    }
    discovery->resolvingServices.erase(servicePtr);
    discovery->onSuccess(Generated::discoveryServiceResolved, servicePtr);
  }
}  // namespace bonsoir_windows
