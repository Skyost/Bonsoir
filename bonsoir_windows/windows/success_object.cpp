#pragma once

#include "success_object.h"

namespace bonsoir_windows {
    SuccessObject::SuccessObject(std::string _id, std::optional<BonsoirService> _service) :
        id(_id),
        service(_service)
    {}

    EncodableMap SuccessObject::to_encodable() {
        auto result = EncodableMap{
            { EncodableValue("id"), EncodableValue(id) }
        };
        if (service.has_value()) {
            result.insert({ EncodableValue("service"), service.value().to_encodable() });
        }
        return result;
    }
}
