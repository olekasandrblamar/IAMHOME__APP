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
        NSLog("Scanning for devices")
        HardManagerSDK.shareBLEManager()?.scanDevices(["ITPOWER01"])
       
    }
    
    func didFindDevice(_ device: CBPeripheral!) {
        let deviceName = device.name
        let deviceUUID = device.identifier.uuidString
        NSLog("Got device \(deviceName ?? "No name ") - \(deviceUUID)")
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
    }
    
    func deviceDidConnected() {
        NSLog("Device connected")
        HardManagerSDK.shareBLEManager()?.stopScanDevice()
        NSLog("Scanning connected")
        HardManagerSDK.shareBLEManager()?.setHardTimeUnitAndUserProfileIs12(true, isMeter: false, sex: 0, age: 32, weight: 80, height: 178)
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
                NSLog("Connection data \(connectionInfoData)")
                result?(connectionInfoData)
            }catch{result?("Error")}
        }
    }
    
    func settingFallBack(_ option: HardSettingOption, status: HardOptionStatus) {
        
    }
    
    private func syncTemparature(tempArray:[[String:String]]){
        
        let temperatureUploads = tempArray.map { (tempMap) -> TemperatureUpload in
            let measureDate = dateTimeFormat.date(from: tempMap["timePoint"]!)!
            let celsius = Double(tempMap["temperature"]!)
            return TemperatureUpload(measureTime: measureDate, celsius: celsius!, deviceId: WatchData.currentDeviceId!)
        }
        DataSync.uploadTemparatures(temps: temperatureUploads)
    }
    
    private func syncHearRate(heartRateArray:[[String:String]]){
        var bpUploads:[BpUpload] = []
        var oxygenUploads: [OxygenLevelUpload] = []
        let heartRateUploads = heartRateArray.map { (heartMap) -> HeartRateUpload in
            let measureDate = dateTimeFormat.date(from: heartMap["testMomentTime"]!)
            let heartRate = Int(heartMap["currentRate"]!)
            let distolic = Int(heartMap["diastolicPressure"]!)
            let systolic = Int(heartMap["systolicPressure"]!)
            let oxygenLevel = Int(heartMap["oxygen"]!)
            bpUploads.append(BpUpload(measureTime: measureDate!, distolic: distolic!, systolic: systolic!, deviceId: WatchData.currentDeviceId!))
            oxygenUploads.append(OxygenLevelUpload(measureTime: measureDate!,oxygenLevel: oxygenLevel!,deviceId: WatchData.currentDeviceId!))
            return HeartRateUpload(measureTime: measureDate!, heartRate: heartRate!, deviceId: WatchData.currentDeviceId!)
        }
        DataSync.uploadHeartRateInfo(heartRates: heartRateUploads)
        DataSync.uploadBloodPressure(bpLevels: bpUploads)
        DataSync.uploadOxygenLevels(oxygenLevels: oxygenUploads)
    }
    
    private func syncStepInfo(stepInfo: [String: Any]){
        let dateString:String = stepInfo["date"] as! String
        NSLog("Got date String %@", dateString)
        let stepDate = self.dayFormat.date(from: dateString)
        NSLog("Got converted date \(stepDate) ")
        let calories = Int(stepInfo["calories"] as! String)
        let dailySteps = Int(stepInfo["step"] as! String)
        NSLog("Date \(stepDate) calories: \(calories) dailySteps \(dailySteps)")
        
        let hourlySteps = stepInfo["stepOneHourInfo"] as! [String:String]
        let stepList = hourlySteps.map { (stepMap) -> StepUpload in
            let (stepMinutes, stepsCount) = stepMap
            let stepTime = Calendar.current.date(byAdding: .minute,value: Int(stepMinutes)!, to: stepDate!)
            return StepUpload(measureTime: stepTime!, steps: Int(stepsCount)!, deviceId: WatchData.currentDeviceId!)
            
        }
        let dailyStepsUpload = StepUpload(measureTime: stepDate!, steps: dailySteps!, deviceId: WatchData.currentDeviceId!)
        let dailyCaloriesUpload = CaloriesUpload(measureTime: stepDate!, calories: calories!, deviceId: WatchData.currentDeviceId!)
        DataSync.uploadCalories(calories: dailyCaloriesUpload)
        DataSync.uploadSteps(steps: stepList)
        DataSync.uploadDailySteps(dailySteps: dailyStepsUpload)
    }
    
    func syncData(connectionInfo:ConnectionInfo){
        
        NSLog("Device connected \(HardManagerSDK.shareBLEManager().isConnected)")
        if(!HardManagerSDK.shareBLEManager().isConnected){
            //WatchData.currentDeviceId = connectionInfo.additionalInformation["macId"]
            WatchData.currentDeviceId = connectionInfo.deviceId
            HardManagerSDK.shareBLEManager().startConnectDevice(withUUID: connectionInfo.deviceId)
        }else if(HardManagerSDK.shareBLEManager().isConnected && !HardManagerSDK.shareBLEManager().isSyncing){
            NSLog("Syncing data")
            let last24Hours = Calendar.current.date(byAdding: .hour,value: -24, to: Date())
            HardManagerSDK.shareBLEManager().getHardExercise(with: last24Hours)
            HardManagerSDK.shareBLEManager().getHardStepDaysAgo(0)
            for days:Int32 in 0...2{
                HardManagerSDK.shareBLEManager().getHardHeartDaysAgo(days)
            }
            let last2Days = Calendar.current.date(byAdding: .day,value: -2, to: Date())
            HardManagerSDK.shareBLEManager()?.getHardHistoryBodyTemperature(last2Days)
        }
    }
    
    func didFindDeviceDict(_ deviceDict: [AnyHashable : Any]!) {
        let peripharal = deviceDict["peripheral"] as? CBPeripheral
        let uuid = peripharal?.identifier.uuidString
        let deviceName = peripharal?.name
        NSLog("Got device \(deviceName ?? "No name ") - \(uuid)")
        let stringLength:Int = deviceId?.count ?? 4
        let deviceSuffix = String(uuid?.suffix(stringLength) as! Substring)
        
        //6987
        //if( deviceSuffix == deviceId){
        if(self.device == nil){
            self.device = peripharal
            NSLog("Connecting to device \(deviceName ?? "No name ") - \(uuid)")
            HardManagerSDK.shareBLEManager()?.startConnectDevice(withUUID: uuid)
        }
        //}
        
        
    }
    
}
