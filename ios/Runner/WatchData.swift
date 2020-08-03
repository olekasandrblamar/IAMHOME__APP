//
//  WatchData.swift
//  Runner
//
//  Created by Shyam Alapati on 8/3/20.
//

import Foundation

class WatchData: NSObject,HardManagerSDKDelegate{
    
    func startScan() {
        HardManagerSDK.shareBLEManager()?.delegate = self
        HardManagerSDK.shareBLEManager()?.scanDevices(["ITPOWER01"])
       
    }
    
    func didFindDevice(_ device: CBPeripheral!) {
        
    }
    
}
