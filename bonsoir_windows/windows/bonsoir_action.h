#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler.h>
#include <flutter/standard_method_codec.h>
#include <queue>
#include <mutex>

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

        SuccessObject(std::string _id, std::string _message,
                      std::optional <BonsoirService> _service);

        void process(BonsoirAction *action) override;

        EncodableMap to_encodable();
    };

    class ErrorObject: public EventObject {
    public:
        EncodableValue error;

        ErrorObject(std::string _message, EncodableValue _error);

        void process(BonsoirAction *action) override;
    };

    class BonsoirAction {
    public:
        std::string action;
        int id;
        bool print_logs;
        std::function<void()> on_dispose;
        std::unique_ptr <EventSink<EncodableValue>> event_sink;

        BonsoirAction(std::string _action, int _id, bool _print_logs,
                      BinaryMessenger *_binary_messenger, std::function<void()> _on_dispose);

        virtual void start() {}

        virtual void dispose();

        void on_success(std::string _id, std::string _message) {
            on_success(_id, _message, std::optional<BonsoirService>());
        }

        void on_success(std::string _id, std::string _message, std::optional <BonsoirService> _service) {
            SuccessObject success_object = SuccessObject(_id, _message, _service);
            on_event(&success_object);
        }

        void on_error(std::string _message, EncodableValue _error) {
            ErrorObject error_object = ErrorObject(_message, _error);
            on_event(&error_object);
        }

        void log(std::string message);

        void process_event_queue();

    protected:
        DNSServiceRef sdRef;
        std::shared_ptr <EventChannel<EncodableValue>> event_channel;
    private:
        void on_event(EventObject *event);

        std::mutex mutex;
        std::queue<EventObject *> event_queue;
    };
}
