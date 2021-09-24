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
    var deviceFound = false
    var deviceConected = false
    static var currentDeviceId:String? = nil
    var statusResult:FlutterResult? = nil
    var upgradeEventSink: FlutterEventSink? = nil
    var statusConnectionInfo: ConnectionInfo? = nil
    var reconnect:Int = 0;
    var eventSink: FlutterEventSink? = nil
    var readingTemperature = false
    var readingHr = false
    var readingBp = false
    var diastolicOffset = 0
    var systolicOffset = 0
    var readingo2 = false
    var upgradeInProcess = false
    var currentFirmWare:String? = nil
    var firmwareVersion = "SW07s_2.56.00_210423"
    var sw07Version = "SW07s_2.45.00_200925"
//    var firmwareVersion = "SW07s_2.56.00_210324"
    
    var batteryComplete = false
    
    override init() {
        super.init()
        self.dayFormat.dateFormat = "yyyy-MM-dd"
        self.dateTimeFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        HardManagerSDK.shareBLEManager()?.delegate = self
    }
    
    func startScan(result:@escaping FlutterResult,deviceId:String) {
        self.result = result
        self.deviceId = deviceId
        self.deviceFound = false
        self.device = nil
        self.deviceConected = false
        NSLog("Scanning for devices with result \(HardManagerSDK.shareBLEManager()?.isConnected)")
        HardManagerSDK.shareBLEManager()?.scanDevices(["ITPOWER01"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            //Stop the scanning after 25 seconds
            if(self.reconnect==0){
                self.reconnect = 1
                HardManagerSDK.shareBLEManager()?.scanDevices(["ITPOWER01"])
                DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                    self.reconnect = 0
                    self.sendResponse(result: result)
                }
            }else{
                self.sendResponse(result: result)
            }
            
        }
       
    }
    
    func sendResponse(result:@escaping FlutterResult){
        HardManagerSDK.shareBLEManager()?.stopScanDevice()
        if(!self.deviceConected){
            var connectionInfo = ConnectionInfo(deviceId: "", deviceName: "", connected: false, deviceFound: self.deviceFound, message: "failed")
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
    }
    
    
    func didFindDevice(_ device: CBPeripheral!) {
        let deviceName = device.name
        let deviceUUID = device.identifier.uuidString
        NSLog("Got device in dif find device \(deviceName ?? "No name ") - \(deviceUUID)")
    }
    
    private func checkAndSendResponse(){
        if(batteryComplete){
            do{
                let deviceJson = try JSONEncoder().encode(statusConnectionInfo)
                let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
                NSLog("Sending Connection data back from battery info \(connectionInfoData)")
                statusResult?(connectionInfoData)
            }catch{
                NSLog("Error getting watch info from battery getDeviceInfo \(error)")
                statusResult?("Error")
            }
        }
    }
    
    func gettingFallBack(_ option: HardGettingOption, values: [AnyHashable : Any]!) {
        //NSLog("Got option \(option.rawValue) value %@", values)
        //For tempartire History
        NSLog("Got option \(option == HardGettingOption.measuringPassively) \(values)")
        if(option == HardGettingOption.bodyTemperatureHistory){
            let tempArray = values["temperatureArray"] as! [[String:String]]
            syncTemparature(tempArray: tempArray)
        }
        else if(option == HardGettingOption.step && values != nil){
            let stepData = values as! [String:Any]
            syncStepInfo(stepInfo: stepData)
        }
        else if(option == HardGettingOption.heart){
            print("values \(values["hearts"])")
            if(values["hearts"] != nil){
                let heartRateData = values["hearts"] as! [[String:String]]
                syncHearRate(heartRateArray: heartRateData)
            }
            
        }
//        else if(option == HardGettingOption.){
//
//        }
        else if(option == HardGettingOption.battery){
            NSLog("battery \(values)")
            do{
                if(values["battery"] != nil){
                    statusConnectionInfo?.batteryStatus = values["battery"] as! String
                }
                batteryComplete = true
                checkAndSendResponse()
             }catch{
                NSLog("Error getting watch info from battery getDeviceInfo \(error)")
                statusResult?("Error")
            }
        }else if(option == HardGettingOption.bodyTemperature){
            NSLog("body temperature \(values)")
            let tempData = values as! [String:String]
            let seconds = Int(tempData["second"] as! String)
            do{
                var returnData = TemperatureReading(countDown: seconds!, celsius: 0, fahrenheit: 0)
                if(seconds==0){
                    let bodyTemp = Double(tempData["bodyTemperature"] as! String)
                    readingTemperature = false
                    returnData.celsius = Double(bodyTemp!)
                    DataSync.uploadTemparatures(temps: [TemperatureUpload(measureTime: Date(), celsius: returnData.celsius, deviceId: getMacId())])
                    returnData.fahrenheit = Double((bodyTemp!*9/5)+32)
                }
                let returnDataValue = String(data: try JSONEncoder().encode(returnData), encoding: .utf8)!
                NSLog("Returning data \(returnDataValue)")
                eventSink?(returnDataValue)
                if(seconds == 0){
                    eventSink?(FlutterEndOfEventStream)
                    eventSink = nil
                }
            }catch{
                let returnData = "{\"error\":\"true\"}"
                eventSink?(returnData)
                eventSink = nil
            }
        }else if(option == HardGettingOption.measuring){
            let tempData = values as! [String:String]
            NSLog("Got values \(values)")
            let type:HardMeasureType = HardMeasureType(rawValue: Int(tempData["type"] as! String)!)!;
            do{
                switch type {
                    case HardMeasureType.heartRate:
                        let heartRateVal = tempData["heart"]
                        NSLog("Heart rate \(heartRateVal)")
                        if(heartRateVal != nil){
                            let heartRate = Int(heartRateVal!)!
                            let returnData = HeartRateReading(heartRate: heartRate)
                            let heartRateUpload = HeartRateUpload(measureTime: Date(), heartRate: returnData.heartRate, deviceId: getMacId(),userProfile: DataSync.getUserInfo())
                            DataSync.uploadHeartRateInfo(heartRates: [heartRateUpload])
                            let returnDataValue = String(data: try JSONEncoder().encode(returnData), encoding: .utf8)!
                            NSLog("Returning HR data \(returnDataValue)")
                            eventSink?(returnDataValue)
                        }
                    
                    case HardMeasureType.bloodOxygen:
                        if (tempData["oxygen"] != nil) {
                            NSLog("Oxygen \(tempData["oxygen"])")
                            let oxygenLevel = Int(tempData["oxygen"] as! String)!
                            if(oxygenLevel>0){
                                let returnData = OxygenLevel(oxygenLevel: oxygenLevel)
                                let oxygenUpload = OxygenLevelUpload(measureTime: Date(), oxygenLevel: oxygenLevel, deviceId: getMacId(), userProfile: DataSync.getUserInfo())
                                DataSync.uploadOxygenLevels(oxygenLevels: [oxygenUpload])
                                let returnDataValue = String(data: try JSONEncoder().encode(returnData), encoding: .utf8)!
                                NSLog("Returning O2 data \(returnDataValue)")
                                self.eventSink?(returnDataValue)
                            }
                        }
                    
                    case HardMeasureType.bloodPressure:
                        if (tempData["systolicPressure"] != nil) {
                            NSLog("Systolic \(values["systolicPressure"]) diastolic \(values["diastolicPressure"]) ")
                        }
                        let systolic = Int(tempData["systolicPressure"] as! String)!
                        if(systolic>0){
                            var returnData = BpReading(systolic: systolic, diastolic: Int(tempData["diastolicPressure"] as! String)!)
                            let userInfo = DataSync.getUserInfo()
                            let bpUpload = BpUpload(measureTime: Date(), distolic: returnData.diastolic, systolic: returnData.systolic, deviceId: getMacId(), userProfile: DataSync.getUserInfo())
                            if(userInfo != nil){
                                returnData.diastolic+=userInfo!.getOffsetValue(readingTypes: ["distolic","diastolic"])
                                returnData.systolic+=userInfo!.getOffsetValue(readingTypes: ["systolic"])
                            }
                            HardManagerSDK.shareBLEManager()?.setBloodPressurePassvielyMeasurementWithHeartRate(returnData.systolic, sp: returnData.diastolic, dp: 0)
                            let returnDataValue = String(data: try JSONEncoder().encode(returnData), encoding: .utf8)!
                            NSLog("Returning BP data \(returnDataValue)")
                            self.eventSink?(returnDataValue)
                        }
                default:
                    NSLog("type not found")
                    
                }
            }catch{
                let returnData = "{\"error\":\"true\"}"
                eventSink?(returnData)
                eventSink = nil
            }
            
        }else if(option == HardGettingOption.measurementEnd){
            NSLog("Measuring end \(values)")
            let tempData = values as! [String:String]
            NSLog("Got values \(values)")
            let type:HardMeasureType = HardMeasureType(rawValue: Int(tempData["type"] as! String)!)!;
            switch type {
                case HardMeasureType.heartRate:
                    readingHr = false
                    eventSink?(FlutterEndOfEventStream)
                    eventSink = nil
                case HardMeasureType.bloodOxygen:
                    readingo2 = false
                    eventSink?(FlutterEndOfEventStream)
                    eventSink = nil
                case HardMeasureType.bloodPressure:
                    readingBp = false
                    eventSink?(FlutterEndOfEventStream)
                    eventSink = nil
                default:
                    NSLog("type not found")
                
            }
        }else if(option == HardGettingOption.measuringPassively){
            let bpData = values as? [String:Int]
            NSLog("Passive dat \(bpData)")
            if(bpData != nil){
                let hr = bpData!["rate"]!
                var dp = bpData!["dp"]!
                var sp = bpData!["sp"]!
                
                var userInfo = DataSync.getUserInfo()
                if(userInfo != nil){
                    diastolicOffset = userInfo!.getOffsetValue(readingTypes: ["diastolic","distolic"])
                    systolicOffset = userInfo!.getOffsetValue(readingTypes: ["systolic"])
                }
                
                if(dp>0){
                    dp = dp+diastolicOffset
                }
                if(sp>0){
                    sp = sp+systolicOffset
                }
                
                
                HardManagerSDK.shareBLEManager()?.setBloodPressurePassvielyMeasurementWithHeartRate(sp, sp: dp, dp: hr)
            }
        }else if(option == HardGettingOption.firmworkUpgradeProgress){
            NSLog("Got upgrade status \(values)")
            let upgradeStatus = values as? [String:Int]
            let upgradePercentage = upgradeStatus!["upgradeProgress"]
            if(upgradePercentage != nil){
                NSLog("Got update percentage \(upgradePercentage!)")
                let message = "Upgrade progress "+String(upgradePercentage!)+" %"
                self.sendUpgradeMessage(status: "Success", message: message)
                
            }
        }
            
    }
    
    func hardManager(_ manager: HardManagerSDK!, firmwareUpgradeStep step: HardFirmwareUpgradeStep, result: HardFirmwareUpgradStepResult) {
        NSLog("Step \(step.rawValue)")
        NSLog("Result \(result.rawValue)")
        if(step == HardFirmwareUpgradeStep.finished){
            UserDefaults.standard.removeObject(forKey: DataSync.USER_PROFILE_DATA)
            upgradeInProcess = false
            self.sendUpgradeMessage(status: "Success", message: "Upgrade complete ",complete: true)
        }else if(result == HardFirmwareUpgradStepResult.internalError
                    || result == HardFirmwareUpgradStepResult.commandFormatWrong
                    || result == HardFirmwareUpgradStepResult.dataWrong
                    || result == HardFirmwareUpgradStepResult.dataSizeWrong
                    || result == HardFirmwareUpgradStepResult.commandStatusMismatch){
            self.sendUpgradeMessage(status: "Error", message: "Error while upgrading ",complete: true)
        }else if(result == HardFirmwareUpgradStepResult.batteryTooLow){
            self.sendUpgradeMessage(status: "Error", message: "Battery too low ",complete: true)
        }
        
    }
    
    func hardManager(_ manager: HardManagerSDK!, firmwareUpgradeNextStep step: HardFirmwareUpgradeStep) {
//        if(step == HardFirmwareUpgradeStep.finished){
//            upgradeInProcess = false
//            //self.sendUpgradeMessage(status: "Success", message: "Upgrade Sucessful", complete: true)
//            //UserDefaults.standard.removeObject(forKey: DataSync.USER_PROFILE_DATA)
//        }
    }
    
    func connectedDeviceMacDidUpdate(_ hardManager: HardManagerSDK!) {
        NSLog("Mac updated \(hardManager.connectedDeviceMAC)")
        if(hardManager.connectedDeviceMAC != nil){
            UserDefaults.standard.set(hardManager.connectedDeviceMAC!,forKey: DataSync.MAC_ADDRESS_NAME)
        }
    }
    
    func getConnectionStatus(result:@escaping FlutterResult){
        if(HardManagerSDK.shareBLEManager() == nil ){
            return result(false)
        }else{
            return result(HardManagerSDK.shareBLEManager()!.isConnected)
        }
    }
    
    
    func upgradeDevice(connectionInfo:ConnectionInfo, eventSink upgradeSink: @escaping FlutterEventSink){
        var connectionInfo = ConnectionInfo()
        connectionInfo.deviceId = getMacId()
        connectionInfo.connected = HardManagerSDK.shareBLEManager()?.isConnected
        NSLog("Got mac id \(connectionInfo.deviceId)")
        self.upgradeEventSink = upgradeSink
        do{
            if(connectionInfo.connected != nil && connectionInfo.connected!){
                NSLog("Trying to upgrade")
                var updateFile = firmwareVersion
                if(self.currentFirmWare != nil && self.currentFirmWare!.lowercased().starts(with: "sw07_")){
                    updateFile = sw07Version;
                }
                let upgradePath = Bundle.main.path(forResource: updateFile, ofType: "bin", inDirectory: "HardSDK")
                NSLog("Upgrade path \(upgradePath)")

                let errorPtr: NSErrorPointer = nil
                HardManagerSDK.shareBLEManager().setUpgradeDeviceFirmwareWithFilePath(upgradePath,error: errorPtr)
                upgradeInProcess = true
                NSLog("Fired the update ")
                if(errorPtr != nil){
                    NSLog("Error while upgrading")
                    let error:NSError? = errorPtr?.pointee
                    self.sendUpgradeMessage(status: "Error", message: "Error while upgrading", complete: true)
                }
            }
        }
        catch{
            NSLog("Error upgrading watch\(error)")
            upgradeInProcess = false
            self.sendUpgradeMessage(status: "Error", message: "Error while upgrading", complete: true)
        }
    }
    
    func sendUpgradeMessage(status: String,message:String,complete:Bool = false){
        var returnValue = ["status":status,"message":message]
        do{
            let returnDataValue = String(data: try JSONEncoder().encode(returnValue), encoding: .utf8)!
            self.upgradeEventSink?(returnDataValue)
            if(complete){
                self.upgradeEventSink?(FlutterEndOfEventStream)
            }
        }catch{
            self.upgradeEventSink?(FlutterEndOfEventStream)
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
            if(connectionInfo.connected != nil && connectionInfo.connected! && !upgradeInProcess){
                batteryComplete = false
                HardManagerSDK.shareBLEManager()?.getHardBattery()
                let version = HardManagerSDK.shareBLEManager()?.firmwareVersion
                
                NSLog("got verison \(version)")
                connectionInfo.upgradeAvailable = false
                self.currentFirmWare = version
                
                //Check the version and if it is not the latest version, update the device
                if(version != nil && version!.lowercased().starts(with: "sw07s") && version?.lowercased() != firmwareVersion.lowercased()){
                    connectionInfo.upgradeAvailable = true
                    
                }else if(version != nil && version!.lowercased().starts(with: "sw07_") && version?.lowercased() != sw07Version.lowercased()){
                    connectionInfo.upgradeAvailable = true
                }
                
                //HardManagerSDK.shareBLEManager()?.getHardFirmwareVersionFormServe()
                statusConnectionInfo = connectionInfo
                statusResult = result
            }else{
                let deviceJson = try JSONEncoder().encode(connectionInfo)
                let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
                NSLog("Sending Connection data back from device info \(connectionInfoData)")
                result(connectionInfoData)
            }
        }catch{
            NSLog("Error getting watch info from getDeviceInfo \(error)")
            result("Error")
        }
    }
    
    func disconnect(result:@escaping FlutterResult,connectionInfo: ConnectionInfo){
        NSLog("Is connected \(HardManagerSDK.shareBLEManager().isConnected)")
        if(HardManagerSDK.shareBLEManager().isConnected){
            HardManagerSDK.shareBLEManager()?.restoreFactorySettings();
            HardManagerSDK.shareBLEManager()?.disconnectHardDevice()
        }
        self.device = nil
        result("Success")
    }

    func deviceDidConnected() {
        self.reconnect = 0
        NSLog("Device connected")
        HardManagerSDK.shareBLEManager()?.stopScanDevice()
        NSLog("Scanning connected")
        
        self.syncDeviceInfo();
        let macId = HardManagerSDK.shareBLEManager()?.connectedDeviceMAC
        NSLog("Got Mac id \(macId)")
        
        if(device != nil){
            let deviceName = device?.name
            let uuid = device?.identifier.uuidString

            
            NSLog("Device connected \(deviceName ?? "No name ") - \(uuid)")
            var connectionInfo = ConnectionInfo(deviceId: uuid, deviceName: deviceName, connected: true, deviceFound: self.deviceFound, message: "connected",deviceType: AppDelegate.WATCH_TYPE)
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
        DataSync.uploadTemparatures(temps: temperatureUploads.filter({ (tempUpload) -> Bool in
            tempUpload.celsius != 0 && tempUpload.measureTime.timeIntervalSince1970 > 10000
        }))
    }
    
    private func syncHearRate(heartRateArray:[[String:String]]){
        var bpUploads:[BpUpload] = []
        var oxygenUploads: [OxygenLevelUpload] = []
        let deviceId = getMacId()
        var heartRateUploads: [HeartRateUpload] = []
        heartRateArray.forEach{ (heartMap) in
            let measureDate = dateTimeFormat.date(from: heartMap["testMomentTime"]!)
            let heartRate = Int(heartMap["currentRate"] ?? "0")
            let distolic = Int(heartMap["diastolicPressure"] ?? "0")
            let systolic = Int(heartMap["systolicPressure"] ?? "0")
            let oxygenLevel = Int(heartMap["oxygen"] ?? "0")
            
            //Only upload valid values and ignore 0 values
            if( distolic != nil && distolic != 0 && measureDate != nil && measureDate!.timeIntervalSince1970 > 10000){
                bpUploads.append(BpUpload(measureTime: measureDate!, distolic: distolic ?? 0, systolic: systolic ?? 0, deviceId: deviceId, userProfile: DataSync.getUserInfo()))
            }
            if(oxygenLevel != nil && oxygenLevel != 0 && measureDate != nil && measureDate!.timeIntervalSince1970 > 10000){
                oxygenUploads.append(OxygenLevelUpload(measureTime: measureDate!,oxygenLevel: oxygenLevel!,deviceId:deviceId, userProfile: DataSync.getUserInfo()))
            }
            if(heartRate != nil && heartRate != 0 && measureDate != nil && measureDate!.timeIntervalSince1970 > 10000){
                heartRateUploads.append(HeartRateUpload(measureTime: measureDate!, heartRate: heartRate!, deviceId: deviceId, userProfile: DataSync.getUserInfo()))
            }
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
        let calories = Int((stepInfo["calories"] ?? "0") as! String )
        let distance = Float((stepInfo["distance"] ?? "0") as! String )
        let dailySteps = Int((stepInfo["step"] ?? "0") as! String)
        NSLog("Date \(stepDate) calories: \(calories) dailySteps \(dailySteps)")
        var stepList = [StepUpload]()
        if(stepInfo["stepOneHourInfo"] != nil){
            let hourlySteps = stepInfo["stepOneHourInfo"] as! [String:String]
            stepList = hourlySteps.map { (stepMap) -> StepUpload in
                let (stepMinutes, stepsCount) = stepMap
                let stepTime = Calendar.current.date(byAdding: .minute,value: Int(stepMinutes)!, to: stepDate!)
                return StepUpload(measureTime: stepTime!, steps: Int(stepsCount)!, deviceId: deviceId, calories: 0, distance: 0, userProfile: DataSync.getUserInfo())
                
            }
        }
        let dailyStepsUpload = StepUpload(measureTime: stepDate!, steps: dailySteps!, deviceId: deviceId, calories: calories!
                                          , distance: distance!, userProfile: DataSync.getUserInfo())
        let dailyCaloriesUpload = CaloriesUpload(measureTime: stepDate!, calories: calories!, deviceId: deviceId, userProfile: DataSync.getUserInfo())
        DataSync.uploadCalories(calories: dailyCaloriesUpload)
        DataSync.uploadSteps(steps: stepList)
        DataSync.uploadDailySteps(dailySteps: dailyStepsUpload)
    }
    
    private func syncDeviceInfo(){
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
            HardManagerSDK.shareBLEManager()?.setHardTimeUnitAndUserProfileIs12(true, isMeter: false, sex: Int32(userSex), age: Int32(age),
                                                                                weight: Int32(weight), height: Int32(height),sbp: 0, dbp: 0,heartWarning: 160,chol: 4.0)
        }
        //Enable auto heart rate test
        HardManagerSDK.shareBLEManager()?.setHardAutoHeartTest(true)
        //Enable Temp type to F
        HardManagerSDK.shareBLEManager()?.setHardTemperatureType(true)
    }

    private func loadData(deviceId:String?){
        DataSync.sendHeartBeat(heartBeat: HeartBeat(deviceId: deviceId, macAddress: getMacId()))
        DataSync.loadWeatherData()
        let last2Days = Calendar.current.date(byAdding: .day,value: -2, to: Date())
        HardManagerSDK.shareBLEManager()?.getHardHistoryBodyTemperature(last2Days)
        let last24Hours = Calendar.current.date(byAdding: .hour,value: -24, to: Date())
        HardManagerSDK.shareBLEManager().getHardExercise(with: last24Hours)
        HardManagerSDK.shareBLEManager().getHardStepDaysAgo(0)
        for days:Int32 in 0...2{
            HardManagerSDK.shareBLEManager().getHardHeartDaysAgo(days)
        }
    }
    
    func loadWeather(tempDataList: [WeatherData]){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd"
        var index:Int32 = 0;
        tempDataList.forEach { (tempData) in
            NSLog("Setting date value \(tempData.time)")
            let date = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(tempData.time)))
            let minTemp = Int(tempData.minTemp)
            let maxTemp = Int(tempData.maxTemp)
            if(index<5){
                NSLog("Setting weather for \(date) index \(index) Temp min \(minTemp) Temp Max \(maxTemp)")
                var currentWeatherType:Int32 = 0
                switch tempData.weatherType {
                case WeatherType.SUNNY:
                    currentWeatherType = 1
                case WeatherType.SNOWY:
                    currentWeatherType = 4
                case WeatherType.CLOUDY:
                    currentWeatherType = 2
                case WeatherType.RAINY:
                    currentWeatherType = 3
                case WeatherType.THUNDER:
                    currentWeatherType = 6
                default:
                    currentWeatherType = 0
                }
                HardManagerSDK.shareBLEManager()?.setHardWeatherSerial(index, date:  date,
                                                                       weatherType: currentWeatherType, temMin: minTemp, temMax: maxTemp, wet: 0, umbralle: false)
            }
            index+=1
        }
        
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
            self.syncDeviceInfo();
            loadData(deviceId: connectionInfo.deviceId)
        }
    }
    
    func readDataFromDevice(eventSink events: @escaping FlutterEventSink,readingType:String){
        if(HardManagerSDK.shareBLEManager().isConnected){
            //Device is connected
            if(readingType == "TEMPERATURE"){
                self.eventSink = events
                self.readingTemperature = true
                HardManagerSDK.shareBLEManager()?.setHardBodyTemperatureMeasurement()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    if(self.readingTemperature){
                        HardManagerSDK.shareBLEManager()?.getHardCurrentTemperature()
                    }else{
                        timer.invalidate()
                    }
                    NSLog("Inside timer")
                }
            }else if(readingType == "HR"){
                self.eventSink = events
                self.readingHr = true
                HardManagerSDK.shareBLEManager()?.setStartHeartMeasurement()
            }else if(readingType == "BP"){
                self.eventSink = events
                self.readingBp = true
                HardManagerSDK.shareBLEManager()?.setStartBloodPressureMeasurement()
            }else if(readingType == "O2"){
                self.eventSink = events
                self.readingo2 = true
                HardManagerSDK.shareBLEManager()?.setStartBloodOxygenMeasurement()
            }else{
                events(FlutterEndOfEventStream)
            }
        }else{
            NSLog("Device is not conected")
            events(FlutterEndOfEventStream)
        }
    }
    
    func didFindDeviceDict(_ deviceDict: [AnyHashable : Any]!) {
        let peripharal = deviceDict["peripheral"] as? CBPeripheral
        let uuid = peripharal?.identifier.uuidString
        let deviceName = peripharal?.name
        self.deviceFound = true
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
