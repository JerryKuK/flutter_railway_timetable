import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var appGroupChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      appGroupChannel = FlutterMethodChannel(
        name: "com.jerry.railwaytimetable/app_group",
        binaryMessenger: controller.binaryMessenger
      )
      appGroupChannel?.setMethodCallHandler { [weak self] call, result in
        guard let self else { return }
        switch call.method {
        case "getAppGroupDir":
          result(AppDelegate.appGroupContainerURL?.path)
        case "reloadWidget":
          if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")
          }
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return result
  }

  static var appGroupContainerURL: URL? {
    FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.com.jerry.railwaytimetable.widget"
    )
  }
}
