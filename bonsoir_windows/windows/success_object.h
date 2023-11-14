#pragma once

#include <flutter/encodable_value.h>
#include <optional>

#include "bonsoir_service.h"

using namespace flutter;

namespace bonsoir_windows {
    class SuccessObject {
    public:
        std::string id;
        std::optional<BonsoirService> service;
        SuccessObject(std::string _id) : SuccessObject(_id, std::optional<BonsoirService>()) {};
        SuccessObject(std::string _id, std::optional<BonsoirService> _service);
        EncodableMap to_encodable();
    };
}