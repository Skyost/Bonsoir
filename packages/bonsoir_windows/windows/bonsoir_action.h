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
    std::shared_ptr<BonsoirService> service;

    SuccessObject(std::string _id, std::string _message)
      : SuccessObject(_id, _message, nullptr){};

    SuccessObject(std::string _id, std::string _message, std::shared_ptr<BonsoirService> _service);

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
      BinaryMessenger *_binaryMessenger
    );

    virtual void start();

    bool isRunning();

    void stop();

    virtual void dispose();

    void onSuccess(std::string _id, std::string _message) {
      onSuccess(_id, _message, nullptr);
    }

    void onSuccess(std::string _id, std::string _message, std::shared_ptr<BonsoirService> _service) {
      std::shared_ptr<EventObject> successObjectPtr = std::make_shared<SuccessObject>(_id, _message, _service);
      onEvent(successObjectPtr);
    }

    void onError(std::string _message, EncodableValue _error) {
      std::shared_ptr<ErrorObject> errorObjectPtr = std::make_shared<ErrorObject>(_message, _error);
      onEvent(errorObjectPtr);
    }

    void log(std::string message);

    void processEventQueue();

   protected:
    DNS_SERVICE_CANCEL cancelHandle{};
    std::shared_ptr<EventChannel<EncodableValue>> eventChannel;

   private:
    void onEvent(std::shared_ptr<EventObject> eventObjectPtr);

    std::mutex mutex;
    std::queue<std::shared_ptr<EventObject>> eventQueue;
    std::atomic<int> state = 0;
  };
}  // namespace bonsoir_windows
