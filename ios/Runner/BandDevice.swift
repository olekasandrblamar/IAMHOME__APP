//
//  BandDevice.swift
//  Runner
//
//  Created by Shyam Alapati on 8/17/20.
//

import Foundation
import TrusangBluetooth

class BandDevice{
    
    static var currentDeviceMac:String? = nil
    static var currentDeviceId:String? = nil
    static var syncing = true
    let btProvider = ZHJBLEManagerProvider.shared
    let syncTimeProcessor = ZHJSyncTimeProcessor()
    let deviceConfigProcessor = ZHJDeviceConfigProcessor()
    let temperatureProcessor = ZHJTemperatureProcessor()
    let HR_BP_BOProcessor = ZHJHR_BP_BOProcessor()
    let stepAndSleepProcessor = ZHJStepAndSleepProcessor()
    let userInfoProcessor = ZHJUserInfoProcessor()
    
    
    let MAC_ADDRESS_NAME = "flutter.device_macid"
    
    /**
        Used to connect the device
     */
    func connectDevice(result:@escaping FlutterResult,deviceId:String){
        btProvider.bluetoothProviderManagerStateDidUpdate {[weak self] (state) in
            guard let `self` = self else { return }
            print(state)
            if state == .poweredOn {
                //self.autoReconnect()
                delay(by: 1.0) {
                    self.scanDevice(seconds: 10.0,result: result,deviceId: deviceId)
                }
            }
        }
        
    }
    
    func scanDevice(seconds: TimeInterval,result:@escaping FlutterResult,deviceId:String){
        btProvider.scan(seconds: seconds) {[weak self] (devices) in
            guard let `self` = self else { return }
            NSLog("Found devices \(devices)")
            if(devices.capacity>0){
                self.btProvider.stopScan()
                var defaultIndex = 0;
                if(BandDevice.currentDeviceMac != nil){
                    defaultIndex = devices.firstIndex(where: {[weak self] (currentDevice) -> Bool in
                        return (currentDevice.mac == BandDevice.currentDeviceMac)
                    })!
                }
                if(defaultIndex>=0){
                let device = devices[defaultIndex]
                
                self.btProvider.connectDevice(device: device, success: { [weak self](p) in
                    guard let `self` = self else { return }
                    var connectionInfo = ConnectionInfo(deviceId: device.mac, deviceName: device.name, connected: true, message: "connected")
                    connectionInfo.additionalInformation["factoryName"] = device.model
                    connectionInfo.additionalInformation["macId"] = device.mac
                    do{
                        let deviceJson = try JSONEncoder().encode(connectionInfo)
                        let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
                        NSLog("Connection data \(connectionInfoData)")
                        self.initialSync()
                        UserDefaults.standard.set(AppDelegate.BAND_TYPE,forKey: AppDelegate.DEVICE_TYPE_KEY)
                        result(connectionInfoData)
                    }catch{result("Error")}
                }, fail: { (p, err) in
                    NSLog("Error while connection")
                }, timeout:{
                    
                })
                }
            }
        }
    }
    
    func syncTime(){
        NSLog("Syncing time")
        syncTimeProcessor.writeTime(ZHJSyncTime.init(Date())) {[weak self] (result) in
            guard let `self` = self else { return }
            delay(by: 0.5) {
                self.syncDeviceConfig()
            }
            NSLog("Got result \(result.rawValue)")
            guard result == .correct else {
                NSLog("Time Sync failure")
                return
            }
            NSLog("Time Sync Success")
        }
    }
    
    func syncDeviceConfig(){
        NSLog("Syncing config")
        deviceConfigProcessor.readDeviceConfig{[weak self] (config) in
            NSLog("Got device config \(config)")
            config.temperatureUnit = ZHJTemperatureUnit.fahrenheit
            config.timeMode = ZHJTimeMode.hour12
            config.trunWrist = true
            config.unit = ZHJUnit.imperial
            self?.deviceConfigProcessor.writeDeviceConfig(config, setHandle: {[weak self] (result) in
                NSLog("Config updated with result \(result)")
                delay(by: 0.5){
                    self?.syncUserInfo()
                }
            })
        }
    }
    
    func initialSync(){
        NSLog("Initial sync ")
        btProvider.discoverWriteCharacteristic {[weak self] (characteristic) in
            guard let `self` = self else { return }
            NSLog("Got charecterstic \(characteristic.properties)")
            delay(by: 0.5) {
                self.syncTime()
            }
        }
        
        
    }
    
