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
    EncodableValue details;

    ErrorObject(std::string _message, EncodableValue _details);

    void process(BonsoirAction *action) override;
  };

  class BonsoirAction {
   public:
    std::string action;
    const std::map<std::string, std::string> logMessages;
    std::unique_ptr<EventSink<EncodableValue>> eventSink;

    BonsoirAction(
      std::string _action,
      const std::map<std::string, std::string> _logMessages,
      int _id,
      bool _printLogs,
      BinaryMessenger *_binaryMessenger
    );

    virtual void start();

    bool isRunning();

    void stop();

    virtual void dispose();

    void onSuccess(std::string eventId, std::list<std::string> parameters = std::list<std::string>(), std::optional<std::string> message = std::nullopt) {
      onSuccess(eventId, nullptr, parameters, message);
    }

    void onSuccess(std::string eventId, std::shared_ptr<BonsoirService> service = nullptr, std::list<std::string> parameters = std::list<std::string>(), std::optional<std::string> message = std::nullopt) {
      std::string successMessage = message.value_or(logMessages.find(eventId)->second);

      std::string serviceDescription = service == nullptr ? "" : service->getDescription();
      std::list<std::string> successParameters = std::list<std::string>();
      std::copy(parameters.begin(), parameters.end(), std::back_inserter(successParameters));
      if (service && !(std::find(successParameters.begin(), successParameters.end(), serviceDescription) != successParameters.end())) {
        successParameters.insert(successParameters.begin(), serviceDescription);
      }

      std::shared_ptr<EventObject> successObjectPtr = std::make_shared<SuccessObject>(eventId, successMessage, service);
      onEvent(successObjectPtr, successParameters);
    }

    void onError(EncodableValue details, std::list<std::string> parameters = std::list<std::string>(), std::optional<std::string> message = std::nullopt) {
      std::string errorMessage = format(message.value_or(logMessages.find(action + "Error")->second), parameters);
        
      std::shared_ptr<ErrorObject> errorObjectPtr = std::make_shared<ErrorObject>(errorMessage, details);
      onEvent(errorObjectPtr, std::list<std::string>());
    }

    void log(std::string message, std::list<std::string> parameters);

    void processEventQueue();

   protected:
    int id;
    std::shared_ptr<EventChannel<EncodableValue>> eventChannel;
    DNS_SERVICE_CANCEL cancelHandle{};

   private:
    void onEvent(std::shared_ptr<EventObject> eventObjectPtr, std::list<std::string> parameters);
    std::string BonsoirAction::format(std::string message, std::list<std::string> parameters);

    bool printLogs;

    std::mutex mutex;
    std::queue<std::shared_ptr<EventObject>> eventQueue;
    std::atomic<int> state = 0;
  };
}  // namespace bonsoir_windows
