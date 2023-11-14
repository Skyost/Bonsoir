#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/event_stream_handler_functions.h>

#include "bonsoir_action.h"

using namespace flutter;

namespace bonsoir_windows {
    BonsoirAction::BonsoirAction(std::string _action, int _id, bool _print_logs, BinaryMessenger *_binary_messenger, std::function<void()> _on_dispose) :
            sdRef(nullptr),
            action(_action),
            id(_id),
            event_channel(std::make_shared < EventChannel < EncodableValue
                    >> (_binary_messenger, "fr.skyost.bonsoir." + _action + "." + std::to_string(
                            id), &StandardMethodCodec::GetInstance())),
            print_logs(_print_logs),
            on_dispose(_on_dispose) {
        event_channel->SetStreamHandler(
                std::make_unique < StreamHandlerFunctions < EncodableValue >> (
                        [this](const EncodableValue *arguments, std::unique_ptr <EventSink<EncodableValue>> &&events) -> std::unique_ptr <StreamHandlerError<EncodableValue>> {
                            std::unique_lock <std::mutex> _ul(mutex);
                            event_sink = std::move(events);
                            process_event_queue();
                            return nullptr;
                        },
                                [this](const EncodableValue *arguments) -> std::unique_ptr <StreamHandlerError<EncodableValue>> {
                                    std::unique_lock <std::mutex> _ul(mutex);
                                    event_sink.release();
                                    return nullptr;
                                }
                )
        );
    }

    void BonsoirAction::dispose() {
        DNSServiceRefDeallocate(sdRef);
        sdRef = nullptr;
        event_channel->SetStreamHandler(nullptr);
        on_dispose();
    }

    void BonsoirAction::on_event(EventObject *event) {
        if (print_logs) {
            log(event->message);
        }
        event_queue.push(event);
        process_event_queue();
    }

    void BonsoirAction::log(std::string message) {
        std::cout << ("[" + action + "] [" + std::to_string(id) + "] " + message) << std::endl;
    }

    void BonsoirAction::process_event_queue() {
        if (!event_sink) {
            return;
        }
        while (!event_queue.empty()) {
            event_queue.front()->process(this);
            event_queue.pop();
        }
    }

    EventObject::EventObject(std::string _message) : message(_message) {}

    SuccessObject::SuccessObject(std::string _id, std::string _message, std::optional <BonsoirService> _service) :
            EventObject(_message),
            id(_id),
            service(_service) {}

    void SuccessObject::process(BonsoirAction *action) {
        action->event_sink->Success(to_encodable());
    }

    EncodableMap SuccessObject::to_encodable() {
        auto result = EncodableMap{
                {EncodableValue("id"), EncodableValue(id)}
        };
        if (service.has_value()) {
            result.insert({EncodableValue("service"), service.value().to_encodable()});
        }
        return result;
    }

    ErrorObject::ErrorObject(std::string _message, EncodableValue _error) :
            EventObject(_message),
            error(_error) {}

    void ErrorObject::process(BonsoirAction *action) {
        action->event_sink->Error(action->action + "Error", message, error);
    }
}