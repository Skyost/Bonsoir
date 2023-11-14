#pragma once

#include <unordered_map>
#include <optional>
#include "bonsoir_service.h"

namespace bonsoir_windows {
    BonsoirService::BonsoirService(std::string _name, std::string _type, int _port, std::optional<std::string> _host, std::unordered_map<std::string, std::string> _attributes) :
        name(_name),
        type(_type),
        port(_port),
        host(_host),
        attributes(_attributes)
    {}

    EncodableMap BonsoirService::to_encodable() {
        auto encodableAttributes = EncodableMap{};
        for (auto const& [key, value] : attributes) {
            encodableAttributes.insert({ EncodableValue(key), EncodableValue(value) });
        }
        return EncodableMap{
            { EncodableValue("service.name"), EncodableValue(name) },
            { EncodableValue("service.type"), EncodableValue(type) },
            { EncodableValue("service.port"), EncodableValue(port) },
            { EncodableValue("service.host"), host.has_value() ? EncodableValue(host.value()) : nullptr},
            { EncodableValue("service.attributes"), encodableAttributes },
        };
    }
    std::string BonsoirService::get_description() {
        std::string attributesString = "{";
        for (auto const& [key, value] : attributes) {
            attributesString += (key + "=" + value);
        }
        attributesString += "}";
        return "{" + name + ", " + type + ", " + std::to_string(port) + ", " + host.value_or("NULL") + ", " + attributesString + "}";
    }
}