    func readTemperature(){
        NSLog("Syncing temperatre")
        let date = DateClass.dateStringOffset(from: DateClass.todayString(), offset: 0)
        NSLog("Syncing temperatre for \(date)")
        let dateFormat = "yyyy-MM-dd HH:mm"
        self.temperatureProcessor.readTemperatureHistoryRecord(date, historyDataHandle: {[weak self] (temperatureModel) in
            let uploadTemps = temperatureModel.details.filter({ (ZHJTemperatureDetail) -> Bool in
                return ZHJTemperatureDetail.wristTemperature>0
            }).map{(model)->TemperatureUpload in
                let date = DateClass.getTimeStrToDate(formatStr: dateFormat,timeStr: model.dateTime)
                let celsius = Double(model.wristTemperature)/100.0
                return TemperatureUpload(measureTime: date, celsius: celsius, deviceId: BandDevice.currentDeviceMac!)
            }
            DataSync.uploadTemparatures(temps: uploadTemps)
            self?.readHeartRate()
        },historyDoneHandle: { [weak self] (obj) in
           self?.readHeartRate()
        })
    }
    
    func readHeartRate(){
        NSLog("Syncing heart rate")
        let date = DateClass.dateStringOffset(from: DateClass.todayString(), offset: 0)
        var hrRecordModels: [ZHJHeartRate] = [ZHJHeartRate]()
        var bpRecordModels: [ZHJBloodPressure] = [ZHJBloodPressure]()
        let dateFormat = "yyyy-MM-dd HH:mm"
        var dataSyncDone = 0
        self.HR_BP_BOProcessor.readHR_BP_BOHistoryRecord(date, historyDataHandle: {[weak self] (HRModel, BPModel, BOModel) in
            
            let hrUploads = HRModel.details.filter({ (ZHJHeartRateDetail) -> Bool in
                return ZHJHeartRateDetail.HR>0
            }).map{(hrModel)->HeartRateUpload in
                return HeartRateUpload(measureTime: DateClass.getTimeStrToDate(formatStr: dateFormat,timeStr: hrModel.dateTime), heartRate: hrModel.HR, deviceId: BandDevice.currentDeviceMac!)
            }
            
            let bpUploads = BPModel.details.map{(bpVal) -> BpUpload in
                return BpUpload(measureTime: DateClass.getTimeStrToDate(formatStr: dateFormat,timeStr: bpVal.dateTime),
                                distolic: bpVal.DBP, systolic: bpVal.SBP, deviceId: BandDevice.currentDeviceMac!)
            }
            
            let oxygenUploads = BOModel.details.filter({ (ZHJBloodOxygenDetail) -> Bool in
                return ZHJBloodOxygenDetail.BO>0
            }).map{(oxygenUpload) -> OxygenLevelUpload in
                return OxygenLevelUpload(measureTime: DateClass.getTimeStrToDate(formatStr: dateFormat, timeStr: oxygenUpload.dateTime), oxygenLevel: oxygenUpload.BO, deviceId: BandDevice.currentDeviceMac!)
                
            }
            
            DataSync.uploadBloodPressure(bpLevels: bpUploads)
            DataSync.uploadHeartRateInfo(heartRates: hrUploads)
            DataSync.uploadOxygenLevels(oxygenLevels: oxygenUploads)
            self?.syncSteps()
            },historyDoneHandle: {[weak self] (obj) in
                self?.syncSteps()
            NSLog("blood pressure complete")
        })
    }
    
    func syncUserInfo() {
        let user = ZHJUserInfo()
        user.sex = 0
        user.height = 170
        user.weight = 600
        user.age = 25
        self.userInfoProcessor.writeUserInfo(user) {[weak self] (result) in
            guard let `self` = self else { return }
            NSLog("Updated user info with \(result == .correct)")
            self.readTemperature()
            guard result == .correct else {
                return
            }
        }
    }
    
