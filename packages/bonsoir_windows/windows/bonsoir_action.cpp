#pragma once

#include "bonsoir_action.h"

#include <flutter/binary_messenger.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>

using namespace flutter;

namespace bonsoir_windows {
  BonsoirAction::BonsoirAction(
    std::string _action,
    const std::map<std::string, std::string> _logMessages,
    int _id,
    bool _printLogs,
    BinaryMessenger *_binaryMessenger
  )
    : action(_action),
      logMessages(_logMessages),
      id(_id),
      eventChannel(std::make_unique<EventChannel<EncodableValue>>(_binaryMessenger, "fr.skyost.bonsoir." + _action + "." + std::to_string(id), &StandardMethodCodec::GetInstance())),
      printLogs(_printLogs) {
    eventChannel->SetStreamHandler(
      std::make_unique<StreamHandlerFunctions<EncodableValue>>(
        [this](const EncodableValue *arguments, std::unique_ptr<EventSink<EncodableValue>> &&events)
          -> std::unique_ptr<StreamHandlerError<EncodableValue>> {
          std::unique_lock<std::mutex> _ul(mutex);
          eventSink = std::move(events);
          processEventQueue();
          return nullptr;
        },
        [this](const EncodableValue *arguments)
          -> std::unique_ptr<StreamHandlerError<EncodableValue>> {
          std::unique_lock<std::mutex> _ul(mutex);
          eventSink.release();
          eventSink = nullptr;
          return nullptr;
        }
      )
    );
  }

  void BonsoirAction::start() {
    state.store(1, std::memory_order_release);
  }

  bool BonsoirAction::isRunning() {
    return state.load(std::memory_order_acquire) == 1;
  }

  void BonsoirAction::stop() {
    state.store(0, std::memory_order_release);
  }

  void BonsoirAction::dispose() {
    stop();
    if (eventChannel) {
      eventChannel->SetStreamHandler(nullptr);
      eventChannel = nullptr;
    }
  }

  void BonsoirAction::onEvent(std::shared_ptr<EventObject> eventObjectPtr, std::list<std::string> parameters) {
    log(eventObjectPtr->message, parameters);
    eventQueue.push(std::move(eventObjectPtr));
    processEventQueue();
  }

  void BonsoirAction::log(std::string message, std::list<std::string> parameters) {
    if (printLogs) {
      std::cout << ("[" + action + "] [" + std::to_string(id) + "] " + format(message, parameters)) << std::endl;
    }
  }

  std::string BonsoirAction::format(std::string message, std::list<std::string> parameters) {
    std::string result = message;
    for (auto const &parameter : parameters) {
      size_t position = result.find("%s");
      if (position != std::string::npos) {
        result.replace(position, 2, parameter);
      }
    }
    return result;
  }

  void BonsoirAction::processEventQueue() {
    if (!eventSink) {
      return;
    }
    while (!eventQueue.empty()) {
      eventQueue.front()->process(this);
      eventQueue.pop();
    }
  }

  EventObject::EventObject(std::string _message)
    : message(_message) {}

  SuccessObject::SuccessObject(std::string _id, std::string _message, std::shared_ptr<BonsoirService> _service)
    : EventObject(_message), id(_id), service(_service) {}

  void SuccessObject::process(BonsoirAction *action) {
    action->eventSink->Success(toEncodable());
  }

  EncodableMap SuccessObject::toEncodable() const {
    auto result = EncodableMap{{EncodableValue("id"), EncodableValue(id)}};
    if (service) {
      result.insert({EncodableValue("service"), service->toEncodable()});
    }
    return result;
  }

  ErrorObject::ErrorObject(std::string _message, EncodableValue _details)
    : EventObject(_message), details(_details) {}

  void ErrorObject::process(BonsoirAction *action) {
    action->eventSink->Error(action->action + "Error", message, details);
  }
}  // namespace bonsoir_windows