#pragma once

#include "winsock.h"

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_codec.h>

#include "include/dns_sd.h"
#include "bonsoir_broadcast.h"
#include "success_object.h"

using namespace flutter;

namespace bonsoir_windows {
    BonsoirBroadcast::BonsoirBroadcast(int _id, bool _print_logs, BonsoirService _service, BinaryMessenger* _binaryMessenger, std::function<void()> _on_dispose):
        sdRef(nullptr),
        id(_id),
        print_logs(_print_logs),
        service(_service),
        event_channel(std::make_shared<EventChannel<EncodableValue>>(_binaryMessenger, "fr.skyost.bonsoir.broadcast." + std::to_string(id), &StandardMethodCodec::GetInstance())),
        on_dispose(_on_dispose)
    {
        event_channel->SetStreamHandler(
            std::make_unique<StreamHandlerFunctions<EncodableValue>>(
                [this](const EncodableValue* arguments, std::unique_ptr<EventSink<EncodableValue>>&& events)->std::unique_ptr<StreamHandlerError<EncodableValue>> {
                    this->event_sink = std::move(events);
                    return nullptr;
                },
                [this](const EncodableValue* arguments)->std::unique_ptr<StreamHandlerError<EncodableValue>> {
                    this->event_sink = nullptr;
                    return nullptr;
                })
        );
    }

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
                OutputDebugString(L"test");
            }
            DNSServiceProcessResult(sdRef);
        }
        else {
            if (print_logs) {
                OutputDebugString(L"error");
            }
            event_sink->Error("broadcastError", "Bonsoir service failed to broadcast : " + service.get_description() + ", error code : " + std::to_string(error), error);
            dispose();
        }
    }

    void BonsoirBroadcast::dispose() {
        DNSServiceRefDeallocate(sdRef);
        if (print_logs) {
            OutputDebugString(L"stop");
        }
        event_sink->Success(SuccessObject("broadcastStopped", service).to_encodable());
        on_dispose();
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
        if (errorCode == kDNSServiceErr_NoError) {
            if (broadcast->print_logs) {
                OutputDebugString(L"test2");
            }
            broadcast->event_sink->Success(SuccessObject("broadcastStarted", broadcast->service).to_encodable());
        }
        else {
            if (broadcast->print_logs) {
                OutputDebugString(L"error");
            }
            broadcast->event_sink->Error("broadcastError", "Bonsoir service failed to broadcast.", errorCode);
            broadcast->dispose();
        }
    }
}