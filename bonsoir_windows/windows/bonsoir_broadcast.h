#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/standard_method_codec.h>
#include <queue>

#include "include/dns_sd.h"
#include "bonsoir_action.h"
#include "bonsoir_service.h"

using namespace flutter;

namespace bonsoir_windows {
	class BonsoirBroadcast : public BonsoirAction {
	public:
		BonsoirService service;
		BonsoirBroadcast(int _id, bool _print_logs, flutter::BinaryMessenger* _binary_messenger, std::function<void()>, BonsoirService _service);
		void start();
		void dispose();
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