//
//  WatchData.swift
//  Runner
//
//  Created by Shyam Alapati on 8/3/20.
//

import Foundation

class WatchData: NSObject,HardManagerSDKDelegate{
    
    var result:FlutterResult? = nil
    var deviceId:String? = nil
    var device:CBPeripheral? = nil
    var dayFormat = DateFormatter()
    var dateTimeFormat = DateFormatter()
    static var currentDeviceId:String? = nil
    
    override init() {
        super.init()
        self.dayFormat.dateFormat = "yyyy-MM-dd"
        self.dateTimeFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        HardManagerSDK.shareBLEManager()?.delegate = self
    }
    
    func startScan(result:@escaping FlutterResult,deviceId:String) {
        self.result = result
        self.deviceId = deviceId
        NSLog("Scanning for devices with result")
        HardManagerSDK.shareBLEManager()?.scanDevices(["ITPOWER01"])
       
    }
    
    func didFindDevice(_ device: CBPeripheral!) {
        let deviceName = device.name
        let deviceUUID = device.identifier.uuidString
        NSLog("Got device in dif find device \(deviceName ?? "No name ") - \(deviceUUID)")
    }
    
    func gettingFallBack(_ option: HardGettingOption, values: [AnyHashable : Any]!) {
        //NSLog("Got option \(option.rawValue) value %@", values)
        //For tempartire History
        if(option == HardGettingOption.bodyTemperatureHistory){
            let tempArray = values["temperatureArray"] as! [[String:String]]
            syncTemparature(tempArray: tempArray)
        }
        if(option == HardGettingOption.stepDetail){
            let stepData = values as! [String:Any]
            syncStepInfo(stepInfo: stepData)
        }
        if(option == HardGettingOption.heart){
            print("values \(values["hearts"])")
            if(values["hearts"] != nil){
                let heartRateData = values["hearts"] as! [[String:String]]
                syncHearRate(heartRateArray: heartRateData)
            }
            
        }
        
    }
    
    func connectedDeviceMacDidUpdate(_ hardManager: HardManagerSDK!) {
        NSLog("Mac updated \(hardManager.connectedDeviceMAC)")
        if(hardManager.connectedDeviceMAC != nil){
            UserDefaults.standard.set(hardManager.connectedDeviceMAC!,forKey: DataSync.MAC_ADDRESS_NAME)
        }
    }
    
    func getCurrentDeviceStatus(connInfo: ConnectionInfo, result:@escaping FlutterResult){
        var connectionInfo = ConnectionInfo()
        connectionInfo.deviceId = getMacId()
        NSLog("Got mac id \(connectionInfo.deviceId)")
        connectionInfo.connected = HardManagerSDK.shareBLEManager()?.isConnected
        if(connectionInfo.connected == nil || !connectionInfo.connected!){
            HardManagerSDK.shareBLEManager().startConnectDevice(withUUID: connInfo.deviceId!)
        }
        do{
            let deviceJson = try JSONEncoder().encode(connectionInfo)
            let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
            NSLog("Sending Connection data back from device info \(connectionInfoData)")
            result(connectionInfoData)
        }catch{
            NSLog("Error getting watch info from getDeviceInfo \(error)")
            result("Error")
            
        }
    }
    
