#pragma once

#include "bonsoir_discovery.h"

#include "generated.h"
#include "utilities.h"

#include <optional>
#include <ws2tcpip.h>

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

  void BonsoirDiscovery::stop() {
    if (!isRunning()) {
      return;
    }
    BonsoirAction::stop();
    onSuccess(Generated::discoveryStopped, nullptr, std::list<std::string>{type});
    std::vector<ResolveRequest *> requests;
    {
      const std::lock_guard<std::mutex> lock(pendingResolvesMutex);
      for (auto iterator = pendingResolves.begin(); iterator != pendingResolves.end();) {
        // One still inside DnsServiceResolve is left to resolveService(), which sees the discovery stopped.
        if ((*iterator)->registered) {
          requests.push_back(*iterator);
          iterator = pendingResolves.erase(iterator);
        } else {
          ++iterator;
        }
      }
    }
    // Outside the lock: DnsServiceResolveCancel waits for a running callback, which takes the lock.
    for (ResolveRequest *request : requests) {
      DnsServiceResolveCancel(&request->cancelHandle);
      delete request;
    }
    services.clear();
    DnsServiceBrowseCancel(&cancelHandle);
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
    ResolveRequest *request = new ResolveRequest{this};
    resolveRequest.Version = DNS_QUERY_REQUEST_VERSION1;
    resolveRequest.InterfaceIndex = 0;
    resolveRequest.QueryName = const_cast<PWSTR>(queryName.c_str());
    resolveRequest.pResolveCompletionCallback = resolveCallback;
    resolveRequest.pQueryContext = request;
    {
      const std::lock_guard<std::mutex> lock(pendingResolvesMutex);
      pendingResolves.insert(request);
    }
    DNS_STATUS status = DnsServiceResolve(&resolveRequest, &request->cancelHandle);
    bool done = false;
    bool cancel = false;
    {
      const std::lock_guard<std::mutex> lock(pendingResolvesMutex);
      request->registered = status == DNS_REQUEST_PENDING;
      if (!request->registered || request->completed || !isRunning()) {
        // Failed at once, already answered, or stopped meanwhile: ours to free.
        pendingResolves.erase(request);
        done = true;
        cancel = request->registered && !request->completed;
      }
    }
    if (cancel) {
      DnsServiceResolveCancel(&request->cancelHandle);
    }
    if (done) {
      delete request;
    }
    if (status != DNS_REQUEST_PENDING) {
      onSuccess(Generated::discoveryServiceResolveFailed, servicePtr, std::list<std::string>{std::to_string(status)});
    }
  }

  void BonsoirDiscovery::dispose() {
    stop();
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
    std::shared_ptr<BonsoirService> newServicePtr = std::make_shared<BonsoirService>(
      name,
      type,
      0,
      std::vector<std::string>(),
      std::nullopt,
      std::map<std::string, std::string>()
    );
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
    if (servicePtr) {
      if (newServicePtr->hostAddresses.empty() && !servicePtr->hostAddresses.empty()) {
        newServicePtr->hostAddresses = servicePtr->hostAddresses;
      }
      if (!newServicePtr->hostname && servicePtr->hostname) {
        newServicePtr->hostname = servicePtr->hostname;
      }
      if (newServicePtr->port == 0 && servicePtr->port != 0) {
        newServicePtr->port = servicePtr->port;
      }
      discovery->services.remove(servicePtr);
      discovery->onSuccess(Generated::discoveryServiceUpdated, newServicePtr);
    } else {
      discovery->onSuccess(Generated::discoveryServiceFound, newServicePtr);
    }
    DnsRecordListFree(dnsRecord, DnsFreeRecordList);
  }

  std::vector<std::string> serviceInstanceIpAddresses(PDNS_SERVICE_INSTANCE serviceInstance) {
    std::vector<std::string> hostAddresses;
    char buffer[INET6_ADDRSTRLEN] = {};

    if (serviceInstance->ip4Address != nullptr) {
      IN_ADDR address{};
      address.S_un.S_addr = *serviceInstance->ip4Address;
      if (InetNtopA(AF_INET, &address, buffer, INET_ADDRSTRLEN) != nullptr) {
        hostAddresses.push_back(std::string(buffer));
      }
    }

    if (serviceInstance->ip6Address != nullptr) {
      if (InetNtopA(AF_INET6, serviceInstance->ip6Address, buffer, INET6_ADDRSTRLEN) != nullptr) {
        hostAddresses.push_back(std::string(buffer));
      }
    }

    return hostAddresses;
  }

  void resolveCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE serviceInstance) {
    auto request = (ResolveRequest *)context;
    BonsoirDiscovery *discovery = nullptr;
    bool owned = false;
    {
      // The request is alive here: stop() frees it only once DnsServiceResolveCancel has waited for this callback,
      // and resolveService() only once this callback has marked it completed.
      const std::lock_guard<std::mutex> lock(request->discovery->pendingResolvesMutex);
      discovery = request->discovery;
      if (discovery->pendingResolves.count(request) == 0) {
        discovery = nullptr;
      } else {
        request->completed = true;
        if (request->registered) {
          discovery->pendingResolves.erase(request);
          owned = true;
        }
      }
    }
    if (owned) {
      delete request;
    }
    if (discovery == nullptr) {
      if (serviceInstance) {
        DnsServiceFreeInstance(serviceInstance);
      }
      return;
    }
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
      servicePtr->hostAddresses = serviceInstanceIpAddresses(serviceInstance);
      if (serviceInstance->pszHostName != nullptr) {
        servicePtr->hostname = toUtf8(serviceInstance->pszHostName);
      }
      servicePtr->port = serviceInstance->wPort;
      servicePtr->attributes.clear();
      if (serviceInstance->dwPropertyCount > 0 && serviceInstance->keys != nullptr) {
        for (DWORD i = 0; i < serviceInstance->dwPropertyCount; i++) {
          if (serviceInstance->keys[i] != nullptr) {
            std::string key = toUtf8(serviceInstance->keys[i]);
            std::string value = "";
            if (serviceInstance->values != nullptr && serviceInstance->values[i] != nullptr) {
              value = toUtf8(serviceInstance->values[i]);
            }
            servicePtr->attributes[key] = value;
          }
        }
      }
      DnsServiceFreeInstance(serviceInstance);
    }
    discovery->onSuccess(Generated::discoveryServiceResolved, servicePtr);
  }
}  // namespace bonsoir_windows
