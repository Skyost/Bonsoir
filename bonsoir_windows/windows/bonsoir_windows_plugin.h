#pragma once

#ifndef FLUTTER_PLUGIN_BONSOIR_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_BONSOIR_WINDOWS_PLUGIN_H_

#include <flutter/binary_messenger.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "bonsoir_broadcast.h"
#include "bonsoir_discovery.h"

using namespace flutter;

namespace bonsoir_windows {

    class BonsoirWindowsPlugin : public Plugin {
    public:
        static void RegisterWithRegistrar(PluginRegistrarWindows *registrar);

        BonsoirWindowsPlugin(BinaryMessenger *messenger) : messenger(messenger) {}

        virtual ~BonsoirWindowsPlugin();

        // Disallow copy and assign.
        BonsoirWindowsPlugin(const BonsoirWindowsPlugin &) = delete;

        BonsoirWindowsPlugin &operator=(const BonsoirWindowsPlugin &) = delete;

        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(const MethodCall <EncodableValue> &method_call, std::unique_ptr <MethodResult<EncodableValue>> result);

    private:
        BinaryMessenger *messenger;
        std::map<int, std::unique_ptr<BonsoirBroadcast>> broadcasts;
        std::map<int, std::unique_ptr<BonsoirDiscovery>> discoveries;
    };

} // namespace bonsoir_windows

#endif
