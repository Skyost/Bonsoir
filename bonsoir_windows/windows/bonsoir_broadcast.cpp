#pragma once

#include "winsock.h"

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/method_codec.h>
#include <iostream>

#include "include/dns_sd.h"
#include "bonsoir_broadcast.h"
#include "bonsoir_windows_plugin.h"

using namespace flutter;

namespace bonsoir_windows {
    BonsoirBroadcast::BonsoirBroadcast(int _id, bool _print_logs, BinaryMessenger* _binary_messenger, std::function<void()> _on_dispose, BonsoirService _service):
        BonsoirAction("broadcast", _id, _print_logs, _binary_messenger, _on_dispose),
        service(_service)
    {}

    void BonsoirBroadcast::start() {
        DNSServiceErrorType error = DNSServiceRegister(
            &sdRef,
            0,
            0,
            service.name.c_str(),
            service.type.c_str(),
            "local.",
            service.host.has_value() ? service.host.value().c_str() : nullptr,
            htons((unsigned short)service.port),
            0,
            nullptr,
            registerCallback,
            this
        );
        if (error == kDNSServiceErr_NoError) {
            if (print_logs) {
                log("Bonsoir service broadcast initialized : " + service.get_description());
            }
            DNSServiceProcessResult(sdRef);
        }
        else {
            on_event(ErrorObject("Bonsoir service failed to broadcast : " + service.get_description() + ", error code : " + std::to_string(error), EncodableValue(error)));
            dispose();
        }
    }

    void BonsoirBroadcast::dispose() {
        if (print_logs) {
            log("Bonsoir service broadcast stopped : " + service.get_description());
        }
        BonsoirAction::dispose();
    }

    void registerCallback(
        DNSServiceRef sdRef,
        DNSServiceFlags flags,
        DNSServiceErrorType errorCode,
        const char* name,
        const char* regtype,
        const char* domain,
        void* context
    ) {
        auto broadcast = (BonsoirBroadcast*)context;
        auto service = broadcast->service;
        if (errorCode == kDNSServiceErr_NoError) {
            broadcast->on_event(SuccessObject("broadcastStarted", "Bonsoir service broadcast started : " + service.get_description(), service));
        }
        else {
            broadcast->on_event(ErrorObject("Bonsoir service failed to broadcast : " + service.get_description(), EncodableValue(errorCode)));
            broadcast->dispose();
        }
    }
}