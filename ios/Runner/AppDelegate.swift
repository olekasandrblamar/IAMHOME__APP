import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceChannel = FlutterMethodChannel(name: "ceras.iamhome.mobile/device",binaryMessenger: controller.binaryMessenger)
    
    //Register the methods
    deviceChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "connectDevice" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.connectDevice(result: result)
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func connectDevice(result: FlutterResult) {
        var connectionInfo = ConnectionInfo(deviceId: "123", deviceName: "abc", connected: true, message: "connected")
        connectionInfo.additionalInformation["factoryName"] = "Sample Device"
        do{
            let deviceJson = try JSONEncoder().encode(connectionInfo)
            let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
            result(connectionInfoData)
        }catch{result("Error")}
    }
}

struct ConnectionInfo:Codable {
    var deviceId:String?
    var deviceName:String?
    var connected = false
    var message:String?
    var additionalInformation: [String:String] = [:]
}
