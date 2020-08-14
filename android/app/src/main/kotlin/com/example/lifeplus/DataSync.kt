package com.cerashealth.ceras

import android.util.Log
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonArray
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.text.DateFormat
import java.util.*

class DataSync {

    companion object{
        private val TAG = DataSync::class.java.simpleName
        private val okHttp = OkHttpClient()
        private val jsonMediaType = "application/json; charset=utf-8".toMediaTypeOrNull()
        val baseUrl = "https://device.dev.myceras.com/api/v1/device"
        private val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").create()

        fun uploadTemperature(temperatures:List<TemperatureUpload>){
            makePostRequest(gson.toJson(temperatures),"temperature")
        }

        fun sendHeartBeat(heartBeat: DeviceHeartBeat){
            makePostRequest(gson.toJson(heartBeat),"heartbeat")
        }

        fun uploadOxygenData(oxygenLevels:List<OxygenLevelUpload>){
            makePostRequest(gson.toJson(oxygenLevels),"oxygen")
        }

        fun uploadBloodPressure(bpLevels:List<BpUpload>){
            makePostRequest(gson.toJson(bpLevels),"bloodpressure")
        }

        fun uploadHeartRate(heartRates:List<HeartRateUpload>){
            makePostRequest(gson.toJson(heartRates),"heartrate")
        }

        fun sendHeartBeat(heartBeat: HeartBeat){
            makePostRequest(gson.toJson(heartBeat),"heartbeat")
        }

        fun uploadStepInfo(stepInfo:List<StepUpload>){
            makePostRequest(gson.toJson(stepInfo),"steps")
        }

        fun uploadDailySteps(dailySteps:List<DailyStepUpload>){
            makePostRequest(gson.toJson(dailySteps),"dailySteps")
        }

        fun uploadCalories(calories:List<CaloriesUpload>){
            makePostRequest(gson.toJson(calories),"calories")
        }

        private fun makePostRequest(postData:String,url:String){
            Log.d(TAG,"Uploading data to $url with data $postData")
            val postReq = Request.Builder().url("$baseUrl/$url").post(postData.toRequestBody(jsonMediaType)).build()
            okHttp.newCall(postReq).enqueue(object: Callback{
                override fun onFailure(call: Call, e: IOException) {
                    Log.e(TAG,"Failed calling ${call.request().url}",e)
                }

                override fun onResponse(call: Call, response: Response) {
                    Log.i(TAG,"Success for call ${call.request().url}")
                }

            })
        }
    }

}

data class DeviceHeartBeat(val deviceId:String)

data class TemperatureUpload(val measureTime:Date, var celsius:Double, val fahrenheit:Double, val deviceId:String)

data class StepUpload(val measureTime:Date, var steps:Int,val deviceId:String)

data class DailyStepUpload(val measureTime:Date, var steps:Int,val deviceId:String)

data class CaloriesUpload(val measureTime:Date, var calories:Int,val deviceId:String)

data class BpUpload(val measureTime:Date, var distolic:Int,var systolic:Int,val deviceId:String)

data class HeartRateUpload(val measureTime:Date, var heartRate:Int,val deviceId:String)

data class OxygenLevelUpload(val measureTime:Date, var oxygenLevel:Int,val deviceId:String)

data class HeartBeat(val deviceId:String?,val macAddress:String?)