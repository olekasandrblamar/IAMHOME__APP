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
    var deviceFound = false
    var deviceConnected = false
    var initComplete = false
    
    //Initialize the B369
    override init() {
        super.init()
        var userInfo = ICUserInfo()
        userInfo.age = 30
        userInfo.enableMeasureHr = true
        userInfo.height = 170
        userInfo.sex = ICSexType.male
        userInfo.weightUnit = ICWeightUnit.lb
        userInfo.weight = 170
        userInfo.peopleType = ICPeopleTypeNormal
        userInfo.kitchenUnit = ICKitchenScaleUnit.lb
        userInfo.rulerUnit = ICRulerUnit.inch
        userInfo.userIndex = 1
        ICDeviceManager.shared()?.update(userInfo)
        ICDeviceManager.shared()?.delegate = self
        ICDeviceManager.shared()?.initMgr()
    }
    
    func startScan(result:@escaping FlutterResult,scanDeviceId:String) {
        self.deviceId = scanDeviceId
        self.deviceFound=false
        self.deviceConnected=false
        self.connectionResult = result
        if(initComplete){
            ICDeviceManager.shared()?.scanDevice(self)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                ICDeviceManager.shared()?.scanDevice(self)
            }
        }
    }
    
    func connectWifi(result:@escaping FlutterResult,ssid:String,password:String){
        NSLog("Conecting to \(ssid) with password \(password)")
        ICDeviceManager.shared()?.getSettingManager()?.configWifi(self.device, ssid: "shyamalapati", password: password, callback: { (callBackCode) in
            NSLog("Got connection response \(callBackCode.rawValue)")
        })
    }
    
    func onReceiveConfigWifiResult(_ device: ICDevice!, state: ICConfigWifiState) {
        NSLog("Got Wifi config result \(state.rawValue) for device \(device.macAddr)")
    }
    
    func onBleState(_ state: ICBleState) {
        NSLog("Got Ble state \(state)")
    }
    
    func onDeviceConnectionChanged(_ device: ICDevice!, state: ICDeviceConnectState) {
        NSLog("Got connection changed to \(state)")
    }
    
    func onInitFinish(_ bSuccess: Bool) {
        NSLog("Init finish status \(bSuccess)")
        if(bSuccess){
            self.initComplete = true
        }
    }
    
    func onReceiveWeightUnitChanged(_ device: ICDevice!, unit: ICWeightUnit) {
        NSLog("Weight unit changes to \(unit)")
    }
    
    func onReceiveWeightData(_ device: ICDevice!, data: ICWeightData!) {
        NSLog("Got Weight data \(data)")
    }
    
    func onReceiveWeightHistoryData(_ device: ICDevice!, data: ICWeightHistoryData!) {
        NSLog("Got weight history data \(data)")
    }
    
    func onReceiveCoordData(_ device: ICDevice!, data: ICCoordData!) {
        NSLog("Got Corod data \(data)")
    }
    
    func onReceiveMeasureStepData(_ device: ICDevice!, step: ICMeasureStep, data: NSObject!) {
        NSLog("Got measure data \(step) \(data)")
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
                let connectionInfo = ConnectionInfo(deviceId: device?.macAddr, deviceName: deviceInfo.name, connected: true, deviceFound: self.deviceFound, message: "connected")
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
