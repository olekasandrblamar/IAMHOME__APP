package com.cerashealth.ceras

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import android.util.Log
import androidx.core.content.ContextCompat
import com.example.ceras.BaseDevice
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
        private const val baseUrl = "https://device.alpha.myceras.com/api/v1/device"
        private val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").create()
        private const val LAST_UPDATE_VAL = "flutter.last_sync_updates"
        private const val USER_PROFILE = "flutter.user_profile_data"
        var CURRENT_MAC_ADDRESS:String? = null

        fun uploadTemperature(temperatures:List<TemperatureUpload>){
            makePostRequest(gson.toJson(temperatures),"temperature")
        }

        private fun updateLastSync(type:String, lastMeasure:Date){
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

        fun getUserInfo():UserProfile?{
            MainActivity.currentContext?.let { currentContext ->
                currentContext.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString(USER_PROFILE,"")?.let { existingUserData->
                    if(existingUserData.isNotEmpty()){
                        Log.i(TAG,"returning existing user info $existingUserData")
                        return gson.fromJson(existingUserData,UserProfile::class.java)
                    }
                }
            }
            return null
        }

        private fun checkAndLoadProfile(){
            MainActivity.currentContext?.let { currentContext ->
                var loadProfileData = true
                currentContext.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString(USER_PROFILE,"")?.let { existingUserData->
                    if(existingUserData.isNotEmpty()){
                        Log.i(TAG,"Existing profile info $existingUserData")
                        val userProfile = gson.fromJson(existingUserData,UserProfile::class.java)
                        val currentTime = Calendar.getInstance()
                        val timeDiffInHours = (currentTime.timeInMillis-userProfile.lastUpdated.time)/(1000*60*60)
                        Log.i(TAG,"Time Diff $timeDiffInHours")
                        //If the last update time is less than 24 hours
                        if(timeDiffInHours > 24){
                            loadProfileData = false
                        }
                    }
                }
                Log.i(TAG,"Loading profile info $loadProfileData")
                //If profile data needs to be loaded
                if(loadProfileData){
                    Log.d(TAG,"Loading profile")
                    CURRENT_MAC_ADDRESS?.let {
                        val postReq = Request.Builder().url("$baseUrl/profileInfo?deviceId=$it")
                                .get()
                                .addHeader("BACKGROUND_STATUS",BaseDevice.isBackground.toString())
                                .build()
                        okHttp.newCall(postReq).enqueue(object: Callback{
                            override fun onFailure(call: Call, e: IOException) {
                                Log.e(TAG,"Failed calling ${call.request().url}",e)
                            }

                            override fun onResponse(call: Call, response: Response) {
                                Log.i(TAG,"Got response ${response.isSuccessful} for call ${call.request().url}")
                                val userProfile = gson.fromJson<UserProfile>(response.body?.string(),UserProfile::class.java)
                                userProfile.lastUpdated = Date()
                                currentContext.getSharedPreferences(MainActivity
                                        .SharedPrefernces,Context.MODE_PRIVATE).edit()
                                        .putString(USER_PROFILE,gson.toJson(userProfile)).commit()
                                response.body?.close()
                                response.close()
                            }

                        })
                    }

                }


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
            MainActivity.currentContext?.let {context->
                Log.i(TAG,"Updating last connected")
                heartBeat.deviceInfo = context.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.userDeviceInfo", "")
                val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
                if(locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                        && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)==PackageManager.PERMISSION_GRANTED){
                    val location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)

                    heartBeat.apply {
                        latitude = location.latitude
                        longitude = location.longitude
                    }
                }
            }

            heartBeat.background = BaseDevice.isBackground
            makePostRequest(gson.toJson(heartBeat),"heartbeat")
            checkAndLoadProfile()
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

class UserProfile{
    var age = 0
    var weightInKgs = 0.0
    var heightInCm = 0
    var sex:String = ""
    var lastUpdated = Date()
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
    var latitude:Double? = null
    var longitude:Double? = null
}