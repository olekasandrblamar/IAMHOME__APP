package com.cerashealth.ceras

import android.content.Context
import android.util.Log
import com.example.lifeplus.BaseDevice
import com.google.gson.GsonBuilder
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.util.*

class DataSync {

    companion object{
        private val TAG = DataSync::class.java.simpleName
        private val okHttp = OkHttpClient()
        private val jsonMediaType = "application/json; charset=utf-8".toMediaTypeOrNull()
        val baseUrl = "https://device.alpha.myceras.com/api/v1/device"
        private val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").create()
        private val LAST_UPDATE_VAL = "flutter.last_sync_updates"

        fun uploadTemperature(temperatures:List<TemperatureUpload>){
            makePostRequest(gson.toJson(temperatures),"temperature")
        }

        fun updateLastSync(type:String, lastMeasure:Date){
            MainActivity.currentContext?.let {currentContext->
                var lastUpdatedDate:MutableMap<String,String> = mutableMapOf()
                val existingData = currentContext.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString(LAST_UPDATE_VAL,"")
                if(existingData?.length!! > 0){
                    lastUpdatedDate = gson.fromJson(existingData,lastUpdatedDate::class.java)
                }

                lastUpdatedDate[type] = gson.toJson(mapOf("lastupdated" to Date(),"lastMeasure" to lastMeasure))
                currentContext.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).edit()
                        .putString(LAST_UPDATE_VAL, gson.toJson(lastUpdatedDate)).commit()

            }
        }

        fun uploadOxygenData(oxygenLevels:List<OxygenLevelUpload>){
            val type = "oxygen"
            makePostRequest(gson.toJson(oxygenLevels),type)
            val lastMeasure = oxygenLevels.maxBy { it.measureTime }
            lastMeasure?.let {
                updateLastSync(type,lastMeasure = lastMeasure?.measureTime)
            }
        }

        fun uploadBloodPressure(bpLevels:List<BpUpload>){
            makePostRequest(gson.toJson(bpLevels),"bloodpressure")
            val lastMeasure = bpLevels.maxBy { it.measureTime }
            lastMeasure?.let {
                updateLastSync("bloodpressure",lastMeasure = lastMeasure?.measureTime)
            }
        }

        fun uploadHeartRate(heartRates:List<HeartRateUpload>){
            makePostRequest(gson.toJson(heartRates),"heartrate")
            val lastMeasure = heartRates.maxBy { it.measureTime }
            lastMeasure?.let {
                updateLastSync("heartrate",lastMeasure = lastMeasure?.measureTime)
            }
        }

        fun sendHeartBeat(heartBeat: HeartBeat){
            MainActivity.updateLastConnected()
            MainActivity.currentContext?.let {
                Log.i(TAG,"Updating last connected")
                heartBeat.deviceInfo = it.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.userDeviceInfo", "")
            }
            heartBeat.background = BaseDevice.isBackground
            makePostRequest(gson.toJson(heartBeat),"heartbeat")
        }

        fun uploadStepInfo(stepInfo:List<StepUpload>){
            makePostRequest(gson.toJson(stepInfo),"steps")
            val lastMeasure = stepInfo.maxBy { it.measureTime }
            lastMeasure?.let {
                updateLastSync("steps",lastMeasure = lastMeasure?.measureTime)
            }
        }

        fun uploadDailySteps(dailySteps:List<DailyStepUpload>){
            makePostRequest(gson.toJson(dailySteps),"dailySteps")
            val lastMeasure = dailySteps.maxBy { it.measureTime }
            lastMeasure?.let {
                updateLastSync("dailySteps",lastMeasure = lastMeasure?.measureTime)
            }
        }

        fun uploadCalories(calories:List<CaloriesUpload>){
            makePostRequest(gson.toJson(calories),"calories")
            val lastMeasure = calories.maxBy { it.measureTime }
            lastMeasure?.let {
                updateLastSync("calories",lastMeasure = lastMeasure?.measureTime)
            }
        }

        private fun makePostRequest(postData:String,url:String){
            Log.d(TAG,"Uploading data to $url with data $postData")
            val postReq = Request.Builder().url("$baseUrl/$url")
                    .post(postData.toRequestBody(jsonMediaType))
                    .addHeader("BACKGROUND_STATUS",BaseDevice.isBackground.toString())
                    .build()
            okHttp.newCall(postReq).enqueue(object: Callback{
                override fun onFailure(call: Call, e: IOException) {
                    Log.e(TAG,"Failed calling ${call.request().url}",e)
                }

                override fun onResponse(call: Call, response: Response) {
                    Log.i(TAG,"Got response ${response.isSuccessful} for call ${call.request().url}")
                    response.body?.close()
                    response.close()
                }

            })
        }
    }

}

data class TemperatureUpload(val measureTime:Date, var celsius:Double, val fahrenheit:Double, val deviceId:String)

data class StepUpload(val measureTime:Date, var steps:Int,val deviceId:String)

data class DailyStepUpload(val measureTime:Date, var steps:Int,val deviceId:String)

data class CaloriesUpload(val measureTime:Date, var calories:Int,val deviceId:String)

data class BpUpload(val measureTime:Date, var distolic:Int,var systolic:Int,val deviceId:String)

data class HeartRateUpload(val measureTime:Date, var heartRate:Int,val deviceId:String)

data class OxygenLevelUpload(val measureTime:Date, var oxygenLevel:Int,val deviceId:String)

data class HeartBeat(val deviceId:String?,val macAddress:String?){
    var deviceInfo:String? = null
    var background = false
}