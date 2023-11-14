#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/standard_method_codec.h>

#include "include/dns_sd.h"
#include "bonsoir_service.h"

using namespace flutter;

namespace bonsoir_windows {
	class BonsoirBroadcast {
	public:
		int id;
		bool print_logs;
		BonsoirService service;
		std::function<void()> on_dispose;
		BonsoirBroadcast(int _id, bool _print_logs, BonsoirService _service, flutter::BinaryMessenger* _binaryMessenger, std::function<void()>);
		void start();
		void dispose();
		std::shared_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink;
	private:
		DNSServiceRef sdRef;
		std::shared_ptr<flutter::EventChannel<flutter::EncodableValue>> event_channel;
	};
	void registerCallback(
		DNSServiceRef sdRef,
		DNSServiceFlags flags,
		DNSServiceErrorType errorCode,
		const char* name,
		const char* regtype,
		const char* domain,
		void* context
	);
}