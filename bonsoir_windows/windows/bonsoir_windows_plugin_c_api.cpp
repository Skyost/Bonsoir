#include "include/bonsoir_windows/bonsoir_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "bonsoir_windows_plugin.h"

void BonsoirWindowsPluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
  bonsoir_windows::BonsoirWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarManager::GetInstance()
      ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar)
  );
}
