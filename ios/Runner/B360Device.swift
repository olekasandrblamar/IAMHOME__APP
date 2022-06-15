//
//  B360Device.swift
//  Runner
//
//  Created by Shyam Alapati on 10/4/21.
//

import Foundation
import VeepooBleSDK

class B360Device{
    
    var deviceId:String? = nil
    var deviceFound = false
    var deviceConnected = false
    var reconnect = 0
    var connectionInfo:ConnectionInfo? = nil
    let bleManager: VPBleCentralManage = VPBleCentralManage.sharedBleManager()
    let deviceInfoResult:FlutterResult? = nil
    var dateTimeFormat = DateFormatter()
    var result:FlutterResult? = nil
    
    init() {
        self.dateTimeFormat.dateFormat = "yyyy-MM-dd HH:mm"
        bleManager.vpBleConnectStateChangeBlock = {(deviceConnectState: VPDeviceConnectState) -> Void
            in
            switch deviceConnectState {
            case .connectStateVerifyPasswordSuccess:
                NSLog("Password verification success")
                self.syncDataFromDevice()
            case .connectStateVerifyPasswordFailure:
                NSLog("Password varification failure")
            case .connectStateDisConnect:
                NSLog("Device disconnected")
            case .connectStateConnect:
                NSLog("Device connected")
            case .discoverNewUpdateFirm:
                NSLog("New firmware available")
            }
        }
    }
    
