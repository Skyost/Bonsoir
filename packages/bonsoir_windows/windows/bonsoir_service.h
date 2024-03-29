#pragma once

#include <flutter/encodable_value.h>

#include <optional>

using namespace flutter;

namespace bonsoir_windows {
  class BonsoirService {
   public:
    std::string name;
    std::string type;
    int port;
    std::optional<std::string> host;
    std::map<std::string, std::string> attributes;

    BonsoirService(
      std::string _name,
      std::string _type,
      int _port,
      std::optional<std::string> host,
      std::map<std::string, std::string> _attributes
    );

    EncodableMap toEncodable();

    std::string getDescription();

    bool operator==(const BonsoirService &other) const;
  };
}  // namespace bonsoir_windows