    func syncSteps(){
        NSLog("Syncing steps")
        let dateFormat = "yyyy-MM-dd HH:mm"
        let dayFormat = "yyyy-MM-dd"
        let date = DateClass.dateStringOffset(from: DateClass.todayString(), offset: 0)
         self.stepAndSleepProcessor.readStepAndSleepHistoryRecord(date: date, historyDataHandle: {[weak self] (stepModel, sleepModel) in
            var dailySteps = 0
            var dailyCalories = 0
            let stepUploads = stepModel.details.filter({ (ZHJStepDetail) -> Bool in
                return ZHJStepDetail.step>0
            }).map{(step)->StepUpload in
                dailySteps+=step.step
                dailyCalories+=step.calories
                return StepUpload(measureTime: DateClass.getTimeStrToDate(formatStr: dateFormat, timeStr: step.dateTime), steps: step.step, deviceId: BandDevice.currentDeviceMac!)
            }
            NSLog("Got steps \(stepModel.dateTime)")
            if(dailySteps>0){
                let dailyStepsUpload = StepUpload(measureTime: DateClass.getTimeStrToDate(formatStr: dayFormat, timeStr: stepModel.dateTime), steps: dailySteps, deviceId: BandDevice.currentDeviceMac!)
                DataSync.uploadDailySteps(dailySteps: dailyStepsUpload)
            }
            if(dailyCalories>0){
                let dailyCaloryUpload = CaloriesUpload(measureTime: DateClass.getTimeStrToDate(formatStr: dayFormat, timeStr: stepModel.dateTime),calories: dailyCalories,deviceId: BandDevice.currentDeviceMac!)
                DataSync.uploadCalories(calories: dailyCaloryUpload)
            }
            if(stepUploads.count>0){
                DataSync.uploadSteps(steps: stepUploads)
            }
            
            
            },historyDoneHandle: {(obj) in
                NSLog("steps complete")
            })
    }
    
    func processDeviceConfig(){
        deviceConfigProcessor.readDeviceConfig{[weak self] (config) in
            NSLog("Got device config \(config.temperatureUnit == .celsius)")
            config.temperatureUnit = .fahrenheit
            config.timeMode = .hour12
            config.trunWrist = true
            config.unit = .imperial
            config.wearStyle = .leftHand
            delay(by: 0.5){
                self?.deviceConfigProcessor.writeDeviceConfig(config, setHandle: {[weak self] (result) in
                    NSLog("Updated config  with \(result == .correct)")
                    NSLog("Config updated with result \(result == .correct)")
                    delay(by: 0.5){
                        self?.readTemperature()
                    }
                })
            }
        }
    }
    
    func syncData(connectionInfo:ConnectionInfo){
        BandDevice.currentDeviceMac = connectionInfo.deviceId
        DataSync.sendHeartBeat(heartBeat: HeartBeat(deviceId: connectionInfo.deviceId, macAddress: connectionInfo.deviceId))
        btProvider.autoReconnect(success: { [weak self] (p) in
            NSLog("Auto reconnect \(p.state == .connected)")
            NSLog("Device state \(ZHJBLEManagerProvider.shared.deviceState == .connected)")
            delay(by: 0.5){
                self?.temperatureProcessor.setAutoDetectTemperature(interval: 5, isOn: true, setHandle: {[weak self] (result) in
                    NSLog("Temp interval set \(result == .correct)")
                    self?.HR_BP_BOProcessor.setAutoDetectHeartRate(interval: 5, isOn: true, setHandle: {[weak self] (result) in
                        NSLog("Heart Rate set \(result == .correct)")
                        let user = ZHJUserInfo()
                        user.sex = 0
                        user.height = 170
                        user.weight = 600
                        user.age = 25
                        self?.userInfoProcessor.writeUserInfo(user) {[weak self] (result) in
                            guard let `self` = self else { return }
                            self.processDeviceConfig()
                            guard result == .correct else {
                                return
                            }
                        }
                    })
                })
                
            }
            
        }) { (p, err) in
            NSLog("Auto reconnect failure")
        }
    }
    
}

