import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'universal_code_viewer_method_channel.dart';

abstract class UniversalCodeViewerPlatform extends PlatformInterface {
  /// Constructs a UniversalCodeViewerPlatform.
  UniversalCodeViewerPlatform() : super(token: _token);

  static final Object _token = Object();

  static UniversalCodeViewerPlatform _instance =
      MethodChannelUniversalCodeViewer();

  /// The default instance of [UniversalCodeViewerPlatform] to use.
  ///
  /// Defaults to [MethodChannelUniversalCodeViewer].
  static UniversalCodeViewerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniversalCodeViewerPlatform] when
  /// they register themselves.
  static set instance(UniversalCodeViewerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
