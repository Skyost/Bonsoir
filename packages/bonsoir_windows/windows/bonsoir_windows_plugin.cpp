#pragma once

#include "bonsoir_windows_plugin.h"

#include <flutter/standard_method_codec.h>

using namespace flutter;

namespace bonsoir_windows {
  void BonsoirWindowsPlugin::RegisterWithRegistrar(PluginRegistrarWindows *registrar) {
    auto messenger = registrar->messenger();
    auto channel = std::make_unique<MethodChannel<EncodableValue>>(
      messenger, "fr.skyost.bonsoir", &StandardMethodCodec::GetInstance()
    );
    auto plugin = std::make_unique<BonsoirWindowsPlugin>(messenger);
    channel->SetMethodCallHandler(
      [pluginPtr = plugin.get()](const auto &call, auto result) {
        pluginPtr->HandleMethodCall(call, std::move(result));
      }
    );
    registrar->AddPlugin(std::move(plugin));
  }

  BonsoirWindowsPlugin::BonsoirWindowsPlugin(BinaryMessenger *messenger)
    : messenger(messenger) {}

  BonsoirWindowsPlugin::~BonsoirWindowsPlugin() {
    broadcasts.clear();
    discoveries.clear();
  }

  void BonsoirWindowsPlugin::HandleMethodCall(const MethodCall<EncodableValue> &methodCall, std::unique_ptr<MethodResult<EncodableValue>> result) {
    const auto &method = methodCall.method_name();
    const auto *arguments = std::get_if<EncodableMap>(methodCall.arguments());
    const auto id = std::get<int>(arguments->find(EncodableValue("id"))->second);
    if (method.compare("broadcast.initialize") == 0) {
      std::map<std::string, std::string> attributes = std::map<std::string, std::string>();
      EncodableMap encodedAttributes = std::get<EncodableMap>(arguments->find(EncodableValue("service.attributes"))->second);
      for (auto const &[key, value] : encodedAttributes) {
        attributes.insert({std::get<std::string>(key), std::get<std::string>(value)});
      }
      auto hostValue = arguments->find(EncodableValue("service.host"));
      std::optional<std::string> host;
      if (hostValue == arguments->end() || hostValue->second.IsNull()) {
        host = std::optional<std::string>();
      } else {
        host = std::get<std::string>(hostValue->second);
      }
      std::unique_ptr<BonsoirService> servicePtr = std::make_unique<BonsoirService>(
        std::get<std::string>(arguments->find(EncodableValue("service.name"))->second),
        std::get<std::string>(arguments->find(EncodableValue("service.type"))->second),
        std::get<int>(arguments->find(EncodableValue("service.port"))->second),
        host,
        attributes
      );
      broadcasts[id] = std::make_unique<BonsoirBroadcast>(
        id,
        std::get<bool>(arguments->find(EncodableValue("printLogs"))->second),
        messenger,
        std::move(servicePtr)
      );
      result->Success(EncodableValue(true));
    } else if (method.compare("broadcast.start") == 0) {
      auto iterator = broadcasts.find(id);
      if (iterator == broadcasts.end()) {
        result->Success(EncodableValue(false));
        return;
      }
      iterator->second->start();
      result->Success(EncodableValue(true));
    } else if (method.compare("broadcast.stop") == 0) {
      auto iterator = broadcasts.find(id);
      if (iterator == broadcasts.end()) {
        result->Success(EncodableValue(false));
        return;
      }
      broadcasts.erase(id);
      // iterator->second->dispose();
      result->Success(EncodableValue(true));
    } else if (method.compare("discovery.initialize") == 0) {
      discoveries[id] = std::make_unique<BonsoirDiscovery>(
        id,
        std::get<bool>(arguments->find(EncodableValue("printLogs"))->second),
        messenger,
        std::get<std::string>(arguments->find(EncodableValue("type"))->second)
      );
      result->Success(EncodableValue(true));
    } else if (method.compare("discovery.start") == 0) {
      auto iterator = discoveries.find(id);
      if (iterator == discoveries.end()) {
        result->Success(EncodableValue(false));
        return;
      }
      iterator->second->start();
      result->Success(EncodableValue(true));
    } else if (method.compare("discovery.resolveService") == 0) {
      auto iterator = discoveries.find(id);
      if (iterator == discoveries.end()) {
        result->Success(EncodableValue(false));
        return;
      }
      iterator->second->resolveService(
        std::get<std::string>(arguments->find(EncodableValue("name"))->second),
        std::get<std::string>(arguments->find(EncodableValue("type"))->second)
      );
      result->Success(EncodableValue(true));
    } else if (method.compare("discovery.stop") == 0) {
      auto iterator = discoveries.find(id);
      if (iterator == discoveries.end()) {
        result->Success(EncodableValue(false));
        return;
      }
      discoveries.erase(id);
      // iterator->second->dispose();
      result->Success(EncodableValue(true));
    } else {
      result->NotImplemented();
    }
  }
}  // namespace bonsoir_windows