    func deviceDidConnected() {
        NSLog("Device connected")
        HardManagerSDK.shareBLEManager()?.stopScanDevice()
        NSLog("Scanning connected")
        
        var userSex = 0
        var age:Int = 32
        var height:Int = 170
        var weight:Int = 60
        let userProfileData = DataSync.getUserInfo()
        if(userProfileData != nil){
            NSLog("updating user info from local storage")
            userSex = userProfileData!.sex.uppercased() == "MALE" ? 0:1
            age = userProfileData!.age
            height = userProfileData!.heightInCm
            weight = Int(userProfileData!.weightInKgs)
        }
        HardManagerSDK.shareBLEManager()?.setHardTimeUnitAndUserProfileIs12(true, isMeter: false, sex: Int32(userSex), age: Int32(age), weight: Int32(weight), height: Int32(height))
        //Enable auto heart rate test
        HardManagerSDK.shareBLEManager()?.setHardAutoHeartTest(true)
        //Enable Temp type to F
        HardManagerSDK.shareBLEManager()?.setHardTemperatureType(true)
        let macId = HardManagerSDK.shareBLEManager()?.connectedDeviceMAC
        NSLog("Got Mac id \(macId)")
        
        if(device != nil){
            let deviceName = device?.name
            let uuid = device?.identifier.uuidString
            
            
            NSLog("Device connected \(deviceName ?? "No name ") - \(uuid)")
            var connectionInfo = ConnectionInfo(deviceId: uuid, deviceName: deviceName, connected: true, message: "connected")
            connectionInfo.additionalInformation["factoryName"] = device!.description
            connectionInfo.additionalInformation["macId"] = macId
            if(uuid != nil){
                WatchData.currentDeviceId = uuid!
            }
            do{
                let deviceJson = try JSONEncoder().encode(connectionInfo)
                let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
                NSLog("Connection data after initial connection \(connectionInfoData)")
                UserDefaults.standard.set(AppDelegate.WATCH_TYPE,forKey: AppDelegate.DEVICE_TYPE_KEY)
                //If it not the first time load the device Data
                result?(connectionInfoData)
                loadData(deviceId: WatchData.currentDeviceId)
            }catch{result?("Error")}
            
        }else{
            if(result == nil){
                loadData(deviceId: WatchData.currentDeviceId)
            }
        }
    }
    
    func settingFallBack(_ option: HardSettingOption, status: HardOptionStatus) {
        
    }
    
    private func getMacId() -> String{
        let macAddress = UserDefaults.standard.string(forKey: DataSync.MAC_ADDRESS_NAME)
        if(macAddress != nil){
            return macAddress!
        }
        return WatchData.currentDeviceId!
    }
    
    private func syncTemparature(tempArray:[[String:String]]){
        let deviceId = getMacId()
        let temperatureUploads = tempArray.map { (tempMap) -> TemperatureUpload in
            var measureDate = dateTimeFormat.date(from: tempMap["timePoint"]!)!
            if(TimeZone.current.isDaylightSavingTime(for: measureDate)){
                measureDate = measureDate.addingTimeInterval(60) // 60 minutes if it DST
            }
            let celsius = Double(tempMap["temperature"]!)
            return TemperatureUpload(measureTime: measureDate, celsius: celsius!, deviceId: deviceId)
        }
        DataSync.uploadTemparatures(temps: temperatureUploads)
    }
    
    private func syncHearRate(heartRateArray:[[String:String]]){
        var bpUploads:[BpUpload] = []
        var oxygenUploads: [OxygenLevelUpload] = []
        let deviceId = getMacId()
        let heartRateUploads = heartRateArray.map { (heartMap) -> HeartRateUpload in
            let measureDate = dateTimeFormat.date(from: heartMap["testMomentTime"]!)
            let heartRate = Int(heartMap["currentRate"]!)
            let distolic = Int(heartMap["diastolicPressure"]!)
            let systolic = Int(heartMap["systolicPressure"]!)
            let oxygenLevel = Int(heartMap["oxygen"]!)
            bpUploads.append(BpUpload(measureTime: measureDate!, distolic: distolic!, systolic: systolic!, deviceId: deviceId))
            oxygenUploads.append(OxygenLevelUpload(measureTime: measureDate!,oxygenLevel: oxygenLevel!,deviceId:deviceId))
            return HeartRateUpload(measureTime: measureDate!, heartRate: heartRate!, deviceId: deviceId)
        }
        DataSync.uploadHeartRateInfo(heartRates: heartRateUploads)
        DataSync.uploadBloodPressure(bpLevels: bpUploads)
        DataSync.uploadOxygenLevels(oxygenLevels: oxygenUploads)
    }
    
