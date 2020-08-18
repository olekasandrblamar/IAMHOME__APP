import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var watchData:WatchData = WatchData()
    static var bandDevice:BandDevice? = nil
    static let dateFormatter = DateFormatter()
    static var lastUpdated:Date? = nil
    static var WATCH_TYPE = "WATCH"
    static var BAND_TYPE = "BAND"
    static var DEVICE_TYPE_KEY = "flutter.deviceType"
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceChannel = FlutterMethodChannel(name: "ceras.iamhome.mobile/device",binaryMessenger: controller.binaryMessenger)
    AppDelegate.dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
    //Register the methods
    deviceChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if(call.method=="connectDevice"){
            
            guard let args = call.arguments else {
              result("iOS could not recognize flutter arguments in method: (sendParams)")
              return
            }
            
            let deviceId:String = (args as? [String: Any])?["deviceId"] as! String
            let deviceType:String = (args as? [String: Any])?["deviceType"] as! String
            self?.connectDevice(result: result,deviceId: deviceId,deviceType: deviceType)
        } else if(call.method=="syncData"){
            
            guard let args = call.arguments else {
              result("iOS could not recognize flutter arguments in method: (sendParams)")
              return
            }
            let connectionInfo:String = (args as? [String:Any])?["connectionInfo"] as! String
            NSLog("Got connection info %@", connectionInfo)
            do{
                var loadData = false
                if(AppDelegate.lastUpdated == nil){
                   loadData = true
                }else {
                    let current = Date()
                    let diffComponents = Calendar.current.dateComponents([.second], from:AppDelegate.lastUpdated! , to: current)
                    if(diffComponents.second!>5){
                        loadData = true
                    }
                }
                if(loadData){
                    let connectionData = try JSONDecoder().decode(ConnectionInfo.self, from: connectionInfo.data(using: .utf8) as! Data)
                    UserDefaults.standard.set(AppDelegate.dateFormatter.string(from: Date()),forKey: "flutter.last_sync")
                    NSLog("Syncing data ")
                    self?.syncData(connectionInfo: connectionData)
                    //self?.watchData.syncData(connectionInfo: connectionData)
                }
                result("Load complete")
            }catch{
                result("Error")
            }
        }
        else {
          result(FlutterMethodNotImplemented)
          return
        }
        
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func syncData(connectionInfo:ConnectionInfo){
        let deviceType = getDeviceType()
        if(deviceType! == AppDelegate.WATCH_TYPE){
            self.watchData.syncData(connectionInfo: connectionInfo)
        }else if(deviceType! == AppDelegate.BAND_TYPE){
            self.getBandDevice()?.syncData(connectionInfo: connectionInfo)
        }
    }
    
    private func getDeviceType() -> String?{
        return UserDefaults.standard.string(forKey: AppDelegate.DEVICE_TYPE_KEY)
    }
    
    private func connectDevice(result:@escaping FlutterResult,deviceId:String, deviceType:String) {
        if(deviceType==AppDelegate.WATCH_TYPE){
            self.watchData.startScan(result: result,deviceId:deviceId)
        }else if(deviceType==AppDelegate.BAND_TYPE){
            getBandDevice()?.connectDevice(result: result, deviceId: deviceId)
        }
    }
    
    private func getBandDevice() -> BandDevice?{
        if(AppDelegate.bandDevice==nil){
            AppDelegate.bandDevice = BandDevice()
        }
        return AppDelegate.bandDevice
    }
}

struct ConnectionInfo:Codable {
    var deviceId:String?
    var deviceName:String?
    var connected = false
    var message:String?
    var additionalInformation: [String:String] = [:]
}
