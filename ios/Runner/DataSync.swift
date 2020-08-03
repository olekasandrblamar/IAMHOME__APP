//
//  DataSync.swift
//  Runner
//
//  Created by Shyam Alapati on 8/3/20.
//

import Foundation
class DataSync {
    
}

struct TemperatureUpload {
    let measureTime:Date
    let celsius: Double
    let fahrenheit:Double
    let deviceId:String
    
    init(measureTime:Date,celsius:Double,deviceId:String) {
        self.measureTime = measureTime
        self.celsius = celsius
        self.fahrenheit = (celsius*9/5)+32
        self.deviceId = deviceId
    }
}

struct StepUpload {
    let measureTime:Date
    let steps:Int
    let deviceId:String
}
