#pragma once

#include <flutter/encodable_value.h>

#include <optional>
#include <vector>

using namespace flutter;

namespace bonsoir_windows {
  class BonsoirService {
   public:
    std::string name;
    std::string type;
    int port;
    std::vector<std::string> hostAddresses;
    std::optional<std::string> hostname;
    std::map<std::string, std::string> attributes;

    BonsoirService(
      std::string _name,
      std::string _type,
      int _port,
      std::vector<std::string> hostAddresses,
      std::optional<std::string> hostname,
      std::map<std::string, std::string> _attributes
    );

    EncodableMap toEncodable();

    std::string getDescription();

    bool operator==(const BonsoirService &other) const;
  };
}  // namespace bonsoir_windows
