import Cocoa
import FlutterMacOS

public class UniversalCodeViewerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "universal_code_viewer", binaryMessenger: registrar.messenger)
        let instance = UniversalCodeViewerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            // 获取 macOS 系统版本
            let osVersion = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
            result("macOS " + versionString)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
