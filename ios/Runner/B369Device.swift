//
//  B369Device.swift
//  Runner
//
//  Created by Shyam Alapati on 7/15/21.
//

import Foundation
import ICDeviceManager

class B369Device: NSObject,ICScanDeviceDelegate,ICDeviceManagerDelegate{
    
    var device:ICDevice? = nil
    var deviceId:String? = nil
    var connectionResult:FlutterResult? = nil
    var wifiResult:FlutterResult? = nil
    var deviceFound = false
    var deviceConnected = false
    var isDeviceConnectionAvailable = false
    var initComplete = false
    private var deviceAdded = false
    
    //Initialize the B369
    override init() {
        super.init()
        let userInfo = ICUserInfo()
        userInfo.age = 30
        userInfo.enableMeasureHr = true
        userInfo.height = 170
        userInfo.sex = ICSexType.male
        userInfo.weightUnit = ICWeightUnit.lb
        userInfo.weight = 60
        userInfo.peopleType = ICPeopleTypeNormal
        userInfo.kitchenUnit = ICKitchenScaleUnit.lb
        userInfo.rulerUnit = ICRulerUnit.inch
        userInfo.userIndex = 1
        let userData = DataSync.getUserInfo()
        if(userData != nil){
            userInfo.age = UInt(userData!.age)
            userInfo.sex = userData?.sex.lowercased() == "male" ? ICSexType.male : ICSexType.femal
            userInfo.weight = Float(userData!.weightInKgs) * 2.20
            userInfo.height = UInt(userData!.heightInCm)
        }
        ICDeviceManager.shared()?.update(userInfo)
        ICDeviceManager.shared()?.delegate = self
        ICDeviceManager.shared()?.initMgr()
        deviceAdded = false
    }
    
