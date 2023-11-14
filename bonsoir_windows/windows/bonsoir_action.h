#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/standard_method_codec.h>
#include <queue>

#include "include/dns_sd.h"
#include "bonsoir_service.h"

using namespace flutter;

namespace bonsoir_windows {
    class BonsoirAction;

    class EventObject {
    public:
        std::string message;
        EventObject(std::string _message);
        virtual void process(BonsoirAction* action) {}
    };

    class SuccessObject: public EventObject {
    public:
        std::string id;
        std::optional<BonsoirService> service;
        SuccessObject(std::string _id, std::string _message) : SuccessObject(_id, _message, std::optional<BonsoirService>()) {};
        SuccessObject(std::string _id, std::string _message, std::optional<BonsoirService> _service);
        void process(BonsoirAction* action);
        EncodableMap to_encodable();
    };

    class ErrorObject: public EventObject {
    public:
        EncodableValue error;
        ErrorObject(std::string _message, EncodableValue _error);
        void process(BonsoirAction* action);
    };

    class BonsoirAction {
    public:
        std::string action;
        int id;
        bool print_logs;
        std::function<void()> on_dispose;
        BonsoirAction(std::string _action, int _id, bool _print_logs, BinaryMessenger* _binary_messenger, std::function<void()>);
        virtual void start() {}
        virtual void dispose();
        std::shared_ptr<EventSink<EncodableValue>> event_sink;
        void on_event(EventObject event);
        void log(std::string message);
    protected:
        DNSServiceRef sdRef;
        std::shared_ptr<EventChannel<EncodableValue>> event_channel;
        void process_event_queue();
    private:
        std::queue<EventObject> event_queue;
    };
}
