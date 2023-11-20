#pragma once

#include "bonsoir_broadcast.h"

#include "utilities.h"

using namespace flutter;

namespace bonsoir_windows {
  BonsoirBroadcast::BonsoirBroadcast(
    int _id,
    bool _printLogs,
    BinaryMessenger *_binaryMessenger,
    BonsoirService _service
  )
    : BonsoirAction("broadcast", _id, _printLogs, _binaryMessenger),
      service(_service) {}

  BonsoirBroadcast::~BonsoirBroadcast() {
    dispose();
  }

  void BonsoirBroadcast::start() {
    std::vector<PCWSTR> propertyKeys;
    std::vector<PCWSTR> propertyValues;
    for (const auto &[key, value] : service.attributes) {
      PCWSTR duplicatedKey = _wcsdup(toUtf16(key).c_str());
      PCWSTR duplicatedValue = _wcsdup(toUtf16(value).c_str());
      if (duplicatedKey != nullptr && duplicatedValue != nullptr) {
        propertyKeys.push_back(duplicatedKey);
        propertyValues.push_back(duplicatedValue);
      }
    }
    propertyKeys.push_back(nullptr);
    propertyValues.push_back(nullptr);

    PIP4_ADDRESS ipAddress = nullptr;
    if (service.host.has_value() && isValidIPv4(service.host.value())) {
      DWORD ip = std::stoul(service.host.value());
      ipAddress = &ip;
    }

    auto computerHost = (getComputerName() + L".local");
    PDNS_SERVICE_INSTANCE serviceInstance = DnsServiceConstructInstance(
      toUtf16(service.name + "." + service.type + ".local").c_str(),
      computerHost.c_str(),
      nullptr,
      nullptr,
      static_cast<WORD>(service.port),
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
      log("Bonsoir service broadcast initialized : " + service.getDescription());
    } else {
      onError("Bonsoir service failed to broadcast : " + service.getDescription() + ", error code : " + std::to_string(status), EncodableValue(std::to_string(status)));
      dispose();
    }
  }

  void BonsoirBroadcast::dispose() {
    stop();
    if (eventChannel != nullptr) {
      onSuccess("broadcastStopped", "Bonsoir service broadcast stopped : " + service.getDescription(), &service);
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
    std::string name = std::get<0>(parseBonjourFqdn(toUtf8(instance->pszInstanceName)));
    if (name == "") {
      return;
    }
    BonsoirService service = broadcast->service;
    if (service.name != name) {
      std::string oldName = service.name;
      service.name = name;
      broadcast->onSuccess("broadcastNameAlreadyExists", "Trying to broadcast a service with a name that already exists : " + service.getDescription() + "(old name was " + oldName + ")", &service);
    }
    if (status == ERROR_SUCCESS) {
      broadcast->onSuccess("broadcastStarted", "Bonsoir service broadcast started : " + service.getDescription(), &service);
    } else {
      broadcast->onError("Bonsoir service failed to broadcast : " + service.getDescription(), EncodableValue(std::to_string(status)));
      broadcast->dispose();
    }
  }
}  // namespace bonsoir_windows