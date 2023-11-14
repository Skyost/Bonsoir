#pragma once

#include <flutter/encodable_value.h>
#include <unordered_map>
#include <optional>

using namespace flutter;

namespace bonsoir_windows {
    class BonsoirService {
    public:
        std::string name;
        std::string type;
        int port;
        std::optional<std::string> host;
        std::unordered_map<std::string, std::string> attributes;
        BonsoirService(std::string _name, std::string _type, int _port) : BonsoirService(_name, _type, _port, std::optional<std::string>(), std::unordered_map<std::string, std::string>()) {};
        BonsoirService(std::string _name, std::string _type, int _port, std::optional<std::string> host, std::unordered_map<std::string, std::string> _attributes);
        EncodableMap to_encodable();
        std::string get_description();
    };
}