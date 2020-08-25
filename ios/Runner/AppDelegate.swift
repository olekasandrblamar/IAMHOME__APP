import UIKit
import Flutter
import Firebase
import TSBackgroundFetch

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var watchData:WatchData = WatchData()
    static var bandDevice:BandDevice? = nil
    static let dateFormatter = DateFormatter()
    static var lastUpdated:Date? = nil
    static var WATCH_TYPE = "WATCH"
    static var BAND_TYPE = "BAND"
    static var DEVICE_TYPE_KEY = "flutter.deviceType"
  
    override func application(_ application: UIApplication,
                              performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        TSBackgroundFetch.sharedInstance()?.perform(completionHandler: completionHandler, applicationState: application.applicationState)
    }
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    TSBackgroundFetch.sharedInstance()?.didFinishLaunching()
    scheduleBackgroundSync()

    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

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
                    NSLog("Syncing data ")
                    try self?.syncData(connectionInfo: connectionInfo)
                    //self?.watchData.syncData(connectionInfo: connectionData)
                }
                result("Load complete")
            }catch{
                result("Error")
            }
        }else if(call.method=="deviceStatus"){
            guard let args = call.arguments else {
              result("iOS could not recognize flutter arguments in method: (sendParams)")
              return
            }
            let connectionInfo:String = (args as? [String:Any])?["connectionInfo"] as! String
            do{
                try self?.getDeviceInfo(result: result, connectionInfo: connectionInfo)
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
    
    private func loadDataFromDevice(){
        do{
            let connectionInfo = UserDefaults.standard.string(forKey: "flutter.watchInfo")
            //If the connection info exists
            if(connectionInfo != nil){
                try syncData(connectionInfo: connectionInfo!)
            }
        }catch{
            NSLog("Error while reading da \(error)")
        }
    }
    
    private func scheduleBackgroundSync(){
        let backgroundConfig = TSBackgroundFetch.sharedInstance()
        backgroundConfig?.stopOnTerminate = false
        backgroundConfig?.scheduleProcessingTask(withIdentifier: "com.transistorsoft.datasync", delay: 10, periodic: true, callback: { (taskId) in
            let connectionInfo = UserDefaults.standard.string(forKey: "flutter.watchInfo")
            do{
                if(connectionInfo != nil){
                    try self.syncData(connectionInfo: connectionInfo!)
                }
            }catch{
                NSLog("Error while loading data \(error)")
            }
            TSBackgroundFetch.sharedInstance()?.finish(taskId)
        })
    }
    
    
    private func syncData(connectionInfo:String) throws {
        let connectionData = try JSONDecoder().decode(ConnectionInfo.self, from: connectionInfo.data(using: .utf8) as! Data)
        let deviceType = getDeviceType()
        UserDefaults.standard.set(AppDelegate.dateFormatter.string(from: Date()),forKey: "flutter.last_sync")
        if(deviceType! == AppDelegate.WATCH_TYPE){
            self.watchData.syncData(connectionInfo: connectionData)
        }else if(deviceType! == AppDelegate.BAND_TYPE){
            self.getBandDevice()?.syncData(connectionInfo: connectionData)
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
    
    private func getDeviceInfo(result:@escaping FlutterResult,connectionInfo:String) throws {
        let connectionData = try JSONDecoder().decode(ConnectionInfo.self, from: connectionInfo.data(using: .utf8) as! Data)
        NSLog("Getting device info ")
        let deviceType = getDeviceType()
        if(deviceType! == AppDelegate.WATCH_TYPE){
            self.watchData.getCurrentDeviceStatus(connInfo: connectionData, result: result)
        }else if(deviceType! == AppDelegate.BAND_TYPE){
            self.getBandDevice()?.getCurrentDeviceStatus(connInfo: connectionData, result: result)
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
    var connected:Bool? = false
    var message:String?
    var additionalInformation: [String:String] = [:]
}
