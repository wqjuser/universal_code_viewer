#ifndef FLUTTER_PLUGIN_UNIVERSAL_CODE_VIEWER_PLUGIN_H_
#define FLUTTER_PLUGIN_UNIVERSAL_CODE_VIEWER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace universal_code_viewer {

class UniversalCodeViewerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  UniversalCodeViewerPlugin();

  virtual ~UniversalCodeViewerPlugin();

  // Disallow copy and assign.
  UniversalCodeViewerPlugin(const UniversalCodeViewerPlugin&) = delete;
  UniversalCodeViewerPlugin& operator=(const UniversalCodeViewerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace universal_code_viewer

#endif  // FLUTTER_PLUGIN_UNIVERSAL_CODE_VIEWER_PLUGIN_H_
