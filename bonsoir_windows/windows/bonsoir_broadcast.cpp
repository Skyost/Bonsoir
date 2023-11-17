#pragma once

#include "bonsoir_broadcast.h"

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/method_codec.h>
#include <windows.h>

#include "utilities.h"

using namespace flutter;

namespace bonsoir_windows {
  BonsoirBroadcast::BonsoirBroadcast(
    int _id,
    bool _printLogs,
    BinaryMessenger *_binaryMessenger,
    std::function<void()> _onDispose,
    BonsoirService _service
  )
    : BonsoirAction("broadcast", _id, _printLogs, _binaryMessenger, _onDispose),
      service(_service) {}

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
    BonsoirAction::stop();
    DnsServiceDeRegister(&registerRequest, nullptr);
    DnsServiceRegisterCancel(&cancelHandle);
  }

  void registerCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE instance) {
    auto broadcast = (BonsoirBroadcast *)context;
    if (!(broadcast->isRunning())) {
      broadcast->log("Bonsoir service broadcast stopped : " + broadcast->service.getDescription());
      broadcast->BonsoirAction::dispose();
      return;
    }
    BonsoirService service = broadcast->service;
    if (status == ERROR_SUCCESS) {
      broadcast->onSuccess("broadcastStarted", "Bonsoir service broadcast started : " + service.getDescription(), &service);
    } else {
      broadcast->onError("Bonsoir service failed to broadcast : " + service.getDescription(), EncodableValue(std::to_string(status)));
      broadcast->dispose();
    }
  }
}  // namespace bonsoir_windows