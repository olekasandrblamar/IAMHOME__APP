package com.cerashealth.ceras.lifeplus

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import android.util.Log
import androidx.core.content.ContextCompat
import com.cerashealth.ceras.*
import com.cerashealth.ceras.lifeplus.data.*
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class DataSync {

    companion object{
        private val TAG = DataSync::class.java.simpleName
        private val okHttp = OkHttpClient()
        private val jsonMediaType = "application/json; charset=utf-8".toMediaTypeOrNull()
        private const val baseUrl = "https://tracker.ceras.io/api/v1/device"
        private val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").create()
        private const val LAST_UPDATE_VAL = "flutter.last_sync_updates"
        private const val USER_PROFILE = "flutter.user_profile_data"
        private const val MAC_ADDRESS_NAME = "flutter.device_macid"
        private const val BASE_URL = "flutter.apiBaseUrl"
        var CURRENT_MAC_ADDRESS:String? = null


        fun uploadTemperature(temperatures:List<TemperatureUpload>){
            makePostRequest(gson.toJson(temperatures),"temperature")
        }

        private fun getBaseUrl():String?{
            MainActivity.currentContext?.let { currentContext ->
                currentContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString(BASE_URL, "")?.let { baseUrl ->
                    return baseUrl
                }
            }
            return null
        }

        private fun updateLastSync(type:String, lastMeasure:Date){
            MainActivity.currentContext?.let { currentContext->
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
                        val postReq = Request.Builder().url("${getBaseUrl()}profileInfo?deviceId=$it")
                                .get()
                                .addHeader("BACKGROUND_STATUS",BaseDevice.isBackground.toString())
                                .build()
                        okHttp.newCall(postReq).enqueue(object: Callback{
                            override fun onFailure(call: Call, e: IOException) {
                                Log.e(TAG,"Failed calling ${call.request().url}",e)
                            }

                            override fun onResponse(call: Call, response: Response) {
                                Log.i(TAG,"Got response ${response.isSuccessful} for call ${call.request().url}")
                                try {
                                    val userProfile = gson.fromJson<UserProfile>(response.body?.string(), UserProfile::class.java)
                                    userProfile.lastUpdated = Date()
                                    currentContext.getSharedPreferences(MainActivity
                                            .SharedPrefernces, Context.MODE_PRIVATE).edit()
                                            .putString(USER_PROFILE, gson.toJson(userProfile)).apply()
                                    response.body?.close()
                                    response.close()
                                }catch (ex:Exception){
                                    Log.e(TAG,"Error while getting profile info ",ex)
                                }
                            }

                        })
                    }

                }


            }
        }

        fun uploadOxygenData(oxygenLevels:List<OxygenLevelUpload>){
            val type = "oxygen"
            val userProfile = getUserInfo()
            oxygenLevels.forEach { it.userProfile =  userProfile}
            makePostRequest(gson.toJson(oxygenLevels.filter { it.oxygenLevel>0 }),type)
            oxygenLevels.maxByOrNull { it.measureTime }?.let {
                updateLastSync(type,lastMeasure = it.measureTime)
            }
        }

        fun uploadBloodPressure(bpLevels:List<BpUpload>){
            val userProfile = getUserInfo()
            bpLevels.forEach { it.userProfile =  userProfile}
            makePostRequest(gson.toJson(bpLevels.filter { it.distolic>0 }),"bloodpressure")
            bpLevels.maxByOrNull { it.measureTime }?.let {
                updateLastSync("bloodpressure",lastMeasure = it.measureTime)
            }
        }

        fun uploadHeartRate(heartRates:List<HeartRateUpload>){
            makePostRequest(gson.toJson(heartRates.filter { it.heartRate>0 }),"heartrate")
            heartRates.maxByOrNull { it.measureTime }?.let {
                updateLastSync("heartrate",lastMeasure = it.measureTime)
            }
        }

        fun sendHeartBeat(heartBeat: HeartBeat){
            MainActivity.updateLastConnected()
            MainActivity.currentContext?.let {context->
                Log.i(TAG,"Updating last connected")
                heartBeat.deviceInfo = context.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.userDeviceInfo", "")
                heartBeat.notificationId = context.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.notificationToken", "")
                val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
                if(locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                        && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)==PackageManager.PERMISSION_GRANTED){
                    locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)?.let {location->
                        heartBeat.apply {
                            latitude = location.latitude
                            longitude = location.longitude
                        }
                    }
                }
            }

            heartBeat.background = BaseDevice.isBackground
            makePostRequest(gson.toJson(heartBeat),"heartbeat")
            checkAndLoadProfile()
        }

        fun uploadStepInfo(stepInfo:List<StepUpload>){
            makePostRequest(gson.toJson(stepInfo),"steps")
            stepInfo.maxByOrNull { it.measureTime }?.let {
                updateLastSync("steps",lastMeasure = it.measureTime)
            }
        }

        fun uploadDailySteps(dailySteps:List<DailyStepUpload>){
            makePostRequest(gson.toJson(dailySteps),"dailySteps")
            dailySteps.maxByOrNull { it.measureTime }?.let {
                updateLastSync("dailySteps",lastMeasure = it.measureTime)
            }
        }

        fun uploadCalories(calories:List<CaloriesUpload>){
            makePostRequest(gson.toJson(calories),"calories")
            calories.maxByOrNull { it.measureTime }?.let {
                updateLastSync("calories",lastMeasure = it.measureTime)
            }
        }

        /**
         * This method loads the weather info
         */
        fun loadWeatherInfo(deviceType:String){
            try {
                MainActivity.currentContext?.let { context ->

                    val lastUpdate = context.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("last_weather_update", "")

                    val today = SimpleDateFormat("yyyy-MM-dd").format(Calendar.getInstance().time)

                    Log.i(TAG,"Weather last update at $lastUpdate and today $today")

                    //If the last update is not today update the weather
                    if (lastUpdate != today) {
                        Log.i(TAG, "Updating weather")
                        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
                        if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                                && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                            locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)?.let {location->
                                Log.i(TAG," Calling weather at ${location.latitude} and ${location.longitude}")
                                val weatherUrl = "https://pro.openweathermap.org/data/2.5/forecast/daily?lat=${location.latitude}&lon=${location.longitude}&appid=4e33f6fdb2e35eeb5277b08ee0ff98bf&units=metric"
                                val getReq = Request.Builder().url(weatherUrl)
                                    .get()
                                    .build()
                                okHttp.newCall(getReq).enqueue(object : Callback {
                                    override fun onFailure(call: Call, e: IOException) {
                                        Log.e(TAG, "Failed calling ${call.request().url}", e)
                                    }

                                    override fun onResponse(call: Call, response: Response) {
                                        Log.i(TAG, "Got response ${response.isSuccessful} for call ${call.request().url}")
                                        try {
                                            val weatherData = gson.fromJson<Map<String, Any>>(response.body?.string(), Map::class.java)
                                            response.body?.close()
                                            response.close()
                                            val temps = (weatherData["list"] as List<Map<String, Any>>).map {
                                                val utcMillis = it["dt"] as Double
                                                val tempData = it["temp"] as Map<String, Any?>
                                                val weatherDetails = it["weather"] as List<Map<String, Any?>>
                                                var weatherId = 0
                                                if (weatherDetails.isNotEmpty()) {
                                                    weatherId = (weatherDetails[0]["id"] as Double).toInt()
                                                }
                                                val weatherType = when (weatherId) {
                                                    in 200..299 -> WeatherType.THUNDER
                                                    in 300..599 -> WeatherType.RAIN
                                                    in 600..699 -> WeatherType.SNOW
                                                    800 -> WeatherType.SUNNY
                                                    in 801..804 -> WeatherType.CLOUD
                                                    else -> WeatherType.UNK
                                                }
                                                WeatherInfo(utcMillis = utcMillis.toLong(), minTemp = tempData["min"] as Double, maxTemp = tempData["max"] as Double, weatherType)
                                            }
//                                        val deviceDataString = context.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.watchInfo", "")
//                                        val deviceData = Gson().fromJson(deviceDataString, ConnectionInfo::class.java)
                                            BaseDevice.getDeviceImpl(deviceType).syncWeather(temps)
                                            //Update the last weather update
                                            context.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).edit().putString("last_weather_update", today).apply()
                                        } catch (ex: Exception) {
                                            Log.e(TAG, "Error while getting profile info ", ex)
                                        }
                                    }

                                })
                            }
                        }
                    }
                }
            }catch(ex:Exception){
                Log.e(TAG,"Error while syncing weather ",ex)
            }
        }

        private fun makePostRequest(postData:String,url:String){
            Log.d(TAG,"Uploading data to $url with data $postData")
            val postReq = Request.Builder().url("${getBaseUrl()}$url")
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

data class WeatherInfo (val utcMillis:Long,val minTemp:Double,val maxTemp: Double,val weatherType:WeatherType = WeatherType.UNK){
}

enum class WeatherType{
    SUNNY,
    RAIN,
    SNOW,
    CLOUD,
    THUNDER,
    SMOG,
    UNK
}