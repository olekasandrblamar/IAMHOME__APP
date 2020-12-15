import UIKit
import Flutter
import Firebase
import BackgroundTasks
//import TSBackgroundFetch

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    static var watchData:WatchData? = nil
    static var bandDevice:BandDevice? = nil
    static let dateFormatter = DateFormatter()
    static var lastUpdated:Date? = nil
    static var WATCH_TYPE = "WATCH"
    static var BAND_TYPE = "BAND"
    static var DEVICE_TYPE_KEY = "flutter.deviceType"
    static let BG_SYNC_TASK = "com.cerashealth.datasync"
  
//    override func application(_ application: UIApplication,
//                              performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
//        //TSBackgroundFetch.sharedInstance()?.perform(completionHandler: completionHandler, applicationState: application.applicationState)
//    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.processBackgroundData()
    }
    
    private func processBackgroundData(){
        let connectionInfo = UserDefaults.standard.string(forKey: "flutter.watchInfo")
        NSLog("Got connection info in background from \(connectionInfo)")
        do{
            if(connectionInfo != nil){
                try self.syncData(connectionInfo: connectionInfo!)
            }
        }catch{
            NSLog("Error while syncing data")
        }
    }
    

    //This is called when the remote notification is triggered
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.processBackgroundData()
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("Registered with notification")
        Messaging.messaging().apnsToken = deviceToken
        do{
            let tokenData = try JSONEncoder().encode(deviceToken)
            NSLog("Decided data \(tokenData)")
            let token = Messaging.messaging().fcmToken as? String
            NSLog("Got toke \(token)")
        }catch{
            NSLog("Error while decding")
        }
        
    }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    //scheduleBackgroundSync()

    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    if #available(iOS 13.0, *){
        configureNativeBackground()
    }

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceChannel = FlutterMethodChannel(name: "ceras.iamhome.mobile/device",binaryMessenger: controller.binaryMessenger)
    AppDelegate.dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
    //Register the methods
    deviceChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        DataSync.BACKGROUND = false
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
        }else if(call.method=="connectionStatus"){
            
            guard let args = call.arguments else {
              result("iOS could not recognize flutter arguments in method: (sendParams)")
              return
            }
            let connectionInfo:String = (args as? [String:Any])?["connectionInfo"] as! String
            do{
                try self?.getConnectionStatus(result: result, connectionInfo: connectionInfo)
            }catch{
                result(false)
            }
        }else if(call.method=="disconnect"){
            guard let args = call.arguments else {
              result("iOS could not recognize flutter arguments in method: (sendParams)")
              return
            }
            NSLog("Disconnecting device")
            let deviceType:String = (args as? [String: Any])?["deviceType"] as! String
            self?.disconectDevice(result: result, deviceType: deviceType)
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
//        let backgroundConfig = TSBackgroundFetch.sharedInstance()
//        backgroundConfig?.stopOnTerminate = false
//        NSLog("Scheduling background sync")
//        backgroundConfig?.addListener("com.transistorsoft.datasync", callback: { (taskId) in
//            NSLog("Executing task \(taskId)")
//            TSBackgroundFetch.sharedInstance()?.finish(taskId)
//        })
//        backgroundConfig?.configure(60, callback: { (status) in
//            if(status != .available){
//                NSLog("Ceras Sync Background job failed to start, status: \(status.rawValue)");
//            }
//            NSLog("Ceras Sync Background config scheduling complete with \(status.rawValue)")
//        })
//        backgroundConfig?.didFinishLaunching()
//        backgroundConfig?.start(nil)
        
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("Application going into background")
        if #available(iOS 13.0, *){
            NSLog("Application did enter background")
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: AppDelegate.BG_SYNC_TASK)
            NSLog("Cancelled all old tasks")
            scheduleSyncTask()
        }
    }
    
    
    @available(iOS 13.0, *)
    private func configureNativeBackground(){
        NSLog("Configuring background tasks")
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppDelegate.BG_SYNC_TASK,
            using: DispatchQueue.global()
        ) { task in
            NSLog("Executing task \(task.identifier)")
            if(task.identifier==AppDelegate.BG_SYNC_TASK){
                DataSync.BACKGROUND = true
                self.scheduleSyncTask()
                NSLog("Executing bg task at \(Date())")
                task.expirationHandler = {[weak task] in
                    NSLog("Task expired without completion at \(Date())")
                    task?.setTaskCompleted(success: false)
                }
                let connectionInfo = UserDefaults.standard.string(forKey: "flutter.watchInfo")
                NSLog("Got connection info in background \(connectionInfo)")
                do{
                    if(connectionInfo != nil){
                        try self.syncData(connectionInfo: connectionInfo!)
                    }
                }catch{
                    NSLog("Error while loading data for task \(task.identifier) \(error)")
                }
                NSLog("Completing task \(task.identifier) at \(Date())")
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    @available(iOS 13.0,*)
    private func scheduleSyncTask(){
        NSLog("Scheduling sync tasks")
        let task = BGProcessingTaskRequest(identifier: AppDelegate.BG_SYNC_TASK)
        task.requiresExternalPower=false
        task.requiresNetworkConnectivity = false
        task.earliestBeginDate = Date(timeIntervalSinceNow: 5*60)
        do {
            NSLog("Task scheduled for ceras sync for \(task.earliestBeginDate)")
            try BGTaskScheduler.shared.submit(task)
        } catch {
            NSLog("Could not schedule ceras task: \(error)")
        }
    }
    
    /**
        This is called when the app is terminated
     */
    override func applicationWillTerminate(_ application: UIApplication) {
        //Make a call to backend to send the terminate signal
    }
    
    
    private func syncData(connectionInfo:String) throws {
        Messaging.messaging().subscribe(toTopic: "ios_updates") { error in
          NSLog("Subscribed to ios_updates with error \(error)")
        }
        
        //DataSync.loadWeatherData()
        
        let connectionData = try JSONDecoder().decode(ConnectionInfo.self, from: connectionInfo.data(using: .utf8) as! Data)
        let deviceType = getDeviceType()
        NSLog("Syncing data for device \(deviceType)")
        UserDefaults.standard.set(AppDelegate.dateFormatter.string(from: Date()),forKey: "flutter.last_sync")
        if(deviceType! == AppDelegate.WATCH_TYPE){
            self.getWatchDevice()?.syncData(connectionInfo: connectionData)
        }else if(deviceType! == AppDelegate.BAND_TYPE){
            self.getBandDevice()?.syncData(connectionInfo: connectionData)
        }
    }
    private func getProfile(){
        let deviceType = getDeviceType()
        NSLog("Syncing data for device \(deviceType)")

    }

    private func getDeviceType() -> String?{
        return UserDefaults.standard.string(forKey: AppDelegate.DEVICE_TYPE_KEY)
    }
    
    private func disconectDevice(result:@escaping FlutterResult, deviceType:String){
        NSLog("disconnecting device \(deviceType)")
        if(deviceType==AppDelegate.WATCH_TYPE){
            NSLog("disonnecting Watch")
            self.getWatchDevice()?.disconnect(result: result)
            NSLog("completed Connecting Watch")
        }else if(deviceType==AppDelegate.BAND_TYPE){
            getBandDevice()?.disconnectDevice(result: result)
        }
    }

    private func connectDevice(result:@escaping FlutterResult,deviceId:String, deviceType:String) {
        NSLog("Connecting device \(deviceType)")
        if(deviceType==AppDelegate.WATCH_TYPE){
            NSLog("Connecting Watch")
            self.getWatchDevice()?.startScan(result: result,deviceId:deviceId)
            NSLog("completed Connecting Watch")
        }else if(deviceType==AppDelegate.BAND_TYPE){
            getBandDevice()?.connectDevice(result: result, deviceId: deviceId)
        }
    }
    
    private func getDeviceInfo(result:@escaping FlutterResult,connectionInfo:String) throws {
        let connectionData = try JSONDecoder().decode(ConnectionInfo.self, from: connectionInfo.data(using: .utf8) as! Data)
        NSLog("Getting device info ")
        let deviceType = getDeviceType()
        if(deviceType! == AppDelegate.WATCH_TYPE){
            self.getWatchDevice()?.getCurrentDeviceStatus(connInfo: connectionData, result: result)
        }else if(deviceType! == AppDelegate.BAND_TYPE){
            self.getBandDevice()?.getCurrentDeviceStatus(connInfo: connectionData, result: result)
        }
    }
    
    private func getConnectionStatus(result:@escaping FlutterResult,connectionInfo:String) throws {
        let connectionData = try JSONDecoder().decode(ConnectionInfo.self, from: connectionInfo.data(using: .utf8) as! Data)
        NSLog("Getting device info ")
        let deviceType = getDeviceType()
        if(deviceType! == AppDelegate.WATCH_TYPE){
            self.getWatchDevice()?.getConnectionStatus(result: result)
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
    
    private func getWatchDevice() -> WatchData?{
        if(AppDelegate.watchData==nil){
            AppDelegate.watchData = WatchData()
        }
        return AppDelegate.watchData
    }
}

struct ConnectionInfo:Codable {
    var deviceId:String?
    var deviceName:String?
    var connected:Bool? = false
    var deviceFound:Bool? = false
    var message:String?
    var additionalInformation: [String:String] = [:]
    var batteryStatus:String? = nil
}
