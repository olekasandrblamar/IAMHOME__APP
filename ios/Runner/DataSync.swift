//
//  DataSync.swift
//  Runner
//
//  Created by Shyam Alapati on 8/3/20.
//

import Foundation

class CustomEncoder: JSONEncoder{
    
    override init() {
        super.init()
        var isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.dateEncodingStrategy = .formatted(isoFormatter)
    }
    
}

class DataSync {
    
    private static let baseUrl = "https://device.alpha.myceras.com/api/v1/device/"
    private static let encoder = CustomEncoder()
    
    
    static func uploadHeartRateInfo(heartRates:[HeartRateUpload]){
        do{
            makePostApiCall(url: "heartrate", postData: try encoder.encode(heartRates))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadDailySteps(dailySteps:StepUpload){
        do{
            makePostApiCall(url: "dailySteps", postData: try encoder.encode([dailySteps]))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadTemparatures(temps:[TemperatureUpload]){
        do{
            makePostApiCall(url: "temperature", postData: try encoder.encode(temps))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadSteps(steps:[StepUpload]){
        do{
            makePostApiCall(url: "steps", postData: try encoder.encode(steps))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    static func uploadOxygenLevels(oxygenLevels: [OxygenLevelUpload]){
        do{
            makePostApiCall(url: "oxygen", postData: try encoder.encode(oxygenLevels))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadBloodPressure(bpLevels: [BpUpload]){
        do{
            makePostApiCall(url: "bloodpressure", postData: try encoder.encode(bpLevels))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func sendHeartBeat(heartBeat:HeartBeat){
        do{
            makePostApiCall(url: "heartbeat", postData: try encoder.encode(heartBeat))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadCalories(calories:CaloriesUpload){
        do{
            makePostApiCall(url: "calories", postData: try encoder.encode([calories]))
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    private static func makePostApiCall(url:String,postData:Data){
        let completeUrl = URL(string: baseUrl+url)!
        var request = URLRequest(url: completeUrl)
        request.httpMethod = "POST"
        request.httpBody = postData
        NSLog("Uploading to \(url) with data \(String(data: postData, encoding: .utf8)!)")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(response)
            print(data)
            print(error)
        }

        task.resume()

    }
    
}

struct TemperatureUpload:Codable {
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

struct HeartBeat:Codable{
    let deviceId:String?
    let macAddress:String?
}

struct BpUpload:Codable {
    let measureTime:Date
    let distolic:Int
    let systolic:Int
    let deviceId:String
}

struct OxygenLevelUpload:Codable{
    let measureTime:Date
    let oxygenLevel:Int
    let deviceId:String
}

struct StepUpload:Codable {
    let measureTime:Date
    let steps:Int
    let deviceId:String
}

struct CaloriesUpload:Codable{
   let measureTime:Date
   let calories:Int
   let deviceId:String
}

struct HeartRateUpload:Codable{
    let measureTime:Date
    let heartRate:Int
    let deviceId:String
}
