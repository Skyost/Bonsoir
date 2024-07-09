#pragma once

#include "bonsoir_broadcast.h"

#include "generated.h"
#include "utilities.h"

using namespace flutter;

namespace bonsoir_windows {
  BonsoirBroadcast::BonsoirBroadcast(
    int _id,
    bool _printLogs,
    BinaryMessenger *_binaryMessenger,
    std::unique_ptr<BonsoirService> _servicePtr
  )
    : BonsoirAction("broadcast", Generated::broadcastMessages, _id, _printLogs, _binaryMessenger),
      servicePtr(std::move(_servicePtr)) {}

  BonsoirBroadcast::~BonsoirBroadcast() {
    dispose();
  }

  void BonsoirBroadcast::start() {
    std::vector<PCWSTR> propertyKeys;
    std::vector<PCWSTR> propertyValues;
    for (const auto &[key, value] : servicePtr->attributes) {
      PCWSTR duplicatedKey = _wcsdup(toUtf16(key).c_str());
      PCWSTR duplicatedValue = _wcsdup(toUtf16(value).c_str());
      if (duplicatedKey != nullptr && duplicatedValue != nullptr) {
        propertyKeys.push_back(duplicatedKey);
        propertyValues.push_back(duplicatedValue);
      }
    }
    propertyKeys.push_back(nullptr);
    propertyValues.push_back(nullptr);

    std::wstring host = servicePtr->host.has_value() ? toUtf16(servicePtr->host.value()) : (getComputerName() + L".local");
    PDNS_SERVICE_INSTANCE serviceInstance = DnsServiceConstructInstance(
      toUtf16(servicePtr->name + "." + servicePtr->type + ".local").c_str(),
      host.c_str(),
      nullptr,
      nullptr,
      static_cast<WORD>(servicePtr->port),
      0,
      0,
      static_cast<DWORD>(propertyKeys.size() - 1),
      propertyKeys.data(),
      propertyValues.data()
    );
    registerRequest.Version = DNS_QUERY_REQUEST_VERSION1;
    registerRequest.InterfaceIndex = 0;
    registerRequest.pServiceInstance = serviceInstance;
    registerRequest.pRegisterCompletionCallback = registerCallback;
    registerRequest.pQueryContext = this;
    registerRequest.unicastEnabled = false;

    auto status = DnsServiceRegister(&registerRequest, &cancelHandle);
    if (status == DNS_REQUEST_PENDING) {
      BonsoirAction::start();
      log(logMessages.find(Generated::broadcastInitialized)->second, std::list<std::string>{servicePtr->getDescription()});
    } else {
      onError(EncodableValue(std::to_string(status)), std::list<std::string>{servicePtr->getDescription(), std::to_string(status)});
      dispose();
    }
  }

  void BonsoirBroadcast::dispose() {
    stop();
    if (eventChannel != nullptr) {
      onSuccess(Generated::broadcastStopped, servicePtr);
      DnsServiceDeRegister(&registerRequest, nullptr);
      DnsServiceRegisterCancel(&cancelHandle);
    }
    BonsoirAction::dispose();
  }

  void registerCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE instance) {
    auto broadcast = (BonsoirBroadcast *)context;
    if (!(broadcast->isRunning())) {
      return;
    }
    if (instance == nullptr || instance->pszInstanceName == nullptr) {
      return;
    }
    std::string name = std::get<0>(parseBonjourFqdn(toUtf8(instance->pszInstanceName)));
    if (name == "") {
      return;
    }
    std::shared_ptr<BonsoirService> servicePtr = broadcast->servicePtr;
    if (servicePtr->name != name) {
      std::string oldName = servicePtr->name;
      servicePtr->name = name;
      broadcast->onSuccess(Generated::broadcastNameAlreadyExists, servicePtr, std::list<std::string>{oldName});
    }
    if (status == ERROR_SUCCESS) {
      broadcast->onSuccess(Generated::broadcastStarted, servicePtr);
    } else {
      broadcast->onError(EncodableValue(std::to_string(status)), std::list<std::string>{servicePtr->getDescription(), std::to_string(status)});
      broadcast->dispose();
    }
  }
}  // namespace bonsoir_windows