    func startScan(result:@escaping FlutterResult,scanDeviceId:String) {
        self.deviceId = scanDeviceId
        self.deviceFound=false
        self.deviceConnected=false
        self.connectionResult = result
        if(initComplete){
            self.scanAndFindDevice(result: result)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.scanAndFindDevice(result: result)
            }
        }
    }
    
    private func scanAndFindDevice(result:@escaping FlutterResult){
        ICDeviceManager.shared()?.scanDevice(self)
        //Stop scanning after 20 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            self.sendResponse(result: result)
        }
    }
    
    func syncData(connectionInfo:ConnectionInfo,result:@escaping FlutterResult){
        self.checkAndReAddDevice(macAddr: connectionInfo.deviceId)
        result(generateResponse(deviceId: connectionInfo.deviceId!, message: "Synced", connected: isDeviceConnectionAvailable))
    }
    
    func connectWifi(result:@escaping FlutterResult,ssid:String,password:String){
        NSLog("Conecting to \(ssid) with password \(password)")
        self.wifiResult = result
        ICDeviceManager.shared()?.getSettingManager()?.configWifi(self.device, ssid: ssid, password: password, callback: { (callBackCode) in
            NSLog("Got connection response \(callBackCode.rawValue)")
        })
        
        let serverBaseUrl = UserDefaults.standard.object(forKey: AppDelegate.SERVER_BASE_URL) as! String
        NSLog("Sending server base url \(String(describing: serverBaseUrl))")
        ICDeviceManager.shared()?.getSettingManager()?.setServerUrl(self.device, server: serverBaseUrl, callback: { (callBackCode) in
            NSLog("Got Server URL \(callBackCode.rawValue)")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 45) {
            self.sendWifiResponse(device: self.device,message: "Config failed",connected: false)
        }
    }
    
    func onReceiveDeviceInfo(_ device: ICDevice!, deviceInfo: ICDeviceInfo!) {
        NSLog("Got device info firmware :\(String(deviceInfo.firmwareVer)) serial #\(String(deviceInfo.sn))")
    }
    
    func disconnect(result:@escaping FlutterResult,connectionInfo: ConnectionInfo){
        let deviceForDeletion = ICDevice()
        deviceForDeletion.macAddr = connectionInfo.deviceId
        ICDeviceManager.shared()?.remove(deviceForDeletion, callback: { device, callBack in
            if(callBack == ICRemoveDeviceCallBackCode.success){
                result("Success")
            }else{
                result("Error")
            }
        })
    }
    
    func onReceiveConfigWifiResult(_ device: ICDevice!, state: ICConfigWifiState) {
        NSLog("Got Wifi config result \(state.rawValue) for device \(String(device.macAddr))")
        switch state {
        case ICConfigWifiState.wifiConnectFail:
            sendWifiResponse(device: device,message: "Config failed",connected: false)
        case ICConfigWifiState.passwordFail:
            sendWifiResponse(device: device,message: "Invalid password",connected: false)
        case ICConfigWifiState.success:
            sendWifiResponse(device: device,message: "success",connected: true)
        case ICConfigWifiState.fail:
            sendWifiResponse(device: device,message: "Config failed",connected: false)
        case ICConfigWifiState.wifiConnecting:
            NSLog("Connecting to wifi")
        case ICConfigWifiState.serverConnecting:
            NSLog("Connecting to device")
        default:
            sendWifiResponse(device: device,message: "Config failed",connected: false)
        }
    }
    
    func sendWifiResponse(device: ICDevice!,message: String,connected: Bool){
        if(self.wifiResult != nil){
            self.wifiResult?(generateResponse(deviceId: device.macAddr, message:message,connected: connected))
            self.wifiResult = nil
        }
    }
    
    
    func onBleState(_ state: ICBleState) {
        NSLog("Got Ble state \(state)")
    }
    
    func onDeviceConnectionChanged(_ device: ICDevice!, state: ICDeviceConnectState) {
        if(state == ICDeviceConnectState.connected){
            NSLog("Got connected changed to true")
            isDeviceConnectionAvailable = true
        }else if(state == ICDeviceConnectState.disconnected){
            NSLog("Got connected changed to false")
            isDeviceConnectionAvailable = false
        }
        NSLog("Got connection changed to \(state)")
    }
    
    func onInitFinish(_ bSuccess: Bool) {
        NSLog("Init finish status \(bSuccess)")
        if(bSuccess){
            self.initComplete = true
            if(self.deviceId != nil){
                checkAndReAddDevice(macAddr: self.deviceId)
            }
        }
    }
    
    func getConnectionStatus(result:@escaping FlutterResult,connectionInfo: ConnectionInfo){
        self.checkAndReAddDevice(macAddr: connectionInfo.deviceId)
        return result(isDeviceConnectionAvailable)
    }
    
    private func checkAndReAddDevice(macAddr:String?){
        if(initComplete == true && deviceAdded == false){
            let connectedDevice = ICDevice()
            connectedDevice.macAddr = macAddr
            NSLog("Device found and adding to devices")
            ICDeviceManager.shared()?.add(connectedDevice, callback: { (device, callbackCode) in
                NSLog("Got call back code \(callbackCode.rawValue) for \(device?.macAddr ?? "")")
                if(callbackCode == .success){
                    self.deviceAdded = true
                }
            })
        }else if(deviceId == nil){
            self.deviceId = macAddr
        }
    }
    
    func getCurrentDeviceStatus(connInfo: ConnectionInfo, result:@escaping FlutterResult){
        do{
            self.checkAndReAddDevice(macAddr: connInfo.deviceId)
            let connectionInfo = ConnectionInfo(deviceId: connInfo.deviceId, deviceName: connInfo.deviceName, connected: isDeviceConnectionAvailable, deviceFound: connInfo.deviceFound, message: "",batteryStatus: "99")
            let deviceJson = try JSONEncoder().encode(connectionInfo)
            let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
            NSLog("Sending Connection data back from device info \(connectionInfoData)")
            result(connectionInfoData)
        }catch{
            NSLog("Error reading data \(error)")
            result("Error")
        }
    }
    
    private func generateResponse(deviceId:String,message:String,connected: Bool) -> String{
        let connectionInfo = ConnectionInfo(deviceId: deviceId, deviceName: "", connected: connected, deviceFound: self.deviceFound, message: message)
        do{
            let deviceJson = try JSONEncoder().encode(connectionInfo)
            let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
            return connectionInfoData
        }catch{
            return "Error"
        }
    }
    
    func onReceiveWeightUnitChanged(_ device: ICDevice!, unit: ICWeightUnit) {
        NSLog("Weight unit changes to \(unit)")
    }
    
    func onReceiveWeightData(_ device: ICDevice!, data: ICWeightData!) {
        NSLog("Got Weight data \(data)")
        updateWeight(device: device, weight: data)
    }
    
    func updateWeight(device: ICDevice!,weight: ICWeightData){
        DataSync.uploadWeights(weights:[WeightUpload(measureTime: Date(), kgs: weight.weight_kg, lbs: weight.weight_lb, deviceId: device.macAddr)])
    }
    
    
    
    func onReceiveWeightHistoryData(_ device: ICDevice!, data: ICWeightHistoryData!) {
        NSLog("Got weight history data \(data)")
    }
    
    func onReceiveCoordData(_ device: ICDevice!, data: ICCoordData!) {
        NSLog("Got Corod data \(data)")
    }
    
    func onReceiveMeasureStepData(_ device: ICDevice!, step: ICMeasureStep, data: NSObject!) {
        NSLog("Got measure data \(step) \(data)")
        switch step {
        case ICMeasureStepMeasureOver :
            NSLog("got measure over data \(data)")
            let weightData = data as! ICWeightData
            self.updateWeight(device: device, weight: weightData)
        case ICMeasureStepMeasureWeightData:
            NSLog("got center weight data \(data)")
        case ICMeasureStepHrStart:
            NSLog("For Step Hr start \(data)")
        case ICMeasureStepAdcResult:
            NSLog("Got adc result \(data)")
        case ICMeasureStepAdcStart:
            NSLog("Adc start \(data)")
        case ICMeasureStepHrResult:
            NSLog("Hr result \(data)")
        default:
            NSLog("Default case")
        }
    }
    
    func sendResponse(result:@escaping FlutterResult){
        ICDeviceManager.shared().stopScan()
        if(!self.deviceConnected){
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

    
    func onScanResult(_ deviceInfo: ICScanDeviceInfo!) {
        self.deviceFound = true
        NSLog("Got mac address \(deviceInfo.macAddr) and matching it with \(deviceId)")
        let macAddress = deviceInfo.macAddr.suffix(5).replacingOccurrences(of: ":", with: "")
        NSLog("mathcing the updated mac address to  \(macAddress) and matching it with \(deviceId)")
        if(macAddress == deviceId){
            //Once the device is found stop the scan
            ICDeviceManager.shared().stopScan()
            let connectedDevice = ICDevice()
            connectedDevice.macAddr = deviceInfo.macAddr
            NSLog("Device found and adding to devices")
            ICDeviceManager.shared()?.add(connectedDevice, callback: { (device, callbackCode) in
                NSLog("Got call back code \(callbackCode) for \(device?.macAddr)")
                self.deviceConnected = true
                self.device = device
                let connectionInfo = ConnectionInfo(deviceId: device?.macAddr, deviceName: deviceInfo.name, connected: true, deviceFound: self.deviceFound, message: "connected",deviceType: AppDelegate.SCALE_TYPE)
                do{
                    let deviceJson = try JSONEncoder().encode(connectionInfo)
                    let connectionInfoData = String(data: deviceJson, encoding: .utf8)!
                    NSLog("Sending connection info \(connectionInfoData)")
                    self.connectionResult?(connectionInfoData)
                }catch{
                    NSLog("Got error while adding device \(error)")
                    self.connectionResult?("Error")
                }
            })
        }
    }

}