    private func syncStepInfo(stepInfo: [String: Any]){
        let deviceId = getMacId()
        let dateString:String = stepInfo["date"] as! String
        NSLog("Got date String %@", dateString)
        let stepDate = self.dayFormat.date(from: dateString)
        NSLog("Got converted date \(stepDate) ")
        let calories = Int(stepInfo["calories"] as! String)
        let dailySteps = Int(stepInfo["step"] as! String)
        NSLog("Date \(stepDate) calories: \(calories) dailySteps \(dailySteps)")
        var stepList = [StepUpload]()
        if(stepInfo["stepOneHourInfo"] != nil){
            let hourlySteps = stepInfo["stepOneHourInfo"] as! [String:String]
            stepList = hourlySteps.map { (stepMap) -> StepUpload in
                let (stepMinutes, stepsCount) = stepMap
                let stepTime = Calendar.current.date(byAdding: .minute,value: Int(stepMinutes)!, to: stepDate!)
                return StepUpload(measureTime: stepTime!, steps: Int(stepsCount)!, deviceId: deviceId)
                
            }
        }
        let dailyStepsUpload = StepUpload(measureTime: stepDate!, steps: dailySteps!, deviceId: deviceId)
        let dailyCaloriesUpload = CaloriesUpload(measureTime: stepDate!, calories: calories!, deviceId: deviceId)
        DataSync.uploadCalories(calories: dailyCaloriesUpload)
        DataSync.uploadSteps(steps: stepList)
        DataSync.uploadDailySteps(dailySteps: dailyStepsUpload)
    }
    
    private func loadData(deviceId:String?){
        DataSync.sendHeartBeat(heartBeat: HeartBeat(deviceId: deviceId, macAddress: getMacId()))
        let last24Hours = Calendar.current.date(byAdding: .hour,value: -24, to: Date())
        HardManagerSDK.shareBLEManager().getHardExercise(with: last24Hours)
        HardManagerSDK.shareBLEManager().getHardStepDaysAgo(0)
        for days:Int32 in 0...2{
            HardManagerSDK.shareBLEManager().getHardHeartDaysAgo(days)
        }
        let last2Days = Calendar.current.date(byAdding: .day,value: -2, to: Date())
        HardManagerSDK.shareBLEManager()?.getHardHistoryBodyTemperature(last2Days)
    }
    
    func syncData(connectionInfo:ConnectionInfo){
        NSLog("Device connected \(HardManagerSDK.shareBLEManager().isConnected)")
        if(!HardManagerSDK.shareBLEManager().isConnected){
            result = nil
            //WatchData.currentDeviceId = connectionInfo.additionalInformation["macId"]
            WatchData.currentDeviceId = connectionInfo.deviceId
            HardManagerSDK.shareBLEManager().startConnectDevice(withUUID: connectionInfo.deviceId)
        }else if(HardManagerSDK.shareBLEManager().isConnected && !HardManagerSDK.shareBLEManager().isSyncing){
            NSLog("Syncing data")
            loadData(deviceId: connectionInfo.deviceId)
        }
    }
    
    func didFindDeviceDict(_ deviceDict: [AnyHashable : Any]!) {
        let peripharal = deviceDict["peripheral"] as? CBPeripheral
        let uuid = peripharal?.identifier.uuidString
        let deviceName = peripharal?.name
        NSLog("Got device in dict \(deviceName ?? "No name ") - \(uuid)")
        let stringLength:Int = deviceId?.count ?? 4
        let deviceSuffix = String(deviceName?.suffix(stringLength) as! Substring)
        
        
        if( deviceSuffix.lowercased() == deviceId?.lowercased()){
            if(self.device == nil){
                self.device = peripharal
                NSLog("Connecting to device \(deviceName ?? "No name ") - \(uuid)")
                HardManagerSDK.shareBLEManager()?.startConnectDevice(withUUID: uuid)
            }
        }
        
        
    }
    
}
