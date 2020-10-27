package com.cerashealth.ceras.lifeplus.data

import android.util.Log
import com.cerashealth.ceras.MainActivity
import com.google.gson.Gson
import java.util.*

class UserProfile{
    var age = 0
    var weightInKgs = 0.0
    var heightInCm = 0
    var sex:String = ""
    var lastUpdated = Date()
}

data class TemperatureUpload(val measureTime: Date, var celsius:Double, val fahrenheit:Double, val deviceId:String)

data class StepUpload(val measureTime: Date, var steps:Int, val deviceId:String)

data class DailyStepUpload(val measureTime: Date, var steps:Int, val deviceId:String)

data class CaloriesUpload(val measureTime: Date, var calories:Int, val deviceId:String)

data class BpUpload(val measureTime: Date, var distolic:Int, var systolic:Int, val deviceId:String, var userProfile:UserProfile? = null)

data class HeartRateUpload(val measureTime: Date, var heartRate:Int, val deviceId:String)

data class OxygenLevelUpload(val measureTime: Date, var oxygenLevel:Int, val deviceId:String, var userProfile:UserProfile? = null)

data class HeartBeat(val deviceId:String?,val macAddress:String?){
    var deviceInfo:String? = null
    var background = false
    var latitude:Double? = null
    var longitude:Double? = null
}


class ConnectionInfo{
    var deviceId:String? = null
    var deviceName:String? = null
    var connected = false
    var deviceFound = false
    var message:String? = null
    var additionalInformation = mapOf<String,String>()
    var deviceType:String? = null

    companion object{
        fun createResponse(deviceId:String? = null,deviceName:String? = null,connected:Boolean = false,message:String? = null
                           ,additionalInfo: Map<String, String> = mapOf<String,String>(),deviceType:String? = null,deviceFound:Boolean = true):String{
            val connectionData =  Gson().toJson(ConnectionInfo().apply {
                this.deviceId = deviceId
                this.connected = connected
                this.message = message
                this.deviceName = deviceName
                this.additionalInformation = additionalInfo
                this.deviceType = deviceType
                this.deviceFound = deviceFound
            })
            Log.i(MainActivity.TAG,"Sending connection data back $connectionData")
            return connectionData
        }
    }

}