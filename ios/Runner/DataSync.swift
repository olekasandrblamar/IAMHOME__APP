//
//  DataSync.swift
//  Runner
//
//  Created by Shyam Alapati on 8/3/20.
//

import Foundation
import CoreLocation

class CustomEncoder: JSONEncoder{
    
    override init() {
        super.init()
        var isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.dateEncodingStrategy = .formatted(isoFormatter)
    }
    
}

class DataSync {
    
    private static let baseUrl = "https://tracker.ceras.io/api/v1/device/"
    private static let encoder = CustomEncoder()
    private static let LAST_UPDATES = "flutter.last_sync_updates"
    static let USER_PROFILE_DATA = "flutter.user_profile_data"
    static var BACKGROUND = false
    private static let urlDeletegate = CustomUrlDelegate()
    private static let getProfileDelegate = UserDataUrlDelegate()
    static let MAC_ADDRESS_NAME = "flutter.device_macid"
    static let BASE_URL =  "flutter.apiBaseUrl"

    static func getBaseUrl() -> String{
        return UserDefaults.standard.object(forKey: DataSync.BASE_URL) as! String
    }
    
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
            let userInfo = getUserInfo()
            let updatedLevels = oxygenLevels.map({ (OxygenLevelUpload) -> OxygenLevelUpload in
                var upload = OxygenLevelUpload
                upload.userProfile = userInfo
                return upload
            })
            makePostApiCall(url: "oxygen", postData: try encoder.encode(updatedLevels))
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
            let userInfo = getUserInfo()
            let updatedLevels = bpLevels.map({ (BpUpload) -> BpUpload in
                var upload = BpUpload
                upload.userProfile = userInfo
                return upload
            })
            makePostApiCall(url: "bloodpressure", postData: try encoder.encode(updatedLevels))
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
    
    static func readUserInfo(){
        
    }
    
    static func sendHeartBeat(heartBeat:HeartBeat){
        do{
            var updatedHBeat = heartBeat
            updatedHBeat.background = BACKGROUND
            updatedHBeat.deviceInfo = UserDefaults.standard.string(forKey: "flutter.userDeviceInfo")
            
            let locationManager = CLLocationManager()
            if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways) {
                let location = locationManager.location
                updatedHBeat.latitude = location?.coordinate.latitude
                updatedHBeat.longitude = location?.coordinate.longitude
            }
            
            makePostApiCall(url: "heartbeat", postData: try encoder.encode(updatedHBeat))
            checkAndLoadUserProfile()
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
    
    private static func checkAndLoadUserProfile(){
        UserDefaults.standard.synchronize()
        let userProfileData = UserDefaults.standard.object(forKey: DataSync.USER_PROFILE_DATA) as! String?
        do{
            var loadProfile = true
            NSLog("Got old profile data \(userProfileData)")
            if(userProfileData != nil){
                NSLog("Reading old profile data \(userProfileData!.data(using: .utf8)!)")
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: userProfileData!.data(using: .utf8)!)
                if(userProfile.lastUpdate != nil){
                    NSLog("Last Update is not empty \(userProfile.lastUpdate)")
                    AppDelegate.dateFormatter.timeZone = TimeZone.current
                    let lastUpdated = AppDelegate.dateFormatter.date(from: userProfile.lastUpdate!)
                    NSLog("Last Update is not empty with lst updated \(lastUpdated)")
                    let timeDiff = Calendar.current.dateComponents([.hour], from: lastUpdated!,to: Date())
                    NSLog("Got profile time diff \(timeDiff.hour!)")
                    if(timeDiff.hour! < 24){
                        loadProfile = false
                    }
                }
            }
            NSLog("Load profile \(loadProfile)")
            //If profile needs to be loaded
            if(loadProfile){
                NSLog("Loading profile \(loadProfile)")
                let macAddress = UserDefaults.standard.string(forKey: DataSync.MAC_ADDRESS_NAME)
                if(macAddress != nil){
                    let profileUrl = URL(string: getBaseUrl()+"profileInfo?deviceId="+macAddress!)!
                    NSLog("Calling profile url \(profileUrl)")
                    var request = URLRequest(url: profileUrl)
                    request.httpMethod = "GET"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                    request.setValue(BACKGROUND.description , forHTTPHeaderField: "BACKGROUND_STATUS")
                    let config = URLSessionConfiguration.background(withIdentifier: "profileInfo")
                    let session = URLSession(configuration: config, delegate: getProfileDelegate, delegateQueue: nil)
                    let task = session.dataTask(with: request)
                    task.resume()
                }
            }
        }catch{
            NSLog("Error loading profile \(error)")
        }
    }
    
    static func getUserInfo() -> UserProfile?{
        let userProfileData = UserDefaults.standard.object(forKey: DataSync.USER_PROFILE_DATA) as! String?
        NSLog("Getting user info with \(userProfileData)")
        if(userProfileData != nil){
            do{
                return try JSONDecoder().decode(UserProfile.self, from: userProfileData!.data(using: .utf8)!)
            }catch{
                NSLog("Error while getting user info \(error)")
            }
        }
        return nil
    }
    
    private static func makePostApiCall(url:String,postData:Data){
        let completeUrl = URL(string: getBaseUrl()+url)!
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

class UserDataUrlDelegate: NSObject,URLSessionTaskDelegate,URLSessionDataDelegate{
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let httpReseponse = dataTask.response as! HTTPURLResponse
        if(httpReseponse.statusCode == 200){
            do{
                let userProfile = String.init(data: data, encoding: .utf8)
                NSLog("Got profile data \(userProfile)")
                var userData = try JSONDecoder().decode(UserProfile.self, from: data)
                userData.lastUpdate = AppDelegate.dateFormatter.string(from: Date())
                let encodedDataString = String.init(data: try JSONEncoder().encode(userData),encoding: .utf8)
                NSLog("Saving profile data \(encodedDataString)")
                UserDefaults.standard.set(encodedDataString, forKey: DataSync.USER_PROFILE_DATA)
                NSLog("Synchronize status \(UserDefaults.standard.synchronize())")
                let userProfileData = UserDefaults.standard.object(forKey: DataSync.USER_PROFILE_DATA)
                NSLog("Got profile data after saving \(userProfileData)")
            }catch{
                NSLog("Error loading user profile ")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if(error != nil){
            let currentUrl = task.currentRequest?.url?.absoluteString
            print("Got error for \(currentUrl) with \(error)")
        }
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

struct UserProfile:Codable{
    var age:Int
    var weightInKgs:Double
    var sex:String
    var heightInCm:Int
    var lastUpdate:String? = nil
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
    var longitude:Double? = nil
    var latitude:Double? = nil
}

struct BpUpload:Codable {
    let measureTime:Date
    let distolic:Int
    let systolic:Int
    let deviceId:String
    var userProfile:UserProfile?
}

struct OxygenLevelUpload:Codable{
    let measureTime:Date
    let oxygenLevel:Int
    let deviceId:String
    var userProfile:UserProfile?
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
