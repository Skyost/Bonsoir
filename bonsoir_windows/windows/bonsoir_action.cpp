#pragma once

#include "bonsoir_action.h"

#include <flutter/binary_messenger.h>
#include <flutter/event_stream_handler_functions.h>

using namespace flutter;

namespace bonsoir_windows {
  BonsoirAction::BonsoirAction(
    std::string _action,
    int _id,
    bool _printLogs,
    BinaryMessenger *_binaryMessenger,
    std::function<void()> _onDispose
  )
    : action(_action),
      id(_id),
      eventChannel(std::make_shared<EventChannel<EncodableValue>>(_binaryMessenger, "fr.skyost.bonsoir." + _action + "." + std::to_string(id), &StandardMethodCodec::GetInstance())),
      printLogs(_printLogs),
      onDispose(_onDispose) {
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
    std::cout << "start !" << std::endl;
    state.store(1, std::memory_order_release);
  }

  bool BonsoirAction::isRunning() {
    return state.load(std::memory_order_acquire) != 0;
  }

  void BonsoirAction::stop() {
    state.store(0, std::memory_order_release);
  }

  void BonsoirAction::dispose() {
    stop();
    eventChannel->SetStreamHandler(nullptr);
    onDispose();
  }

  void BonsoirAction::onEvent(EventObject *event) {
    log(event->message);
    eventQueue.push(event);
    processEventQueue();
  }

  void BonsoirAction::log(std::string message) {
    if (printLogs) {
      std::cout << ("[" + action + "] [" + std::to_string(id) + "] " + message) << std::endl;
    }
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

  SuccessObject::SuccessObject(std::string _id, std::string _message, BonsoirService *_service)
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

  ErrorObject::ErrorObject(std::string _message, EncodableValue _error)
    : EventObject(_message), error(_error) {}

  void ErrorObject::process(BonsoirAction *action) {
    action->eventSink->Error(action->action + "Error", message, error);
  }
}  // namespace bonsoir_windows