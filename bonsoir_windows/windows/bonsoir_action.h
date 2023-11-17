#pragma once

#include <flutter/event_channel.h>
#include <windows.h>
#include <windns.h>

#include <mutex>
#include <queue>

#include "bonsoir_service.h"

using namespace flutter;

namespace bonsoir_windows {
  class BonsoirAction;

  class EventObject {
   public:
    std::string message;

    EventObject(std::string _message);

    virtual void process(BonsoirAction *action) {}
  };

  class SuccessObject : public EventObject {
   public:
    std::string id;
    BonsoirService *service;

    SuccessObject(std::string _id, std::string _message)
      : SuccessObject(_id, _message, nullptr){};

    SuccessObject(std::string _id, std::string _message, BonsoirService *_service);

    void process(BonsoirAction *action) override;

    EncodableMap toEncodable() const;
  };

  class ErrorObject : public EventObject {
   public:
    EncodableValue error;

    ErrorObject(std::string _message, EncodableValue _error);

    void process(BonsoirAction *action) override;
  };

  class BonsoirAction {
   public:
    std::string action;
    int id;
    bool printLogs;
    std::function<void()> onDispose;
    std::unique_ptr<EventSink<EncodableValue>> eventSink;

    BonsoirAction(
      std::string _action,
      int _id,
      bool _printLogs,
      BinaryMessenger *_binaryMessenger,
      std::function<void()> _onDispose
    );

    virtual void start();

    bool isRunning();

    void stop();

    virtual void dispose();

    void onSuccess(std::string _id, std::string _message) {
      onSuccess(_id, _message, nullptr);
    }

    void onSuccess(std::string _id, std::string _message, BonsoirService *_service) {
      SuccessObject successObject = SuccessObject(_id, _message, _service);
      onEvent(&successObject);
    }

    void onError(std::string _message, EncodableValue _error) {
      ErrorObject errorObject = ErrorObject(_message, _error);
      onEvent(&errorObject);
    }

    void log(std::string message);

    void processEventQueue();

   protected:
    DNS_SERVICE_CANCEL cancelHandle{};
    std::shared_ptr<EventChannel<EncodableValue>> eventChannel;

   private:
    std::atomic<int> state = 0;
    void onEvent(EventObject *event);

    std::mutex mutex;
    std::queue<EventObject *> eventQueue;
  };
}  // namespace bonsoir_windows
