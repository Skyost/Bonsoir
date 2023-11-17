#pragma once

#include "bonsoir_windows_plugin.h"

#include <flutter/method_codec.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <sstream>

#include "bonsoir_broadcast.h"
#include "bonsoir_discovery.h"
#include "bonsoir_service.h"

using namespace flutter;

namespace bonsoir_windows {
  void BonsoirWindowsPlugin::RegisterWithRegistrar(PluginRegistrarWindows *registrar) {
    auto messenger = registrar->messenger();
    auto channel = std::make_unique<MethodChannel<EncodableValue>>(
      messenger, "fr.skyost.bonsoir", &StandardMethodCodec::GetInstance()
    );
    auto plugin = std::make_unique<BonsoirWindowsPlugin>(messenger);
    plugin.get()->messenger = messenger;

    channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      }
    );

    registrar->AddPlugin(std::move(plugin));
  }

  BonsoirWindowsPlugin::~BonsoirWindowsPlugin() {
    for (auto &[id, broadcast] : broadcasts) {
      broadcast->dispose();
    }
    broadcasts.clear();
    for (auto &[id, discovery] : discoveries) {
      discovery->dispose();
    }
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
      std::optional<std::string> host = hostValue == arguments->end() ? std::optional<std::string>() : std::get<std::string>(hostValue->second);
      BonsoirService service = BonsoirService(
        std::get<std::string>(arguments->find(EncodableValue("service.name"))->second),
        std::get<std::string>(arguments->find(EncodableValue("service.type"))->second),
        std::get<int>(arguments->find(EncodableValue("service.port"))->second),
        host,
        attributes
      );
      broadcasts[id] = std::unique_ptr<BonsoirBroadcast>(new BonsoirBroadcast(
        id,
        std::get<bool>(arguments->find(EncodableValue("printLogs"))->second),
        messenger,
        [this, id]() {
              broadcasts.erase(id);
        },
        service
      ));
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
      iterator->second->dispose();
      result->Success(EncodableValue(true));
    } else if (method.compare("discovery.initialize") == 0) {
      discoveries[id] = std::unique_ptr<BonsoirDiscovery>(new BonsoirDiscovery(
        id,
        std::get<bool>(arguments->find(EncodableValue("printLogs"))->second),
        messenger,
        [this, id]() { discoveries.erase(id); },
        std::get<std::string>(arguments->find(EncodableValue("type"))->second)
      ));
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
      iterator->second->dispose();
      result->Success(EncodableValue(true));
    } else {
      result->NotImplemented();
    }
  }
}  // namespace bonsoir_windows
