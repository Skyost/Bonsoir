#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/standard_method_codec.h>

#include <queue>

#include "bonsoir_action.h"
#include "bonsoir_service.h"

using namespace flutter;

namespace bonsoir_windows {
    class BonsoirBroadcast : public BonsoirAction {
    public:
        BonsoirService service;

        BonsoirBroadcast(int _id, bool _print_logs, flutter::BinaryMessenger *_binary_messenger, std::function<void()>, BonsoirService _service);

        void start() override;

        void dispose() override;
    };

    void registerCallback(DWORD status, PVOID context, PDNS_SERVICE_INSTANCE instance);
} // namespace bonsoir_windows