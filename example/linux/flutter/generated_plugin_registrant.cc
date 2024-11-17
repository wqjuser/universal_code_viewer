//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <universal_code_viewer/universal_code_viewer_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) universal_code_viewer_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UniversalCodeViewerPlugin");
  universal_code_viewer_plugin_register_with_registrar(universal_code_viewer_registrar);
}
