#include "include/universal_code_viewer/universal_code_viewer_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "universal_code_viewer_plugin.h"

void UniversalCodeViewerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  universal_code_viewer::UniversalCodeViewerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
