import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'universal_code_viewer_platform_interface.dart';

/// An implementation of [UniversalCodeViewerPlatform] that uses method channels.
class MethodChannelUniversalCodeViewer extends UniversalCodeViewerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('universal_code_viewer');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
