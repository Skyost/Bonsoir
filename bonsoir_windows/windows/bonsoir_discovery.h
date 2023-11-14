#pragma once

#include "bonsoir_action.h"
#include "bonsoir_service.h"

namespace bonsoir_windows {
	class BonsoirDiscovery : public BonsoirAction {
	public:
		std::string type;
		std::list<BonsoirService> services;
		std::map<DNSServiceRef, BonsoirService*> resolving_services = std::map<DNSServiceRef, BonsoirService*>{};
		BonsoirDiscovery(int _id, bool _print_logs, flutter::BinaryMessenger *_binary_messenger,
                         std::function<void()>, std::string type);

        void start() override;

        void resolveService(std::string service_name, std::string service_type);

        void stopResolution(DNSServiceRef resolveRef, bool remove);

        void dispose() override;
	};
	void browseCallback(
		DNSServiceRef sdRef,
		DNSServiceFlags flags,
		uint32_t interfaceIndex,
		DNSServiceErrorType errorCode,
		const char* serviceName,
		const char* regtype,
		const char* replyDomain,
		void* context
	);
	void resolveCallback(
		DNSServiceRef sdRef,
		DNSServiceFlags flags,
		uint32_t interfaceIndex,
		DNSServiceErrorType errorCode,
		const char* fullname,
		const char* hosttarget,
		uint16_t port,
		uint16_t txtLen,
		const unsigned char* txtRecord,
		void* context
	);
}