class DateClass {
    // MARK:- 当前年月日字符串
    static func todayString() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: Date())
    }
    // MARK:- 当前年月日时分秒字符串
    static func todayIntegrateString() -> String {
        let dateFormat = DateFormatter()
        // 以中国为准
        let locale = Locale(identifier: "zh")
        dateFormat.locale = locale
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormat.string(from: Date())
    }
    // MARK:- 获取当前时间戳(秒)
    static func getNowTimeS() -> Int {
        let date = Date()
        let timeInterval:Int = Int(date.timeIntervalSince1970)
        return timeInterval
    }
    // MARK:- 获取当前时区的时间
    static func getCurrentTimeZone() -> Date {
        let date = Date()
        let zone = TimeZone.current
        let interval = zone.secondsFromGMT()
        let nowDate = date.addingTimeInterval(TimeInterval(interval))
        return nowDate
    }
    // MARK:- 获取0时区的开始时间（2018-5-13 16：00：00）
    static func getZeroTimeZone() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormat.date(from: DateClass.todayString())
        return todayDate!
    }
    // MARK:- 获取获取当前时区的开始时间（2018-5-13 00：00：00）
    static func getCurrentInitTimeZone() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let zone = TimeZone.current
        dateFormat.timeZone = zone
        let interval = zone.secondsFromGMT()
        let todayDate = dateFormat.date(from: DateClass.todayString())
        return todayDate!.addingTimeInterval(TimeInterval(interval))
    }
    // MARK:- 将时间戳按指定格式时间输出 13569746264 -> 2018-05-06
    static func timestampToStr(_ timestamp: Int, formatStr: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        // 以中国为准
        //        let locale = Locale(identifier: "zh")
        let locale = Locale.current
        dateFormat.locale = locale
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        let str = dateFormat.string(from: date)
        return str
    }
    // MARK:- 将时间格式转换时间戳输出 2018-05-06 -> 13569746264
    static func timeStrToTimestamp(_ timeStr: String, formatStr: String) -> Int {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = formatStr
        let date = dateFormat.date(from: timeStr) ?? Date()
        let timestamp = Int(date.timeIntervalSince1970)
        return timestamp
    }
    // MARK:- 将制定格式时间转自定义格式时间 2018-05-06 -> 2018-05-06 00:00:00
    static func timeStrToTimeStr(_ timeStr: String, formatStr: String, toFormatStr: String) -> String {
        let timestamp = DateClass.timeStrToTimestamp(timeStr, formatStr: formatStr)
        return DateClass.timestampToStr(timestamp, formatStr: toFormatStr)
    }
    
    // MARK:- 获取当前时间按指定格式时间输出
    static func getCurrentTimeStr(formatStr: String) -> String {
        let date = Date()
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        // 以中国为准
        let locale = Locale.init(identifier: "zh-CN")
        dateFormat.locale = locale
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        let str = dateFormat.string(from: date)
        return str
    }
    
    // MARK:- 距离指定日期偏移天数的日期
    static func dateStringOffset(from: String, offset: Int) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        guard let fromDate = dateFormat.date(from: from) else {
            return from
        }
        
        var cmps = Calendar.current.dateComponents([.year, .month, .day], from: fromDate)
        cmps.day = cmps.day! + offset
        let resultDate = Calendar.current.date(from: cmps)
        return dateFormat.string(from: resultDate!)
    }
    
    static func getTimeStrToDate(formatStr: String, timeStr: String) -> Date {
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        return dateFormat.date(from: timeStr)!
    }
    
    static func getSpecialDays(dateStr: String, count: Int) -> [String] {
        var days = [String]()
        let dateformatter = DateFormatter.init()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date = dateformatter.date(from: dateStr)
        let calendar = Calendar.current
        
        for i in 0..<count {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date!)
            dateComponents.day = dateComponents.day! + i
            let newDate = calendar.date(from: dateComponents)
            let dateString = dateformatter.string(from: newDate!)
            days.append(dateString)
        }
        return days
    }
    
    //指定年月的开始日期
    static func startOfMonth(year: Int, month: Int) -> Date {
        let calendar = NSCalendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calendar.date(from: startComps)!
        return startDate
    }
    
    //指定年月的结束日期
    static func endOfMonth(year: Int, month: Int, returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        
        let endOfYear = calendar.date(byAdding: components,
                                      to: startOfMonth(year: year, month:month))!
        return endOfYear
    }
}

extension Date {
    //计算两个日期之间的日期差
    func daysBetweenDate(toDate: Date) -> Int {
        let beginDate = self.getMorningDate()
        let endDate = toDate.getMorningDate()
        let components = Calendar.current.dateComponents([.day], from: beginDate, to: endDate)
        return components.day ?? 0
    }
    //当前日期置为0点0分0秒
    func getMorningDate() -> Date{
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year,.month,.day], from: self)
        return (calendar.date(from: components))!
    }
}