    func startScan(result:@escaping FlutterResult,deviceId:String) {
        NSLog("Connecting with device id \(String(describing: deviceId))")
        self.reconnect = 0
        self.deviceFound = false
        self.scanAndConnectDevice(result: result, deviceId: deviceId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NSLog("reconnect \(self.reconnect) device found \(self.deviceFound)")
            //Stop the scanning after 25 seconds
            if(self.reconnect==0){
                NSLog("Reconnecting device")
                self.bleManager.veepooSDKStopScanDevice()
                self.reconnect = 1
                self.scanAndConnectDevice(result: result, deviceId: deviceId)
                DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                    self.reconnect = 0
                    self.sendInvalidResponse(result: result)
                }
            }else{
                NSLog("Reconnecting failed")
                self.sendInvalidResponse(result: result)
            }
        }
    }
    
    private func turnOnSetting(setting: VPSettingBaseFunctionSwitchType,callBack:@escaping () -> Void = { }){
        self.bleManager.peripheralManage.veepooSDKSettingBaseFunctionType(setting, settingState: .settingFunctionOpen) { completeState in
            NSLog("Complete state for \(setting.rawValue) \(completeState.rawValue)")
            switch completeState{
            case .functionCompleteComplete,.functionCompleteClose, .functionCompleteOpen:
                NSLog("Complete for \(String(setting.rawValue)) \(String(completeState.rawValue))")
                callBack()
            default:
                NSLog("Pending state \(completeState) for \(String(setting.rawValue)) \(String(completeState.rawValue))")
            }
        }
    }
    
    private func turnOffSetting(setting: VPSettingBaseFunctionSwitchType,callBack:@escaping () -> Void = { }){
        self.bleManager.peripheralManage.veepooSDKSettingBaseFunctionType(setting, settingState: .settingFunctionClose) { completeState in
            NSLog("Complete state for \(setting.rawValue) \(completeState.rawValue)")
            switch completeState{
            case .functionCompleteComplete,.functionCompleteClose, .functionCompleteOpen:
                NSLog("Complete for \(String(setting.rawValue)) \(String(completeState.rawValue))")
                callBack()
            default:
                NSLog("Pending state \(completeState) for \(String(setting.rawValue)) \(String(completeState.rawValue))")
            }
        }
    }
    
    private func updateTime(){
        let curDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.month,.year,.minute,.hour,.second], from: curDate)
        NSLog("Current hour \(components.hour)")
        self.bleManager.peripheralManage.veepooSDKSettingTime(withYear: Int32(components.year!), month: Int32(components.month!), day: Int32(components.day!), hour: Int32(components.hour!), minute: Int32(components.minute!), second: Int32(components.second!), timeSystem: 1)
        self.bleManager.peripheralManage.veepooSDKSettingBaseFunctionType(VPSettingBaseFunctionSwitchType.timeFormat,settingState: .settingFunctionClose){ completeState in
            NSLog("Complete state for Update time \(completeState.rawValue)")
        }
    }
    
    private func configureDevice(){
        
        var tbyte:[UInt8] = Array(repeating: 0x00, count: 20)
        VPBleCentralManage.sharedBleManager()
            .peripheralModel.deviceSwitchData.copyBytes(to: &tbyte, count: 20)
        NSLog("Switch data \(tbyte)")
        NSLog("Configuring device BP")
        turnOnSetting(setting: VPSettingBaseFunctionSwitchType.automaticBPTest) {
            NSLog("Configuring device HR")
            self.turnOnSetting(setting: VPSettingBaseFunctionSwitchType.automaticHRTest) {
                NSLog("Configuring device 02")
                self.turnOnSetting(setting: VPSettingBaseFunctionSwitchType.automaticOxygenTest) {
                    NSLog("Configuring device HRV")
                    self.turnOnSetting(setting: VPSettingBaseFunctionSwitchType.automaticHRVTest) {
                        self.turnOffSetting(setting: VPSettingBaseFunctionSwitchType.accurateSleep) {
                            NSLog("Configuring device Sleep")
                        }
                        self.bleManager.peripheralManage.veepooSDKSettingBaseFunctionType(VPSettingBaseFunctionSwitchType.metric, settingState: .settingFunctionClose) { completeState in
                            NSLog("Complete state for HR \(completeState.rawValue)")
                        }
                    }
                }
            }
        }
        self.updateTime()
        
    }
    
    private func scanAndConnectDevice(result:@escaping FlutterResult,deviceId:String){
        bleManager.veepooSDKStartScanDeviceAndReceiveScanningDevice { (deviceInfo) in
            NSLog("Got mac address \(String(describing: deviceInfo?.deviceAddress)) and matching it with \(deviceId)")
            let macAddress = deviceInfo?.deviceAddress.suffix(5).replacingOccurrences(of: ":", with: "")
            NSLog("matching the updated mac address to  \(String(describing: macAddress)) and matching it with \(deviceId)")
            self.deviceFound = true
            if(macAddress == deviceId){
                VPBleCentralManage.sharedBleManager().veepooSDKStopScanDevice()
                VPBleCentralManage.sharedBleManager().veepooSDKConnectDevice(deviceInfo) { state in
                    NSLog("Got connection state \(state)")
                    switch(state){
                    case .BleConnectFailed:
                        let deviceData = ConnectionInfo.init(deviceId: deviceInfo?.deviceAddress, deviceName: deviceInfo?.deviceName, connected: false, deviceFound: true, message: "Failed", deviceType: AppDelegate.B360_DEVICE)
                        self.sendConnectionResponse(connInfo: deviceData, result: result)
                    case .BleConnectSuccess:
                        NSLog("Got connction success sending response ")
                        let deviceData = ConnectionInfo.init(deviceId: deviceInfo?.deviceAddress, deviceName: deviceInfo?.deviceName, connected: true, deviceFound: true, message: "connected", deviceType: AppDelegate.B360_DEVICE)
                        self.sendConnectionResponse(connInfo: deviceData, result: result)
                        self.connectionInfo = deviceData
                        self.sendHeartBeat(deviceId: deviceData.deviceId!, macAddress: deviceData.deviceId!)
                    case .BleVerifyPasswordSuccess:
                        NSLog("Password success")
                    case .BleConnecting:
                        NSLog("Connecting to watch")
                    case .BlePoweredOff:
                        NSLog("Bluetooth powered off")
                    case .BleVerifyPasswordFailure:
                        NSLog("Password failure")
                    default:
                        NSLog("Invalid status")
                    }
                }
            }
        }
    }
    
    func syncData(connectionInfo: ConnectionInfo,result: @escaping FlutterResult){
        let deviceConnected = bleManager.isConnected
        self.connectionInfo = connectionInfo
        if(self.deviceId == nil){
            self.deviceId = connectionInfo.deviceId
        }
        self.result = result
        NSLog("Is device conected \(deviceConnected)")
        if(deviceConnected){
            self.configureDevice()
            syncDataFromDevice()
        }else{
            reConnectDevice()
        }
    }
    
    func getCurrentDeviceStatus(connInfo: ConnectionInfo, result:@escaping FlutterResult){
        self.connectionInfo = connInfo
        if(!bleManager.isConnected){
            reConnectDevice { connectionStatus in
                self.generateStatusResponse(connInfo: connInfo, result: result)
            }
        }else{
            self.generateStatusResponse(connInfo: connInfo, result: result)
        }
    }
    
    private func sendHeartResponse(heartRate:UInt,eventSink events: @escaping FlutterEventSink){
        do{
            let returnData = HeartRateDataValue(data: heartRate, measureTime: Date().iso8601withFractionalSeconds)
            let returnDataValue = String(data: try JSONEncoder().encode(returnData), encoding: .utf8)!
            NSLog("Returning Heart rate \(returnDataValue)")
            events(returnDataValue)
        }
        catch{
            NSLog("Error while sending HR value \(error)")
        }
    }
    
    private func sendO2LevelResponse(o2Level:UInt,eventSink events: @escaping FlutterEventSink){
        do{
            let returnData = O2LevelDataValue(data: o2Level, measureTime: Date().iso8601withFractionalSeconds)
            let returnDataValue = String(data: try JSONEncoder().encode(returnData), encoding: .utf8)!
            NSLog("Returning O2 rate \(returnDataValue)")
            events(returnDataValue)
        }
        catch{
            NSLog("Error while sending HR value \(error)")
        }
    }
    
    func readDataFromDevice(eventSink events: @escaping FlutterEventSink,readingType:String){
        NSLog("Processing B360 reading type \(readingType.uppercased())")
        let userProfile = DataSync.getUserInfo()
        switch readingType.uppercased() {
        case AppDelegate.HR:
            NSLog("Processing heart rate")
            var startDate = Date()
            bleManager.peripheralManage.veepooSDKTestHeartStart(true) { hrTestState, heartRate in
                switch hrTestState {
                case .over:
                    NSLog("Heart rate complete")
                    events(FlutterEndOfEventStream)
                case .testing:
                    NSLog("Heart rate testing")
                    if(heartRate>0){
                        self.sendHeartResponse(heartRate: heartRate, eventSink: events)
                        if(Date().timeIntervalSince(startDate) > 15){
                            self.bleManager.peripheralManage.veepooSDKTestHeartStart(false) { heartRateState, heartRate in
                                NSLog("Completed Heart date")
                                events(FlutterEndOfEventStream)
                            }
                            let heartRateUploads = [HeartRateUpload(measureTime: Date(), heartRate: Int(heartRate), deviceId: self.deviceId!, userProfile: userProfile)]
                            DataSync.uploadHeartRateInfo(heartRates: heartRateUploads)
                            NSLog("Heart rate complete")
                        }
                    }
                case .start:
                    NSLog("Started reading heart rate ")
                default:
                    NSLog("Default for heart rate test")
                }
                
            }
        case AppDelegate.BP:
            NSLog("Processing blood pressure")
            bleManager.peripheralManage.veepooSDKTestBloodStart(true, testMode: 0) { state, progress, systolic, diastolic in
                switch state{
                case .complete:
                    NSLog("BP complete")
                    do{
                        let returnData = BpDataValue(data1: Int(systolic), data2: Int(diastolic),measureTime: Date().iso8601withFractionalSeconds)
                        let returnDataValue = String(data: try JSONEncoder().encode(returnData), encoding: .utf8)!
                        NSLog("Returning Heart rate \(returnDataValue)")
                        events(returnDataValue)
                        events(FlutterEndOfEventStream)
                        let bpUploads = [BpUpload(measureTime: Date(), distolic: Int(diastolic), systolic: Int(systolic), deviceId: self.deviceId!, userProfile: userProfile)]
                        DataSync.uploadBloodPressure(bpLevels: bpUploads)
                    }
                    catch{
                        NSLog("Error while sending BP value \(error)")
                    }
                case .testing:
                    NSLog("Testing BP with \(systolic)/\(diastolic) with progress \(progress)")
                default:
                    NSLog("Got default data with state \(String(describing: state))")
                }
            }
        case AppDelegate.O2:
            NSLog("Processing O2 sats")
            var startDate = Date()
            bleManager.peripheralManage.veepooSDKTestOxygenStart(true) { o2state, o2Level in
                switch o2state{
                case .over:
                    NSLog("O2 complete")
                    events(FlutterEndOfEventStream)
                case .testing:
                    NSLog("Got o2 value \(o2Level)")
                    if(o2Level>0){
                        self.sendO2LevelResponse(o2Level: o2Level, eventSink: events)
                        if(Date().timeIntervalSince(startDate) > 15){
                            self.bleManager.peripheralManage.veepooSDKTestOxygenStart(false) { heartRateState, heartRate in
                                NSLog("Completed o2 sats")
                                events(FlutterEndOfEventStream)
                            }
                            let o2Levels = [OxygenLevelUpload(measureTime: Date(), oxygenLevel: Int(o2Level), deviceId: self.deviceId!, userProfile: userProfile)]
                            DataSync.uploadOxygenLevels(oxygenLevels: o2Levels)
                            NSLog("O2 levels complete")
                        }
                    }
                default:
                    NSLog("Defuault methos for o2 sats with value \(o2Level) and state \(String(describing: o2state))")
                }
            }
        default:
            events(FlutterEndOfEventStream)
        }
    }
    
    private func syncO2Sats(){
        NSLog("Processing O2 sats")
        var startDate = Date()
        let userProfile = DataSync.getUserInfo()
        bleManager.peripheralManage.veepooSDKTestOxygenStart(true) { o2state, o2Level in
            switch o2state{
            case .over:
                NSLog("O2 complete")
            case .testing:
                NSLog("Got o2 value \(o2Level)")
                if(o2Level>0){
                    if(Date().timeIntervalSince(startDate) > 15){
                        self.bleManager.peripheralManage.veepooSDKTestOxygenStart(false) { heartRateState, heartRate in
                            NSLog("Completed o2 sats")
                        }
                        let o2Levels = [OxygenLevelUpload(measureTime: Date(), oxygenLevel: Int(o2Level), deviceId: self.deviceId!, userProfile: userProfile)]
                        DataSync.uploadOxygenLevels(oxygenLevels: o2Levels)
                        NSLog("O2 levels complete")
                    }
                }
            default:
                NSLog("Defuault methos for o2 sats with value \(o2Level) and state \(String(describing: o2state))")
            }
        }
    }
    
    private func generateStatusResponse(connInfo:ConnectionInfo,result:@escaping FlutterResult){
        var connectionInfo = ConnectionInfo()
        connectionInfo.deviceId = connInfo.deviceId
        connectionInfo.connected = bleManager.isConnected
        if(bleManager.isConnected){
            self.bleManager.peripheralManage.veepooSDKReadDeviceBatteryPower { batteryLevel in
                NSLog("Got battery level \(batteryLevel * 25)")
                connectionInfo.batteryStatus = String(describing: batteryLevel*25)
                self.sendConnectionResponse(connInfo: connectionInfo, result: result)
            }
        }else{
            self.sendConnectionResponse(connInfo: connectionInfo, result: result)
        }
    }
    
    func disconnect(result:@escaping FlutterResult,connectionInfo: ConnectionInfo){
        NSLog("Is connected \(bleManager.isConnected)")
        if(bleManager.isConnected){
            //Clear the data on the device
            bleManager.peripheralManage.veepooSDKClearDeviceData()
            //Disconnect the device from SDK
            bleManager.veepooSDKDisconnectDevice()
        }
        result("Success")
    }
    
    func getConnectionStatus(result:@escaping FlutterResult){
        return result(bleManager.isConnected)
    }
    
    private func reConnectDevice(callBack:@escaping (_ status: Bool) -> Void = {_ in }){
        VPBleCentralManage.sharedBleManager().veepooSDKSynchronousPassword(with: .VerifyPasswordType, password: "0000") { syncType in
            switch(syncType){
            case .validationAllSuccess:
                callBack(true)
                self.configureDevice()
                self.syncDataFromDevice()
            case .validationSuccess:
                NSLog("Password validation sucess")
            case .validationFailed,.readFailed :
                callBack(false)
                NSLog("Failed validating password")
            default:
                NSLog("Got password result \(syncType)")
            }
        }
    }

    
    private func syncHeartRate(){
        NSLog("Syncing heart rate data")
        var day = -2;
        let deviceId = connectionInfo?.deviceId ?? ""
        let userInfo = DataSync.getUserInfo()
        var heartRateUploads: [HeartRateUpload] = []
        var stepUploads: [StepUpload] = []
        var dailyStepUploads: [StepUpload] = []
        var caloriesUpload: [CaloriesUpload] = []
        while day<=0 {
            let dateString = getDateString(days: day)
            NSLog("Gettig data for \(dateString)")
            let heartRateData = VPDataBaseOperation.veepooSDKGetOriginalChangeHalfHourData(withDate: dateString, andTableID: connectionInfo?.deviceId)
            if(heartRateData == nil){
                NSLog("Got empty heart rate data for \(dateString)")
            }else{
                let heartRateValues = heartRateData as? Dictionary<String?,Dictionary<String,String>>
                let dailyStepTime = dateTimeFormat.date(from: dateString+" 00:00")!
                var totalDailySteps = 0
                var totalCalories = 0.0
                var totalDistance:Float = 0.0
                heartRateValues?.forEach({ (calculationTime, heartRateData) in
                    let heartRate = Int(heartRateData["heartValue"] ?? "0") ?? 0
                    let steps = Int(heartRateData["stepValue"] ?? "0") ?? 0
                    let calories = Double(heartRateData["calValue"] ?? "0.0") ?? 0.0
                    let distance = Float(heartRateData["disValue"] ?? "0.0") ?? 0.0
                    if(calculationTime != nil){
                        let measureTime = dateTimeFormat.date(from: dateString+" "+calculationTime!)
                        if(measureTime != nil){
                            if(heartRate>0){
                                heartRateUploads.append(HeartRateUpload(measureTime: measureTime!, heartRate: heartRate, deviceId: deviceId, userProfile: userInfo))
                            }
                            if(steps>0){
                                totalDailySteps+=steps
                                totalCalories+=calories
                                totalDistance+=distance
                                stepUploads.append(StepUpload(measureTime: measureTime!, steps: steps, deviceId: deviceId, calories: Int(calories), distance: distance, userProfile: userInfo))
                            }
                        }
                    }
                })
                if(totalDailySteps > 0){
                    dailyStepUploads.append(StepUpload(measureTime: dailyStepTime, steps: totalDailySteps, deviceId: deviceId, calories: Int(totalCalories), distance: totalDistance, userProfile: userInfo))
                    caloriesUpload.append(CaloriesUpload(measureTime: dailyStepTime, calories: Int(totalCalories), deviceId: deviceId, userProfile: userInfo))
                }
            }
            NSLog("Got Heart rate data \(heartRateData ?? [:])")
            day+=1
        }
        
        let params = ["message":"Data Uploaded","HR":String(heartRateUploads.count),"STEPS":String(stepUploads.count),"DAILYSTEPS":String(dailyStepUploads.count)]
        
        DataSync.postLog(action: "DATA UPLOAD", params: params, deviceId: connectionInfo?.deviceId)
        
        //Upload the daily steps
        dailyStepUploads.forEach { dailyStep in
            DataSync.uploadDailySteps(dailySteps: dailyStep)
        }
        
        //Upload the steps
        if(!stepUploads.isEmpty){
            DataSync.uploadSteps(steps: stepUploads)
        }
        
        //Upload heart rate
        if(!heartRateUploads.isEmpty){
            DataSync.uploadHeartRateInfo(heartRates: heartRateUploads)
        }
        
        caloriesUpload.forEach { dailyCalories in
            DataSync.uploadCalories(calories: dailyCalories)
        }
    }
    
    private func syncDeviceData(){
        var day = -2;
        var bpUploads:[BpUpload] = []
        var o2Uploads:[OxygenLevelUpload] = []
        let deviceId = connectionInfo?.deviceId ?? ""
        let userInfo = DataSync.getUserInfo()
        while day<=0 {
            let dateString = getDateString(days: day)
            NSLog("Gettig all data for \(dateString)")
            let o2Sats = VPDataBaseOperation.veepooSDKGetDeviceOxygenData(withDate: dateString, andTableID: connectionInfo?.deviceId) as? [Dictionary<String,String>]
            NSLog("Got o2 sats \(o2Sats)")
            o2Sats?.filter({ data in
                data["OxygenValue"] != "0"
            }).map({ o2Data in
                let measureTime = dateTimeFormat.date(from: dateString+" "+o2Data["Time"]!)!
                let oxygenLevel = Int(o2Data["OxygenValue"] ?? "0") ?? 0
                o2Uploads.append(OxygenLevelUpload(measureTime: measureTime, oxygenLevel: oxygenLevel, deviceId: deviceId, userProfile: userInfo))
            })
            
            let bpInfo = VPDataBaseOperation.veepooSDKGetBloodData(withDate: dateString, andTableID: connectionInfo?.deviceId) as? [Dictionary<String,String>]
            bpInfo?.forEach({ bpData in
                let systolic = Int(bpData["systolic"] ?? "0") ?? 0
                let diastolic = Int(bpData["diastolic"] ?? "0") ?? 0
                let measueTime = dateTimeFormat.date(from: dateString+" "+bpData["Time"]!)!
                if(systolic != 0 && diastolic != 0){
                    bpUploads.append(BpUpload(measureTime: measueTime, distolic: diastolic, systolic: systolic, deviceId: deviceId, userProfile: userInfo))
                }
            })
            
            let params = ["message":"Data Uploaded","O2":String(o2Uploads.count),"BP":String(bpUploads.count)]
            
            DataSync.postLog(action: "DATA UPLOAD", params: params, deviceId: connectionInfo?.deviceId)
            
            NSLog("Got BP info \(bpInfo)")
            
            //let originalSleep = VPDataBaseOperation.veepooSDKGetAccurateSleepData(withDate: dateString, andTableID: connectionInfo?.deviceId) as? [Dictionary<String,Any>]
            //NSLog("original sleep for date \(dateString) \(originalSleep)")
            
            //let sleepInfo = VPDataBaseOperation.veepooSDKGetSleepData(withDate: dateString, andTableID: connectionInfo?.deviceId)
            //NSLog("Got sleep info \(sleepInfo)")
//            sleepInfo?.forEach { sleep in
//
//            }
            
            day+=1
        }
        if(!bpUploads.isEmpty){
            DataSync.uploadBloodPressure(bpLevels: bpUploads)
        }
        
        if(!o2Uploads.isEmpty){
            DataSync.uploadOxygenLevels(oxygenLevels: o2Uploads)
        }
        
    }
    
    private func syncDataFromDevice(){
        NSLog("Getting step data")
        if(self.result != nil){
            self.connectionInfo?.connected = true
            self.sendConnectionResponse(connInfo: self.connectionInfo!, result: self.result!)
            self.result = nil
        }
        self.sendHeartBeat(deviceId: self.connectionInfo?.deviceId ?? "", macAddress: self.connectionInfo?.deviceId ?? "")
        bleManager.peripheralManage.veepooSdkStartReadDeviceAllData { readState, totalDay, cureentDay, currentDayProgress in
            switch(readState){
            case .start:
                NSLog("Start reading data from device")
            case .reading:
                NSLog("Reading \(readState) .Reading \(currentDayProgress) of \(cureentDay) with total \(totalDay)")
            case .complete:
                NSLog("Data sync complete")
                self.syncHeartRate()
                self.syncDeviceData()
                self.syncO2Sats()
            case .invalid:
                NSLog("Error reading data from the device")
            default:
                NSLog("Default action for reading data")
            }
        }
    }
    
    private func sendHeartBeat(deviceId: String, macAddress: String){
        DataSync.sendHeartBeat(heartBeat: HeartBeat(deviceId: deviceId, macAddress: macAddress))
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let userInfo = DataSync.getUserInfo()
            if(userInfo != nil){
                let year = Calendar.current.component(.year, from: Date())
                VPBleCentralManage.sharedBleManager().peripheralManage.veepooSDKSynchronousPersonalInformation(withStature: UInt(userInfo!.heightInCm), weight: UInt(userInfo!.weightInKgs), birth: (UInt(year-userInfo!.age)), sex: userInfo!.sex.uppercased() == "MALE" ? 0:1, targetStep: 5000) { response in
                    NSLog("Got profile sync response \(response)")
                }
            }
        }
    }
    
    private func sendInvalidResponse(result:@escaping FlutterResult){
        VPBleCentralManage.sharedBleManager().veepooSDKStopScanDevice()
        let deviceInfo = ConnectionInfo.init(deviceId: "", deviceName: "", connected: false, deviceFound: false, message: "Failed", deviceType: AppDelegate.B360_DEVICE)
        self.sendConnectionResponse(connInfo: deviceInfo, result: result)
    }
    
    private func sendConnectionResponse(connInfo: ConnectionInfo,result:@escaping FlutterResult){
        do{
            let deviceJson = try JSONEncoder().encode(connInfo)
            let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
            NSLog("Sending connection info \(connectionInfoData)")
            result(connectionInfoData)
        }catch{
            NSLog("Got error while adding device \(error)")
            result("Error")
        }
    }
    
    private func getDateString(days: Int) -> String{
        let todayDate = Date(timeIntervalSinceNow: 0)
        let currentCalendar = Calendar.current
        
        let date = currentCalendar.date(byAdding: .day, value: days, to: todayDate)
        
        let year = currentCalendar.component(.year, from: date!)
        
        let month = currentCalendar.component(.month, from: date!)
        
        let day = currentCalendar.component(.day, from: date!)
        
        return String(year) + "-" + String(format: "%02d", month) + "-" + String(format: "%02d", day)
        
    }
}
