#pragma once

#include "bonsoir_service.h"

#include <iostream>

namespace bonsoir_windows {
  BonsoirService::BonsoirService(
    std::string _name,
    std::string _type,
    int _port,
    std::vector<std::string> _hostAddresses,
    std::optional<std::string> _hostname,
    std::map<std::string, std::string> _attributes
  )
    : name(_name), type(_type), port(_port), hostAddresses(_hostAddresses), hostname(_hostname), attributes(_attributes) {}

  EncodableMap BonsoirService::toEncodable() {
    auto encodableAttributes = EncodableMap{};
    for (auto const &[key, value] : attributes) {
      encodableAttributes.insert({EncodableValue(key), EncodableValue(value)});
    }
    EncodableMap result = EncodableMap{
      {EncodableValue("service.name"), EncodableValue(name)},
      {EncodableValue("service.type"), EncodableValue(type)},
      {EncodableValue("service.port"), EncodableValue(port)},
      {EncodableValue("service.attributes"), encodableAttributes},
    };
    if (!hostAddresses.empty()) {
      EncodableList encodedHostAddresses = EncodableList{};
      for (auto const &address : hostAddresses) {
        encodedHostAddresses.push_back(EncodableValue(address));
      }
      result.insert(
        {EncodableValue("service.hostAddresses"), EncodableValue(encodedHostAddresses)}
      );
    }
    if (hostname.has_value()) {
      result.insert(
        {EncodableValue("service.hostname"), EncodableValue(hostname.value())}
      );
    }
    return result;
  }

  std::string BonsoirService::getDescription() {
    std::string attributes_string = "{";
    if (!attributes.empty()) {
      for (auto const &[key, value] : attributes) {
        attributes_string += (key + "=" + value + ", ");
      }
      attributes_string = attributes_string.substr(0, attributes_string.length() - 2);
    }
    attributes_string += "}";
    std::string host_addresses_string = "[";
    if (!hostAddresses.empty()) {
      for (auto const &address : hostAddresses) {
        host_addresses_string += (address + ", ");
      }
      host_addresses_string = host_addresses_string.substr(0, host_addresses_string.length() - 2);
    }
    host_addresses_string += "]";
    return "{name=" + name + ", type=" + type + ", port=" + std::to_string(port) + ", hostAddresses=" + host_addresses_string + ", hostname=" + hostname.value_or("NULL") + ", attributes=" + attributes_string + "}";
  }

  bool BonsoirService::operator==(const BonsoirService &other) const {
    if (name != other.name || type != other.type || port != other.port || hostAddresses != other.hostAddresses || hostname != other.hostname) {
      return false;
    }
    return attributes.size() == other.attributes.size() && std::equal(attributes.begin(), attributes.end(), other.attributes.begin());
  }
}  // namespace bonsoir_windows
