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
    private static let LAST_UPDATES = "flutter.last_sync_updates"
    static var BACKGROUND = false
    private static let urlDeletegate = CustomUrlDelegate()
    
    
    static func uploadHeartRateInfo(heartRates:[HeartRateUpload]){
        do{
            makePostApiCall(url: "heartrate", postData: try encoder.encode(heartRates))
            
            let latestValue = heartRates.max { (first, second) -> Bool in
                first.measureTime < second.measureTime
            }
            if(latestValue != nil){
                changeLastUpdated(type: "HEART_RATE",latestMeasureTime: latestValue!.measureTime)
            }
            
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadDailySteps(dailySteps:StepUpload){
        do{
            makePostApiCall(url: "dailySteps", postData: try encoder.encode([dailySteps]))
            changeLastUpdated(type: "DAILY_STEPS",latestMeasureTime: dailySteps.measureTime)
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadTemparatures(temps:[TemperatureUpload]){
        do{
            makePostApiCall(url: "temperature", postData: try encoder.encode(temps))
            let latestValue = temps.max { (first, second) -> Bool in
                first.measureTime < second.measureTime
            }
            if(latestValue != nil){
                changeLastUpdated(type: "TEMPERATURE",latestMeasureTime: latestValue!.measureTime)
            }
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadSteps(steps:[StepUpload]){
        do{
            makePostApiCall(url: "steps", postData: try encoder.encode(steps))
            let latestValue = steps.max { (first, second) -> Bool in
                first.measureTime < second.measureTime
            }
            if(latestValue != nil){
                changeLastUpdated(type: "STEPS",latestMeasureTime: latestValue!.measureTime)
            }
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    static func uploadOxygenLevels(oxygenLevels: [OxygenLevelUpload]){
        do{
            makePostApiCall(url: "oxygen", postData: try encoder.encode(oxygenLevels))
            let latestValue = oxygenLevels.max { (first, second) -> Bool in
                first.measureTime < second.measureTime
            }
            if(latestValue != nil){
                changeLastUpdated(type: "OXYGEN",latestMeasureTime: latestValue!.measureTime)
            }
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func uploadBloodPressure(bpLevels: [BpUpload]){
        do{
            makePostApiCall(url: "bloodpressure", postData: try encoder.encode(bpLevels))
            let latestValue = bpLevels.max { (first, second) -> Bool in
                first.measureTime < second.measureTime
            }
            if(latestValue != nil){
                changeLastUpdated(type: "BP",latestMeasureTime: latestValue!.measureTime)
            }
        }catch{
            NSLog("Error while Uploading Data \(error)")
        }
    }
    
    static func changeLastUpdated(type:String?,latestMeasureTime:Date){
        NSLog("Setting last updates for \(type)")
        var lastUpdates = UserDefaults.standard.string(forKey: DataSync.LAST_UPDATES)
        NSLog("Got last updates from local storage \(lastUpdates)")
        var updates:[String:String] = [:]
        if(lastUpdates != nil || !((lastUpdates != nil ? lastUpdates! : "").isEmpty)){
            do{
                updates = try JSONDecoder().decode(Dictionary<String,String>.self, from: lastUpdates!.data(using: .utf8) as! Data)
            }catch{
                NSLog("Error decoding data from local storage \(error)")
            }
        }
        do{
            let currentUpdateData = ["lastMeasure":AppDelegate.dateFormatter.string(from: latestMeasureTime),"lastupdated":AppDelegate.dateFormatter.string(from: Date())]
            let currentLastUpdate = String(data:try JSONEncoder().encode(currentUpdateData),encoding: .utf8)
            updates[type!] = currentLastUpdate
            lastUpdates = String(data:try JSONEncoder().encode(updates),encoding: .utf8)
            UserDefaults.standard.set(lastUpdates, forKey: DataSync.LAST_UPDATES)
            NSLog("Set updates to \(lastUpdates)")
        }catch{
            NSLog("Error updating last sync for \(type) with \(error)")
        }
        NSLog("completed setting last updates for \(type)")
    }
    
    static func sendHeartBeat(heartBeat:HeartBeat){
        do{
            var updatedHBeat = heartBeat
            updatedHBeat.background = BACKGROUND
            updatedHBeat.deviceInfo = UserDefaults.standard.string(forKey: "flutter.userDeviceInfo")
            makePostApiCall(url: "heartbeat", postData: try encoder.encode(updatedHBeat))
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
        request.setValue(BACKGROUND.description , forHTTPHeaderField: "BACKGROUND_STATUS")
        
        //create a background task and execute it
        let config = URLSessionConfiguration.background(withIdentifier: url)
        let session = URLSession(configuration: config, delegate: urlDeletegate, delegateQueue: nil)
        let task = session.dataTask(with: request)

        task.resume()

    }
    
}

class CustomUrlDelegate: NSObject,URLSessionTaskDelegate,URLSessionDelegate,URLSessionDataDelegate{
    
   
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let currentUrl = dataTask.currentRequest?.url?.absoluteString
        let httpResponse = dataTask.response as! HTTPURLResponse
        print("Got response for \(currentUrl) with status \(httpResponse.statusCode) \(String.init(data: data, encoding: .utf8))")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if(error != nil){
            let currentUrl = task.currentRequest?.url?.absoluteString
            print("Got error for \(currentUrl) with \(error)")
        }
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
    var deviceInfo:String? = nil
    var background:Bool = false
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
